class Status {
  late bool status;
  late String name;
  late String description;

  Status.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    status = json['status'];
    description = json['description'];
  }
}