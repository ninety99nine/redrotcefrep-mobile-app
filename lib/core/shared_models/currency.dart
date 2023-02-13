class Currency {
  late String symbol;
  late String code;

  Currency.fromJson(Map<String, dynamic> json) {
    symbol = json['symbol'];
    code = json['code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['symbol'] = symbol;
    data['code'] = code;
    return data;
  }
}