import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/time_entry_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final timeEntryProvider = TimeEntryProvider();
  await timeEntryProvider.initProvider();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => timeEntryProvider),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const Color primaryEmerald = Color.fromARGB(255, 6, 163, 90);
  static const Color darkBackground = Color(0xFF1B1B1B);
  static const Color cardColorDark = Color(0xFF2A2A2A);
  static const Color vibrantRed = Color(0xFF9B1C1C);

  // -------------------------
  // الثيم الداكن (Dark Theme)
  // -------------------------
  ThemeData _getDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      primaryColor: primaryEmerald,
      colorScheme: ColorScheme.dark(
        primary: primaryEmerald,
        secondary: primaryEmerald,
        surface: cardColorDark, // للخلفيات والكروت
        background: darkBackground,
        onPrimary: Colors.black,
        onSurface: Colors.white,
        onBackground: Colors.white,
        error: vibrantRed,
        onError: Colors.white,
      ),
      useMaterial3: true,
      fontFamily: 'Roboto',

      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: primaryEmerald,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryEmerald,
        foregroundColor: Colors.black,
      ),

      expansionTileTheme: ExpansionTileThemeData(
        textColor: primaryEmerald,
        iconColor: primaryEmerald,
        collapsedIconColor: Colors.white70,
        collapsedTextColor: Colors.white,
        backgroundColor: cardColorDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryEmerald, width: 2),
        ),
        labelStyle: const TextStyle(color: Colors.white70),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryEmerald,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // -------------------------
  //  (Light Theme)
  // -------------------------
  ThemeData _getLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.white,
      primaryColor: primaryEmerald,

      colorScheme: ColorScheme.light(
        primary: primaryEmerald,
        secondary: primaryEmerald,
        surface: Colors.white,
        background: Colors.grey.shade50,
        onPrimary: Colors.white,
        onSurface: Colors.black,
        onBackground: Colors.black,
        error: vibrantRed,
        onError: Colors.white,
      ),
      useMaterial3: true,
      fontFamily: 'Roboto',

      appBarTheme: AppBarTheme(
        backgroundColor: primaryEmerald,
        elevation: 1,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      listTileTheme: const ListTileThemeData(
        iconColor: primaryEmerald,
        textColor: Colors.black87,
      ),

      expansionTileTheme: ExpansionTileThemeData(
        textColor: primaryEmerald,
        iconColor: primaryEmerald,
        collapsedIconColor: Colors.black54,
        collapsedTextColor: Colors.black87,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Colors.grey.shade300),
        ),
      ),

      // حقول الإدخال الفاتحة
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: primaryEmerald,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryEmerald, width: 2),
        ),
        labelStyle: const TextStyle(color: Colors.black54),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: _getLightTheme(),
          darkTheme: _getDarkTheme(),
          themeMode: themeProvider.themeMode,
          home: const HomeScreen(),
        );
      },
    );
  }
}
