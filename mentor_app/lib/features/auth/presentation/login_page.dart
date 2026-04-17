import 'package:flutter/material.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/api_service.dart';
import '../../../core/theme/soft_ui_colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.api, required this.onLoggedIn});

  final ApiService api;
  final VoidCallback onLoggedIn;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  String? _generalError;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _generalError = null;
      _emailError = null;
      _passwordError = null;
    });
    try {
      await widget.api.login(
        email: _email.text.trim(),
        password: _password.text,
      );
      widget.onLoggedIn();
    } on ApiException catch (e) {
      setState(() {
        _emailError = e.firstErrorForField('email');
        _passwordError = e.firstErrorForField('password');
        _generalError = e.message;
      });
    } catch (e) {
      setState(() => _generalError = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final soft = Theme.of(context).extension<SoftUiColors>() ?? SoftUiColors.dark;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: soft.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                Text(
                  'Mentor',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.8,
                        color: soft.textPrimary,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Вход в аккаунт',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: soft.textDim,
                      ),
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: soft.surfaceBubble,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: soft.outline),
                    boxShadow: SoftUiColors.shadowDropped(),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          errorText: _emailError,
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Введите email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _password,
                        obscureText: true,
                        autofillHints: const [AutofillHints.password],
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _trySubmit(),
                        decoration: InputDecoration(
                          labelText: 'Пароль',
                          errorText: _passwordError,
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Введите пароль';
                          }
                          return null;
                        },
                      ),
                      if (_generalError != null &&
                          (_emailError == null && _passwordError == null)) ...[
                        const SizedBox(height: 16),
                        Text(
                          _generalError!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: scheme.error,
                                height: 1.35,
                              ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: _loading ? null : _trySubmit,
                        child: _loading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Войти'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'После входа сессия может запрашивать биометрию на этом устройстве.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: soft.textMute,
                        height: 1.45,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _trySubmit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    _submit();
  }
}
