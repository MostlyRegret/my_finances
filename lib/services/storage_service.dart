import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/loan.dart';
import '../models/budget.dart';

class StorageService {
  static const _kLoansKey = "loans_json";
  static const _kDarkModeKey = "dark_mode";
  static const _kBudgetKey = "budget_json";

  Future<void> saveDarkMode(SharedPreferences prefs, bool value) async {
    await prefs.setBool(_kDarkModeKey, value);
  }

  bool loadDarkMode(SharedPreferences prefs) {
    return prefs.getBool(_kDarkModeKey) ?? false;
  }

  Future<void> saveLoans(SharedPreferences prefs, List<Loan> loans) async {
    final list = loans.map((l) => l.toJson()).toList();
    await prefs.setString(_kLoansKey, jsonEncode(list));
  }

  List<Loan> loadLoans(SharedPreferences prefs) {
    final raw = prefs.getString(_kLoansKey);
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];
    return decoded
        .map((e) => Loan.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> saveBudget(SharedPreferences prefs, BudgetData budget) async {
    await prefs.setString(_kBudgetKey, jsonEncode(budget.toJson()));
  }

  BudgetData loadBudget(SharedPreferences prefs) {
    final raw = prefs.getString(_kBudgetKey);
    if (raw == null || raw.isEmpty) return BudgetData.empty();
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return BudgetData.empty();
    return BudgetData.fromJson(Map<String, dynamic>.from(decoded));
  }

  Future<void> clearAll(SharedPreferences prefs) async {
    await prefs.remove(_kLoansKey);
    await prefs.remove(_kBudgetKey);
    await prefs.remove(_kDarkModeKey);
  }
}
