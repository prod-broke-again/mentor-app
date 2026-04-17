import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mentor_app/core/network/api_service.dart';
import 'package:mentor_app/core/storage/token_storage.dart';
import 'package:mentor_app/core/theme/app_theme.dart';
import 'package:mentor_app/features/auth/presentation/login_page.dart';

void main() {
  testWidgets('LoginPage builds', (WidgetTester tester) async {
    final storage = TokenStorage();
    final api = ApiService(tokenStorage: storage);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightSoft(),
        home: LoginPage(api: api, onLoggedIn: () {}),
      ),
    );
    expect(find.text('Mentor'), findsOneWidget);
  });
}
