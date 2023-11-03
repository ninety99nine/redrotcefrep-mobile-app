class AiMessageCategory {
  late int id;
  late String name;
  late String description;
  late DateTime updatedAt;
  late DateTime createdAt;

  AiMessageCategory.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    updatedAt = DateTime.parse(json['updatedAt']);
    createdAt = DateTime.parse(json['createdAt']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{
      'id': id,
      'name': name,
      'description': description,
      'updated_at': updatedAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
    return data;
  }
}