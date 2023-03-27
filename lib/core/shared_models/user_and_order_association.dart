class UserAndOrderAssociation {
  late int id;
  late String role;
  late bool canCollect;
  late DateTime updatedAt;
  late DateTime createdAt;
  late String? collectionCode;
  late String? collectionQrCode;
  late DateTime? collectionCodeExpiresAt;

  UserAndOrderAssociation.fromJson(Map<String, dynamic> json) {

    id = json['id'];
    role = json['role'];
    canCollect = json['canCollect'];
    collectionCode = json['collectionCode'];
    collectionQrCode = json['collectionQrCode'];
    createdAt = DateTime.parse(json['createdAt']);
    updatedAt = DateTime.parse(json['updatedAt']);
    collectionCodeExpiresAt = json['collectionCodeExpiresAt'] == null ? null : DateTime.parse(json['collectionCodeExpiresAt']);
    
  }
}