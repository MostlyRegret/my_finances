import 'package:flutter/material.dart';
import '../models/loan.dart';
import '../state/app_state.dart';

class LoanFormScreen extends StatefulWidget {
  final AppState appState;
  final Loan? existing;

  const LoanFormScreen({super.key, required this.appState, this.existing});

  @override
  State<LoanFormScreen> createState() => _LoanFormScreenState();
}

class _LoanFormScreenState extends State<LoanFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _name;
  late final TextEditingController _principal;
  late final TextEditingController _apr;
  late final TextEditingController _payment;

  late DateTime _startDate;
  late PaymentFrequency _freq;

  bool get isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final loan = widget.existing;

    _name = TextEditingController(text: loan?.name ?? "");
    _principal = TextEditingController(text: loan?.principal.toString() ?? "");
    _apr = TextEditingController(
      text: loan?.annualInterestRatePercent.toString() ?? "",
    );
    _payment = TextEditingController(
      text: loan?.paymentAmount.toString() ?? "",
    );

    _startDate = loan?.startDate ?? DateTime.now();
    _freq = loan?.frequency ?? PaymentFrequency.biweekly;
  }

  @override
  void dispose() {
    _name.dispose();
    _principal.dispose();
    _apr.dispose();
    _payment.dispose();
    super.dispose();
  }

  String _newId() => DateTime.now().microsecondsSinceEpoch.toString();

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(1970),
      lastDate: DateTime(2100),
      initialDate: _startDate,
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  PaymentFrequency? _parseFrequency(String? v) {
    if (v == null) return null;
    return PaymentFrequency.values.firstWhere((e) => e.name == v);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? "Edit Loan" : "Add Loan")),
      body: SafeArea(
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.only(bottom: 96),
              children: [
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: "Loan name"),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? "Enter a name" : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _principal,
                  decoration: const InputDecoration(
                    labelText: "Principal (starting balance)",
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (v) {
                    final x = double.tryParse((v ?? "").trim());
                    if (x == null || x <= 0) return "Enter a valid principal";
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _apr,
                  decoration: const InputDecoration(
                    labelText: "APR % (annual interest rate)",
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (v) {
                    final x = double.tryParse((v ?? "").trim());
                    if (x == null || x < 0) return "Enter a valid APR";
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _freq.name,
                  decoration: const InputDecoration(
                    labelText: "Payment frequency",
                  ),
                  items: PaymentFrequency.values
                      .map(
                        (f) => DropdownMenuItem(
                          value: f.name,
                          child: Text(f.name),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _freq = _parseFrequency(v)!),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _payment,
                  decoration: const InputDecoration(
                    labelText: "Payment amount",
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (v) {
                    final x = double.tryParse((v ?? "").trim());
                    if (x == null || x <= 0) return "Enter a valid payment";
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text("Start date (first payment date)"),
                  subtitle: Text(
                    "${_startDate.year}-${_startDate.month.toString().padLeft(2, '0')}-${_startDate.day.toString().padLeft(2, '0')}",
                  ),
                  trailing: OutlinedButton(
                    onPressed: _pickStartDate,
                    child: const Text("Pick"),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;

                    final loan = Loan(
                      id: widget.existing?.id ?? _newId(),
                      name: _name.text.trim(),
                      startDate: _startDate,
                      principal: double.parse(_principal.text.trim()),
                      annualInterestRatePercent: double.parse(_apr.text.trim()),
                      frequency: _freq,
                      paymentAmount: double.parse(_payment.text.trim()),
                    );

                    if (isEdit) {
                      await widget.appState.updateLoan(loan);
                    } else {
                      await widget.appState.addLoan(loan);
                    }

                    if (mounted) Navigator.pop(context);
                  },
                  child: Text(isEdit ? "Save changes" : "Add loan"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
