class SmsAlertActivity {
  late int id;
  late String name;
  late bool enabled;
  late String description;
  late DateTime createdAt;
  late DateTime updatedAt;
  late bool requiresStores;

  SmsAlertActivity.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    enabled = json['enabled'];
    description = json['description'];
    requiresStores = json['requiresStores'];
    createdAt = DateTime.parse(json['createdAt']);
    updatedAt = DateTime.parse(json['updatedAt']);
  }
}