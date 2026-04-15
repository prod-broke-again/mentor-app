import 'package:flutter/material.dart';

import 'core/network/api_service.dart';
import 'core/storage/token_storage.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/login_page.dart';
import 'features/finance/presentation/pages/home_page.dart';

/// Корень приложения: тёмная тема + переключение login / home по токену.
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
    setState(() {
      _loggedIn = t != null && t.isNotEmpty;
      _checking = false;
    });
  }

  void _onLoggedIn() => setState(() => _loggedIn = true);

  void _onLoggedOut() => setState(() => _loggedIn = false);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mentor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkCyberpunk(),
      home: _checking
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : _loggedIn
              ? HomePage(api: widget.api, onLogout: _onLoggedOut)
              : LoginPage(api: widget.api, onLoggedIn: _onLoggedIn),
    );
  }
}
