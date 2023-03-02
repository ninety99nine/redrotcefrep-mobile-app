class ValueAndDescription {
  late String value;
  late String description;

  ValueAndDescription.fromJson(Map<String, dynamic> json) {
    value = json['value'].toString();
    description = json['description'];
  }
}