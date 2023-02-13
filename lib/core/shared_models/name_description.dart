class NameAndDescription {
  late String name;
  late String description;

  NameAndDescription.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    description = json['description'];
  }
}