// Windows foreground activity agent: sends exe + window title + duration to Laravel API.
package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"time"
	"unsafe"

	"github.com/google/uuid"
	"golang.org/x/sys/windows"
)

const processQueryLimitedInformation = 0x1000

var (
	modUser32   = windows.NewLazySystemDLL("user32.dll")
	modKernel32 = windows.NewLazySystemDLL("kernel32.dll")

	procGetForegroundWindow        = modUser32.NewProc("GetForegroundWindow")
	procGetWindowTextLengthW       = modUser32.NewProc("GetWindowTextLengthW")
	procGetWindowTextW             = modUser32.NewProc("GetWindowTextW")
	procGetWindowThreadProcessId   = modUser32.NewProc("GetWindowThreadProcessId")
	procGetLastInputInfo           = modUser32.NewProc("GetLastInputInfo")

	procOpenProcess                = modKernel32.NewProc("OpenProcess")
	procCloseHandle                = modKernel32.NewProc("CloseHandle")
	procQueryFullProcessImageNameW = modKernel32.NewProc("QueryFullProcessImageNameW")
	procGetTickCount64             = modKernel32.NewProc("GetTickCount64")
)

type lastInputInfo struct {
	CbSize uint32
	DwTime uint32
}

type session struct {
	ID              string
	Exe             string
	Title           string
	StartedAt       time.Time
	LastHeartbeatAt time.Time
}

type payload struct {
	ClientSessionID string `json:"client_session_id"`
	Exe             string `json:"exe"`
	WindowTitle     string `json:"window_title,omitempty"`
	StartedAt       string `json:"started_at"`
	EndedAt         string `json:"ended_at,omitempty"`
	DurationSeconds int    `json:"duration_seconds"`
	DeviceName      string `json:"device_name,omitempty"`
	Event           string `json:"event,omitempty"`
}

func main() {
	log.SetFlags(0)
	baseURL := strings.TrimRight(os.Getenv("MENTOR_API_URL"), "/")
	if baseURL == "" {
		baseURL = "http://127.0.0.1:8000/api"
	}
	token := os.Getenv("MENTOR_TOKEN")
	if token == "" {
		log.Fatal("MENTOR_TOKEN is required (Sanctum Bearer token)")
	}
	poll := durationEnv("MENTOR_POLL_SECONDS", 12*time.Second)
	idleLimit := durationEnv("MENTOR_IDLE_SECONDS", 60*time.Second)
	heartbeat := durationEnv("MENTOR_HEARTBEAT_SECONDS", 60*time.Second)
	deviceName := os.Getenv("MENTOR_DEVICE_NAME")
	if deviceName == "" {
		deviceName = "windows-agent"
	}
	queuePath := queueFilePath()

	var cur *session
	lastPoll := time.Now()
	ticker := time.NewTicker(poll)
	defer ticker.Stop()

	for {
		now := time.Now()
		gap := now.Sub(lastPoll)
		lastPoll = now

		if gap > poll*3 && cur != nil {
			endSession(&cur, baseURL, token, deviceName, queuePath)
		}

		idleSec := idleSeconds()
		if idleSec >= uint32(idleLimit.Seconds()) {
			if cur != nil {
				endSession(&cur, baseURL, token, deviceName, queuePath)
			}
			drainQueue(baseURL, token, queuePath)
			<-ticker.C
			continue
		}

		exe, title, ok := foregroundExeTitle()
		if !ok || exe == "" {
			if cur != nil {
				endSession(&cur, baseURL, token, deviceName, queuePath)
			}
			drainQueue(baseURL, token, queuePath)
			<-ticker.C
			continue
		}

		key := exe + "\x00" + title
		prevKey := ""
		if cur != nil {
			prevKey = cur.Exe + "\x00" + cur.Title
		}
		if cur != nil && key != prevKey {
			endSession(&cur, baseURL, token, deviceName, queuePath)
		}

		if cur == nil {
			cur = &session{
				ID:              uuid.NewString(),
				Exe:             exe,
				Title:           title,
				StartedAt:       now,
				LastHeartbeatAt: now,
			}
		}

		if cur != nil && now.Sub(cur.LastHeartbeatAt) >= heartbeat {
			postPayload(baseURL, token, queuePath, payload{
				ClientSessionID: cur.ID,
				Exe:             cur.Exe,
				WindowTitle:     cur.Title,
				StartedAt:       cur.StartedAt.UTC().Format(time.RFC3339Nano),
				DurationSeconds: int(now.Sub(cur.StartedAt).Seconds()),
				DeviceName:      deviceName,
				Event:           "heartbeat",
			})
			cur.LastHeartbeatAt = now
		}

		drainQueue(baseURL, token, queuePath)
		<-ticker.C
	}
}

func durationEnv(name string, def time.Duration) time.Duration {
	v := strings.TrimSpace(os.Getenv(name))
	if v == "" {
		return def
	}
	if d, err := time.ParseDuration(v); err == nil {
		return d
	}
	if n, err := strconv.Atoi(v); err == nil {
		return time.Duration(n) * time.Second
	}
	return def
}

