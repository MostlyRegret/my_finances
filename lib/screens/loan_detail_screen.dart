import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../state/app_state.dart';
import '../utils/loan_math.dart';
import 'loan_form_screen.dart';

class LoanDetailScreen extends StatelessWidget {
  final AppState appState;
  final String loanId;

  const LoanDetailScreen({
    super.key,
    required this.appState,
    required this.loanId,
  });

  @override
  Widget build(BuildContext context) {
    final loan = appState.getLoanById(loanId);
    if (loan == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Loan")),
        body: const Center(child: Text("Loan not found.")),
      );
    }

    final now = DateTime.now();
    final snap = simulateAsOf(loan, now);
    final payoff = projectedPayoffDateFromNow(loan, now);
    final money = NumberFormat.currency(symbol: "\$");

    return Scaffold(
      appBar: AppBar(
        title: Text(loan.name),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      LoanFormScreen(appState: appState, existing: loan),
                ),
              );
            },
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Delete loan?"),
                  content: const Text(
                    "This will remove the loan from your device.",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Cancel"),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("Delete"),
                    ),
                  ],
                ),
              );
              if (ok == true) {
                await appState.deleteLoan(loan.id);
                if (context.mounted) Navigator.pop(context);
              }
            },
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "As of today",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    _row("Balance", money.format(snap.balance)),
                    _row("Payments made", snap.paymentsMade.toString()),
                    _row("Total paid", money.format(snap.totalPaid)),
                    _row("Interest paid", money.format(snap.totalInterest)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Plan",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    _row(
                      "APR",
                      "${loan.annualInterestRatePercent.toStringAsFixed(2)}%",
                    ),
                    _row("Frequency", loan.frequency.name),
                    _row("Payment", money.format(loan.paymentAmount)),
                    const Divider(),
                    _row(
                      "Projected payoff",
                      payoff == null
                          ? "Payment too small (won’t pay down principal)"
                          : "${payoff.year}-${payoff.month.toString().padLeft(2, '0')}-${payoff.day.toString().padLeft(2, '0')}",
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Note: Assumes interest is applied each payment period. Lender methods can vary slightly.",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String left, String right) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(left)),
          Text(right, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
