class Money {
  late double amount;
  late String amountWithCurrency;
  late String amountWithoutCurrency;

  Money.fromJson(Map<String, dynamic> json) {
    amount = double.parse(json['amount'].toString());
    amountWithCurrency = json['amountWithCurrency'];
    amountWithoutCurrency = json['amountWithoutCurrency'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['amount'] = amount;
    data['amountWithCurrency'] = amountWithCurrency;
    data['amountWithoutCurrency'] = amountWithoutCurrency;
    return data;
  }
}