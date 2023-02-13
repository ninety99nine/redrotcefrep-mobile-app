class UserAssociationAsOrderViewer {
  late int id;
  late int views;
  late DateTime createdAt;
  late DateTime updatedAt;
  late DateTime lastSeenAt;

  UserAssociationAsOrderViewer.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    views = json['views'];
    createdAt = DateTime.parse(json['createdAt']);
    updatedAt = DateTime.parse(json['updatedAt']);
    lastSeenAt = DateTime.parse(json['lastSeenAt']);
  }
}