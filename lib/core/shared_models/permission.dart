class Permission {
  late String name;
  late String grant;
  late String description;

  Permission.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    grant = json['grant'];
    description = json['description'];
  }
}