import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../widgets/loan_card.dart';
import 'loan_form_screen.dart';
import 'loan_detail_screen.dart';

class LoansTabScreen extends StatelessWidget {
  final AppState appState;
  const LoansTabScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    final loans = appState.loans;

    return Stack(
      children: [
        loans.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 96),
                  child: Text(
                    "No loans yet.\nTap + to add one.",
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 140),
                itemCount: loans.length,
                itemBuilder: (context, i) {
                  final loan = loans[i];
                  return LoanCard(
                    loan: loan,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LoanDetailScreen(
                            appState: appState,
                            loanId: loan.id,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LoanFormScreen(appState: appState),
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
