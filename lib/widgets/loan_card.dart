import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/loan.dart';
import '../utils/loan_math.dart';

class LoanCard extends StatelessWidget {
  final Loan loan;
  final VoidCallback onTap;

  const LoanCard({super.key, required this.loan, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final snap = simulateAsOf(loan, now);
    final money = NumberFormat.currency(symbol: "\$");

    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text(loan.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          "${loan.frequency.name} • APR ${loan.annualInterestRatePercent.toStringAsFixed(2)}% • Payment ${money.format(loan.paymentAmount)}",
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text("Balance", style: Theme.of(context).textTheme.labelSmall),
            Text(
              money.format(snap.balance),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
