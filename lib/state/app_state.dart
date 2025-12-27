import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/loan.dart';
import '../models/budget.dart';
import '../services/storage_service.dart';

class AppState extends ChangeNotifier {
  final StorageService _storage = StorageService();

  bool isDarkMode = false;
  final List<Loan> loans = [];
  BudgetData budget = BudgetData.empty();

  SharedPreferences? _prefs;

  Future<void> loadFromPrefs(SharedPreferences prefs) async {
    _prefs = prefs;
    isDarkMode = _storage.loadDarkMode(prefs);

    loans
      ..clear()
      ..addAll(_storage.loadLoans(prefs));

    budget = _storage.loadBudget(prefs);

    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = _prefs;
    if (prefs == null) return;
    await _storage.saveDarkMode(prefs, isDarkMode);
    await _storage.saveLoans(prefs, loans);
    await _storage.saveBudget(prefs, budget);
  }

  Future<void> setDarkMode(bool value) async {
    isDarkMode = value;
    notifyListeners();
    await _persist();
  }

  // ---------- EXPORT ----------
  String exportAllDataJson() {
    final data = {
      "exportedAt": DateTime.now().toIso8601String(),
      "darkMode": isDarkMode,
      "loans": loans.map((l) => l.toJson()).toList(),
      "budget": budget.toJson(),
    };
    return const JsonEncoder.withIndent("  ").convert(data);
  }

  // ---------- IMPORT / RESTORE ----------
  /// Restores app data from exported JSON string.
  /// This REPLACES local data.
  Future<void> restoreFromJsonString(String jsonString) async {
    final prefs = _prefs;
    if (prefs == null) {
      throw StateError("Preferences not initialized.");
    }

    final decoded = jsonDecode(jsonString);
    if (decoded is! Map) {
      throw FormatException("Invalid JSON format.");
    }

    final map = Map<String, dynamic>.from(decoded);

    // darkMode is optional
    final darkMode = map["darkMode"];
    if (darkMode is bool) {
      isDarkMode = darkMode;
    }

    // loans
    final loansRaw = map["loans"];
    if (loansRaw is! List) {
      throw FormatException("Missing or invalid 'loans' array.");
    }
    final restoredLoans = loansRaw
        .map((e) => Loan.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    // budget
    final budgetRaw = map["budget"];
    BudgetData restoredBudget = BudgetData.empty();
    if (budgetRaw is Map) {
      restoredBudget = BudgetData.fromJson(
        Map<String, dynamic>.from(budgetRaw),
      );
    }

    // Apply in-memory
    loans
      ..clear()
      ..addAll(restoredLoans);
    budget = restoredBudget;

    notifyListeners();

    // Persist
    await _persist();
  }

  // ---------- LOANS ----------
  Future<void> addLoan(Loan loan) async {
    loans.add(loan);
    notifyListeners();
    await _persist();
  }

  Future<void> updateLoan(Loan updated) async {
    final idx = loans.indexWhere((l) => l.id == updated.id);
    if (idx == -1) return;
    loans[idx] = updated;
    notifyListeners();
    await _persist();
  }

  Future<void> deleteLoan(String id) async {
    loans.removeWhere((l) => l.id == id);
    notifyListeners();
    await _persist();
  }

  Loan? getLoanById(String id) {
    try {
      return loans.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }

  // ---------- BUDGET ----------
  String _newId() => DateTime.now().microsecondsSinceEpoch.toString();

  double incomeToMonthly(double amount, IncomeFrequency f) {
    switch (f) {
      case IncomeFrequency.weekly:
        return amount * 52.0 / 12.0;
      case IncomeFrequency.biweekly:
        return amount * 26.0 / 12.0;
      case IncomeFrequency.monthly:
        return amount;
      case IncomeFrequency.yearly:
        return amount / 12.0;
    }
  }

  double get monthlyIncomeTotal => budget.incomes.fold(
    0.0,
    (sum, item) => sum + incomeToMonthly(item.amount, item.frequency),
  );

  double get monthlyBillsTotal => budget.expenses
      .where((e) => e.category == ExpenseCategory.bills)
      .fold(0.0, (sum, e) => sum + e.monthlyAmount);

  double get monthlyOtherTotal => budget.expenses
      .where((e) => e.category == ExpenseCategory.other)
      .fold(0.0, (sum, e) => sum + e.monthlyAmount);

  double get monthlyExpensesTotal => monthlyBillsTotal + monthlyOtherTotal;

  double get monthlyLeftover => monthlyIncomeTotal - monthlyExpensesTotal;

  Future<void> addIncome({
    required String name,
    required double amount,
    required IncomeFrequency frequency,
  }) async {
    budget.incomes.add(
      IncomeItem(
        id: _newId(),
        name: name,
        amount: amount,
        frequency: frequency,
      ),
    );
    notifyListeners();
    await _persist();
  }

  Future<void> deleteIncome(String id) async {
    budget.incomes.removeWhere((e) => e.id == id);
    notifyListeners();
    await _persist();
  }

  Future<void> addExpense({
    required String name,
    required double monthlyAmount,
    required ExpenseCategory category,
  }) async {
    budget.expenses.add(
      ExpenseItem(
        id: _newId(),
        name: name,
        monthlyAmount: monthlyAmount,
        category: category,
      ),
    );
    notifyListeners();
    await _persist();
  }

  Future<void> deleteExpense(String id) async {
    budget.expenses.removeWhere((e) => e.id == id);
    notifyListeners();
    await _persist();
  }
}
