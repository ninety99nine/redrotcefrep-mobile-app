class Occasion {
  late int id;
  late String name;

  Occasion.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }
}