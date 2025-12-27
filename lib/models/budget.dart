enum IncomeFrequency { weekly, biweekly, monthly, yearly }

enum ExpenseCategory { bills, other }

class IncomeItem {
  final String id;
  String name;
  double amount;
  IncomeFrequency frequency;

  IncomeItem({
    required this.id,
    required this.name,
    required this.amount,
    required this.frequency,
  });

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "amount": amount,
    "frequency": frequency.name,
  };

  static IncomeItem fromJson(Map<String, dynamic> json) => IncomeItem(
    id: json["id"] as String,
    name: json["name"] as String,
    amount: (json["amount"] as num).toDouble(),
    frequency: IncomeFrequency.values.firstWhere(
      (e) => e.name == json["frequency"],
    ),
  );
}

class ExpenseItem {
  final String id;
  String name;
  double monthlyAmount;
  ExpenseCategory category;

  ExpenseItem({
    required this.id,
    required this.name,
    required this.monthlyAmount,
    required this.category,
  });

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "monthlyAmount": monthlyAmount,
    "category": category.name,
  };

  static ExpenseItem fromJson(Map<String, dynamic> json) => ExpenseItem(
    id: json["id"] as String,
    name: json["name"] as String,
    monthlyAmount: (json["monthlyAmount"] as num).toDouble(),
    category: ExpenseCategory.values.firstWhere(
      (e) => e.name == json["category"],
    ),
  );
}

class BudgetData {
  final List<IncomeItem> incomes;
  final List<ExpenseItem> expenses;

  BudgetData({required this.incomes, required this.expenses});

  Map<String, dynamic> toJson() => {
    "incomes": incomes.map((e) => e.toJson()).toList(),
    "expenses": expenses.map((e) => e.toJson()).toList(),
  };

  static BudgetData empty() => BudgetData(incomes: [], expenses: []);

  static BudgetData fromJson(Map<String, dynamic> json) => BudgetData(
    incomes: (json["incomes"] as List? ?? [])
        .map((e) => IncomeItem.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    expenses: (json["expenses"] as List? ?? [])
        .map((e) => ExpenseItem.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
  );
}
