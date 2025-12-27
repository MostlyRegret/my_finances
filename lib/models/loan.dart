enum PaymentFrequency { weekly, biweekly, monthly }

class Loan {
  final String id;
  String name;

  // Starting point
  DateTime startDate;
  double principal;

  // Interest
  double annualInterestRatePercent; // e.g. 7.5

  // Payment plan
  PaymentFrequency frequency;
  double paymentAmount;

  Loan({
    required this.id,
    required this.name,
    required this.startDate,
    required this.principal,
    required this.annualInterestRatePercent,
    required this.frequency,
    required this.paymentAmount,
  });

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "startDate": startDate.toIso8601String(),
    "principal": principal,
    "annualInterestRatePercent": annualInterestRatePercent,
    "frequency": frequency.name,
    "paymentAmount": paymentAmount,
  };

  static Loan fromJson(Map<String, dynamic> json) => Loan(
    id: json["id"] as String,
    name: json["name"] as String,
    startDate: DateTime.parse(json["startDate"] as String),
    principal: (json["principal"] as num).toDouble(),
    annualInterestRatePercent: (json["annualInterestRatePercent"] as num)
        .toDouble(),
    frequency: PaymentFrequency.values.firstWhere(
      (e) => e.name == json["frequency"],
    ),
    paymentAmount: (json["paymentAmount"] as num).toDouble(),
  );
}
