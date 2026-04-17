import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/network/api_service.dart';
import 'core/storage/token_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ru_RU');
  final tokenStorage = TokenStorage();
  final api = ApiService(tokenStorage: tokenStorage);
  runApp(MentorBootstrap(api: api, tokenStorage: tokenStorage));
}
