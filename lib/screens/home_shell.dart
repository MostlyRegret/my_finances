import 'package:flutter/material.dart';
import '../state/app_state.dart';
import 'loans_tab_screen.dart';
import 'budget_tab_screen.dart';
import 'settings_screen.dart';

class HomeShell extends StatefulWidget {
  final AppState appState;
  const HomeShell({super.key, required this.appState});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final tabs = [
      LoansTabScreen(appState: widget.appState),
      BudgetTabScreen(appState: widget.appState),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_index == 0 ? "Loans" : "Budget"),
        actions: [
          IconButton(
            onPressed: () =>
                Navigator.pushNamed(context, SettingsScreen.routeName),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: SafeArea(bottom: true, child: tabs[_index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.account_balance),
            label: "Loans",
          ),
          NavigationDestination(icon: Icon(Icons.paid), label: "Budget"),
        ],
      ),
    );
  }
}
