import 'package:flutter/material.dart';

import 'app.dart';
import 'core/api/api_client.dart';
import 'core/config/api_config.dart';
import 'core/storage/token_storage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(RefConectApp(api: ApiClient(urlBase: ApiConfig.urlBase), almacen: TokenStorage()));
}