func foregroundExeTitle() (exe string, title string, ok bool) {
	hwnd, _, _ := procGetForegroundWindow.Call()
	if hwnd == 0 {
		return "", "", false
	}
	title = windowText(windows.Handle(hwnd))
	var pid uint32
	procGetWindowThreadProcessId.Call(hwnd, uintptr(unsafe.Pointer(&pid)))
	if pid == 0 {
		return "", title, true
	}
	path := exePathFromPID(pid)
	if path == "" {
		return fmt.Sprintf("pid-%d.exe", pid), title, true
	}
	return strings.ToLower(filepath.Base(path)), title, true
}

func windowText(hwnd windows.Handle) string {
	n, _, _ := procGetWindowTextLengthW.Call(uintptr(hwnd))
	if n == 0 {
		return ""
	}
	buf := make([]uint16, n+1)
	procGetWindowTextW.Call(uintptr(hwnd), uintptr(unsafe.Pointer(&buf[0])), uintptr(len(buf)))
	return windows.UTF16ToString(buf)
}

func exePathFromPID(pid uint32) string {
	h, _, _ := procOpenProcess.Call(
		uintptr(processQueryLimitedInformation),
		0,
		uintptr(pid),
	)
	if h == 0 {
		return ""
	}
	defer procCloseHandle.Call(h)

	buf := make([]uint16, 32768)
	size := uint32(len(buf))
	r, _, _ := procQueryFullProcessImageNameW.Call(
		h,
		0,
		uintptr(unsafe.Pointer(&buf[0])),
		uintptr(unsafe.Pointer(&size)),
	)
	if r == 0 {
		return ""
	}
	return windows.UTF16ToString(buf[:size])
}

func idleSeconds() uint32 {
	var li lastInputInfo
	li.CbSize = uint32(unsafe.Sizeof(li))
	r, _, _ := procGetLastInputInfo.Call(uintptr(unsafe.Pointer(&li)))
	if r == 0 {
		return 0
	}
	tick, _, _ := procGetTickCount64.Call()
	now := uint64(tick)
	last := uint64(li.DwTime)
	if now < last {
		return 0
	}
	return uint32((now - last) / 1000)
}

func endSession(cur **session, baseURL, token, deviceName, queuePath string) {
	s := *cur
	if s == nil {
		return
	}
	now := time.Now()
	postPayload(baseURL, token, queuePath, payload{
		ClientSessionID: s.ID,
		Exe:             s.Exe,
		WindowTitle:     s.Title,
		StartedAt:       s.StartedAt.UTC().Format(time.RFC3339Nano),
		EndedAt:         now.UTC().Format(time.RFC3339Nano),
		DurationSeconds: int(now.Sub(s.StartedAt).Seconds()),
		DeviceName:      deviceName,
	})
	*cur = nil
}

func postPayload(baseURL, token, queuePath string, p payload) {
	url := baseURL + "/v1/activity/sessions"
	body, err := json.Marshal(p)
	if err != nil {
		log.Println("marshal:", err)
		return
	}
	req, err := http.NewRequest(http.MethodPost, url, bytes.NewReader(body))
	if err != nil {
		log.Println("request:", err)
		return
	}
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Accept", "application/json")
	req.Header.Set("Authorization", "Bearer "+token)

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		log.Println("post:", err)
		appendQueue(queuePath, body)
		return
	}
	defer resp.Body.Close()
	if resp.StatusCode >= 300 {
		b, _ := io.ReadAll(resp.Body)
		log.Printf("api %s: %s", resp.Status, string(b))
		appendQueue(queuePath, body)
	}
}

func queueFilePath() string {
	if d, err := os.UserCacheDir(); err == nil {
		dir := filepath.Join(d, "MentorActivityAgent")
		_ = os.MkdirAll(dir, 0o700)
		return filepath.Join(dir, "pending.jsonl")
	}
	return filepath.Join(".", "pending.jsonl")
}

func appendQueue(path string, line []byte) {
	f, err := os.OpenFile(path, os.O_CREATE|os.O_WRONLY|os.O_APPEND, 0o600)
	if err != nil {
		return
	}
	defer f.Close()
	_, _ = f.Write(append(line, '\n'))
}

func drainQueue(baseURL, token, path string) {
	data, err := os.ReadFile(path)
	if err != nil || len(data) == 0 {
		return
	}
	lines := bytes.Split(bytes.TrimSpace(data), []byte("\n"))
	var remaining [][]byte
	for _, line := range lines {
		if len(line) == 0 {
			continue
		}
		req, err := http.NewRequest(http.MethodPost, baseURL+"/v1/activity/sessions", bytes.NewReader(line))
		if err != nil {
			remaining = append(remaining, line)
			continue
		}
		req.Header.Set("Content-Type", "application/json")
		req.Header.Set("Accept", "application/json")
		req.Header.Set("Authorization", "Bearer "+token)
		resp, err := http.DefaultClient.Do(req)
		if err != nil {
			remaining = append(remaining, line)
			continue
		}
		resp.Body.Close()
		if resp.StatusCode >= 300 {
			remaining = append(remaining, line)
		}
	}
	if len(remaining) == 0 {
		_ = os.Remove(path)
		return
	}
	_ = os.WriteFile(path, bytes.Join(remaining, []byte("\n")), 0o600)
}
