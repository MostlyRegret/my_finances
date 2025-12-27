import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../state/app_state.dart';
import '../models/budget.dart';

class BudgetTabScreen extends StatelessWidget {
  final AppState appState;
  const BudgetTabScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat.currency(symbol: "\$");

    final monthlyIncome = appState.monthlyIncomeTotal;
    final bills = appState.monthlyBillsTotal;
    final other = appState.monthlyOtherTotal;
    final expenses = appState.monthlyExpensesTotal;
    final leftover = appState.monthlyLeftover;

    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 120),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Monthly Summary",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                _row("Income", money.format(monthlyIncome)),
                _row("Bills", money.format(bills)),
                _row("Other", money.format(other)),
                const Divider(),
                _row("Total expenses", money.format(expenses)),
                const SizedBox(height: 6),
                _row("Leftover", money.format(leftover)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Income
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Wages / Income",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: () => _showAddIncomeDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text("Add"),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (appState.budget.incomes.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text("No income items yet."),
                  )
                else
                  ...appState.budget.incomes.map((i) {
                    final monthly = appState.incomeToMonthly(
                      i.amount,
                      i.frequency,
                    );
                    return ListTile(
                      title: Text(i.name),
                      subtitle: Text(
                        "${i.frequency.name} • ${money.format(i.amount)} • monthly ≈ ${money.format(monthly)}",
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => appState.deleteIncome(i.id),
                      ),
                    );
                  }),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Expenses
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Monthly Expenses",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: () => _showAddExpenseDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text("Add"),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (appState.budget.expenses.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text("No expenses yet."),
                  )
                else ...[
                  Text("Bills", style: Theme.of(context).textTheme.titleSmall),
                  ...appState.budget.expenses
                      .where((e) => e.category == ExpenseCategory.bills)
                      .map(
                        (e) => ListTile(
                          title: Text(e.name),
                          subtitle: Text(money.format(e.monthlyAmount)),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => appState.deleteExpense(e.id),
                          ),
                        ),
                      ),
                  const SizedBox(height: 6),
                  Text("Other", style: Theme.of(context).textTheme.titleSmall),
                  ...appState.budget.expenses
                      .where((e) => e.category == ExpenseCategory.other)
                      .map(
                        (e) => ListTile(
                          title: Text(e.name),
                          subtitle: Text(money.format(e.monthlyAmount)),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => appState.deleteExpense(e.id),
                          ),
                        ),
                      ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  static Widget _row(String left, String right) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(left)),
          Text(right, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Future<void> _showAddIncomeDialog(BuildContext context) async {
    String name = "";
    String amountText = "";
    IncomeFrequency freq = IncomeFrequency.biweekly;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setState) {
            return AlertDialog(
              title: const Text("Add income"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      initialValue: name,
                      decoration: const InputDecoration(
                        labelText: "Name (e.g. Paycheck)",
                      ),
                      onChanged: (v) => setState(() => name = v),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      initialValue: amountText,
                      decoration: const InputDecoration(labelText: "Amount"),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (v) => setState(() => amountText = v),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: freq.name,
                      decoration: const InputDecoration(labelText: "Frequency"),
                      items: IncomeFrequency.values
                          .map(
                            (f) => DropdownMenuItem(
                              value: f.name,
                              child: Text(f.name),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v == null) return;
                        setState(
                          () => freq = IncomeFrequency.values.firstWhere(
                            (e) => e.name == v,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text("Cancel"),
                ),
                FilledButton(
                  onPressed: () async {
                    final n = name.trim();
                    final a = double.tryParse(amountText.trim());
                    if (n.isEmpty || a == null || a <= 0) return;

                    await appState.addIncome(
                      name: n,
                      amount: a,
                      frequency: freq,
                    );
                    if (dialogContext.mounted) Navigator.pop(dialogContext);
                  },
                  child: const Text("Add"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showAddExpenseDialog(BuildContext context) async {
    String name = "";
    String monthlyText = "";
    ExpenseCategory category = ExpenseCategory.bills;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setState) {
            return AlertDialog(
              title: const Text("Add expense"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      initialValue: name,
                      decoration: const InputDecoration(
                        labelText: "Name (e.g. Rent)",
                      ),
                      onChanged: (v) => setState(() => name = v),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      initialValue: monthlyText,
                      decoration: const InputDecoration(
                        labelText: "Monthly amount",
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (v) => setState(() => monthlyText = v),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: category.name,
                      decoration: const InputDecoration(labelText: "Category"),
                      items: ExpenseCategory.values
                          .map(
                            (c) => DropdownMenuItem(
                              value: c.name,
                              child: Text(c.name),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v == null) return;
                        setState(
                          () => category = ExpenseCategory.values.firstWhere(
                            (e) => e.name == v,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text("Cancel"),
                ),
                FilledButton(
                  onPressed: () async {
                    final n = name.trim();
                    final m = double.tryParse(monthlyText.trim());
                    if (n.isEmpty || m == null || m < 0) return;

                    await appState.addExpense(
                      name: n,
                      monthlyAmount: m,
                      category: category,
                    );
                    if (dialogContext.mounted) Navigator.pop(dialogContext);
                  },
                  child: const Text("Add"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
