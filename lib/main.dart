import 'package:dfdfdfdf/screens/main_layout.dart';
import 'package:dfdfdfdf/services/ably_service.dart';
import 'package:dfdfdfdf/services/api_key_service.dart';
import 'package:dfdfdfdf/services/caching_service.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  // Before calling any Ably methods, ensure the widget binding is ready.
  WidgetsFlutterBinding.ensureInitialized();

  await AppCache.init();
  await AppCache.clear();
  // Because AblyService has to be initialized before runApp is called
  // provisioning also has to be done before the app starts
  final apiKeyProvision = await ApiKeyService().getOrProvisionApiKey();
  final ablyService = AblyService(apiKeyProvision: apiKeyProvision);

  runApp(MyApp(ablyService: ablyService));
}

class MyApp extends StatelessWidget {
  final AblyService ablyService;
  const MyApp({required this.ablyService, Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MainLayout(ablyService: ablyService),
    );
  }
}
