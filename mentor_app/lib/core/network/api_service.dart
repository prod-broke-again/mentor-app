import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../constants/api_constants.dart';
import '../storage/token_storage.dart';
import 'api_exception.dart';

/// Клиент Laravel API (Sanctum PAT + JSON/multipart).
final class ApiService {
  ApiService({required TokenStorage tokenStorage, http.Client? httpClient})
      : _tokenStorage = tokenStorage,
        _client = httpClient ?? http.Client();

  final TokenStorage _tokenStorage;
  final http.Client _client;

  Uri _uri(String path) {
    final base = ApiConstants.baseUrl.replaceAll(RegExp(r'/+$'), '');
    final p = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$base$p');
  }

  Future<Map<String, String>> _jsonHeaders({bool withAuth = true}) async {
    final h = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (withAuth) {
      final t = await _tokenStorage.readToken();
      if (t != null && t.isNotEmpty) {
        h['Authorization'] = 'Bearer $t';
      }
    }
    return h;
  }

  Future<Map<String, String>> _authHeaders() async {
    final h = <String, String>{'Accept': 'application/json'};
    final t = await _tokenStorage.readToken();
    if (t == null || t.isEmpty) {
      throw ApiException('Not authenticated', statusCode: 401);
    }
    h['Authorization'] = 'Bearer $t';
    return h;
  }

  /// POST /api/auth/login
  Future<void> login({required String email, required String password}) async {
    final res = await _client.post(
      _uri('/api/auth/login'),
      headers: await _jsonHeaders(withAuth: false),
      body: jsonEncode({
        'email': email,
        'password': password,
        'device_name': 'mentor_app',
      }),
    );
    if (res.statusCode != 200) {
      throw ApiException('Login failed', statusCode: res.statusCode, body: res.body);
    }
    final map = jsonDecode(res.body) as Map<String, dynamic>;
    final token = map['token'] as String?;
    if (token == null || token.isEmpty) {
      throw ApiException('No token in login response', statusCode: res.statusCode, body: res.body);
    }
    await _tokenStorage.writeToken(token);
  }

  Future<void> logout() async {
    final res = await _client.post(
      _uri('/api/auth/logout'),
      headers: await _jsonHeaders(),
    );
    await _tokenStorage.clear();
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw ApiException('Logout failed', statusCode: res.statusCode, body: res.body);
    }
  }

  /// GET /api/dashboard
  Future<Map<String, dynamic>> fetchDashboard() async {
    final res = await _client.get(
      _uri('/api/dashboard'),
      headers: await _authHeaders(),
    );
    if (res.statusCode != 200) {
      throw ApiException('Dashboard failed', statusCode: res.statusCode, body: res.body);
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  /// POST /api/ai/process (JSON body)
  Future<Map<String, dynamic>> processAiText(String text) async {
    final res = await _client.post(
      _uri('/api/ai/process'),
      headers: await _jsonHeaders(),
      body: jsonEncode({'text': text}),
    );
    if (res.statusCode != 200) {
      throw ApiException('AI process failed', statusCode: res.statusCode, body: res.body);
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  /// POST /api/ai/process (multipart audio)
  Future<Map<String, dynamic>> processAiAudioFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw ApiException('Audio file not found');
    }
    final request = http.MultipartRequest('POST', _uri('/api/ai/process'));
    request.headers.addAll(await _authHeaders());
    final ext = filePath.toLowerCase();
    MediaType? contentType;
    if (ext.endsWith('.m4a') || ext.endsWith('.aac')) {
      contentType = MediaType('audio', 'mp4');
    } else if (ext.endsWith('.wav')) {
      contentType = MediaType('audio', 'wav');
    } else if (ext.endsWith('.webm')) {
      contentType = MediaType('audio', 'webm');
    } else if (ext.endsWith('.mp3')) {
      contentType = MediaType('audio', 'mpeg');
    }
    request.files.add(
      await http.MultipartFile.fromPath(
        'audio',
        filePath,
        contentType: contentType,
      ),
    );
    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    if (res.statusCode != 200) {
      throw ApiException('AI audio failed', statusCode: res.statusCode, body: res.body);
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  void dispose() => _client.close();
}
