class FriendGroupStoreAssociation {
  late int id;
  late int addedByUserId;
  late DateTime createdAt;
  late DateTime updatedAt;

  FriendGroupStoreAssociation.fromJson(Map<String, dynamic> json) {

    id = json['id'];
    addedByUserId = json['addedByUserId'];
    createdAt = DateTime.parse(json['createdAt']);
    updatedAt = DateTime.parse(json['updatedAt']);
  }
}