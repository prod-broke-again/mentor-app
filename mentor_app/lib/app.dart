import 'package:flutter/material.dart';

import 'core/network/api_service.dart';
import 'core/security/biometric_auth.dart';
import 'core/storage/token_storage.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/login_page.dart';
import 'features/finance/presentation/pages/home_page.dart';

/// Корень приложения: Soft UI темы + переключение login / home по сессии.
class MentorBootstrap extends StatefulWidget {
  const MentorBootstrap({super.key, required this.api, required this.tokenStorage});

  final ApiService api;
  final TokenStorage tokenStorage;

  @override
  State<MentorBootstrap> createState() => _MentorBootstrapState();
}

class _MentorBootstrapState extends State<MentorBootstrap> {
  bool _checking = true;
  bool _loggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final t = await widget.tokenStorage.readToken();
    if (!mounted) return;

    if (t == null || t.isEmpty) {
      setState(() {
        _loggedIn = false;
        _checking = false;
      });
      return;
    }

    final bio = BiometricAuth();
    if (await bio.isAvailable) {
      final ok = await bio.authenticate(
        localizedReason: 'Подтвердите личность, чтобы открыть Mentor',
      );
      if (!mounted) return;
      if (!ok) {
        setState(() {
          _loggedIn = false;
          _checking = false;
        });
        return;
      }
    }

    try {
      await widget.api.validateSession();
      if (!mounted) return;
      setState(() {
        _loggedIn = true;
        _checking = false;
      });
    } catch (_) {
      await widget.tokenStorage.clear();
      if (!mounted) return;
      setState(() {
        _loggedIn = false;
        _checking = false;
      });
    }
  }

  void _onLoggedIn() => setState(() => _loggedIn = true);

  void _onLoggedOut() => setState(() => _loggedIn = false);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mentor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightSoft(),
      darkTheme: AppTheme.darkSoft(),
      themeMode: ThemeMode.system,
      home: Builder(
        builder: (context) {
          if (_checking) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      'Проверка сессии…',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            );
          }
          if (_loggedIn) {
            return HomePage(api: widget.api, onLogout: _onLoggedOut);
          }
          return LoginPage(api: widget.api, onLoggedIn: _onLoggedIn);
        },
      ),
    );
  }
}
