import '../models/loan.dart';
import 'date_utils.dart';

class LoanSnapshot {
  final DateTime asOf;
  final int paymentsMade;
  final double balance;
  final double totalPaid;
  final double totalInterest;

  const LoanSnapshot({
    required this.asOf,
    required this.paymentsMade,
    required this.balance,
    required this.totalPaid,
    required this.totalInterest,
  });
}

int periodsPerYear(PaymentFrequency f) {
  switch (f) {
    case PaymentFrequency.weekly:
      return 52;
    case PaymentFrequency.biweekly:
      return 26;
    case PaymentFrequency.monthly:
      return 12;
  }
}

DateTime nextPaymentDate(DateTime d, PaymentFrequency f) {
  switch (f) {
    case PaymentFrequency.weekly:
      return d.add(const Duration(days: 7));
    case PaymentFrequency.biweekly:
      return d.add(const Duration(days: 14));
    case PaymentFrequency.monthly:
      return addMonths(d, 1);
  }
}

LoanSnapshot simulateAsOf(Loan loan, DateTime asOf) {
  if (asOf.isBefore(loan.startDate)) {
    return LoanSnapshot(
      asOf: asOf,
      paymentsMade: 0,
      balance: loan.principal,
      totalPaid: 0,
      totalInterest: 0,
    );
  }

  final n = periodsPerYear(loan.frequency);
  final r = (loan.annualInterestRatePercent / 100.0) / n;

  double balance = loan.principal;
  double totalPaid = 0;
  double totalInterest = 0;
  int payments = 0;

  // Interpret startDate as first scheduled payment date.
  DateTime payDate = loan.startDate;

  while (!payDate.isAfter(asOf) && balance > 0.0) {
    final interest = balance * r;
    totalInterest += interest;
    balance += interest;

    final pay = loan.paymentAmount;
    final applied = pay > balance ? balance : pay;

    balance -= applied;
    totalPaid += applied;
    payments += 1;

    payDate = nextPaymentDate(payDate, loan.frequency);
  }

  // Avoid tiny negative due to floating point
  if (balance < 0.000001) balance = 0;

  return LoanSnapshot(
    asOf: asOf,
    paymentsMade: payments,
    balance: balance,
    totalPaid: totalPaid,
    totalInterest: totalInterest,
  );
}

/// Rough payoff projection from "now" onward (assumes same schedule).
/// Returns null if payment is too small to ever pay down the loan.
DateTime? projectedPayoffDateFromNow(Loan loan, DateTime now) {
  final snap = simulateAsOf(loan, now);
  if (snap.balance <= 0) return now;

  final n = periodsPerYear(loan.frequency);
  final r = (loan.annualInterestRatePercent / 100.0) / n;

  // If payment doesn't cover at least first period interest, it never decreases.
  final firstInterest = snap.balance * r;
  if (loan.paymentAmount <= firstInterest) return null;

  double balance = snap.balance;
  DateTime payDate = nextPaymentDate(now, loan.frequency);

  // Safety cap to prevent infinite loops.
  for (int i = 0; i < 20000; i++) {
    final interest = balance * r;
    balance += interest;

    final applied = loan.paymentAmount > balance ? balance : loan.paymentAmount;
    balance -= applied;

    if (balance <= 0.000001) return payDate;

    payDate = nextPaymentDate(payDate, loan.frequency);
  }
  return null;
}
