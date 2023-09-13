class VariantAttribute {
  late String name;
  late String instruction;
  late List<String> values;

  VariantAttribute.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    instruction = json['instruction'];
    values = List<String>.from(json['values']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['values'] = values;
    data['instruction'] = instruction;
    return data;
  }
}