class Percentage {
  late int value;
  late String valueSymbol;

  Percentage.fromJson(Map<String, dynamic> json) {
    value = json['value'];
    valueSymbol = json['valueSymbol'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['value'] = value;
    data['valueSymbol'] = valueSymbol;
    return data;
  }
}