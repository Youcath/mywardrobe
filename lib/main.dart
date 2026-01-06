import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/database_helper.dart';
import 'providers/wardrobe_provider.dart';
import 'providers/theme_provider.dart';
import 'pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // sqflite 会在首次访问数据库时自动初始化，
  // 我们也可以在这里通过单例预热一下数据库
  await DatabaseHelper().database;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WardrobeProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: '我的私人衣橱',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.currentThemeData,
            home: const HomePage(),
          );
        },
      ),
    );
  }
}


