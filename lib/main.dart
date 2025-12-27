import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'state/app_state.dart';
import 'theme/app_theme.dart';
import 'screens/home_shell.dart';
import 'screens/settings_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final appState = AppState();
  await appState.loadFromPrefs(prefs);
  runApp(FinanceTrackerApp(appState: appState));
}

class FinanceTrackerApp extends StatelessWidget {
  final AppState appState;
  const FinanceTrackerApp({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'My Finances',
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: appState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: HomeShell(appState: appState),
          routes: {
            SettingsScreen.routeName: (_) => SettingsScreen(appState: appState),
          },
        );
      },
    );
  }
}
