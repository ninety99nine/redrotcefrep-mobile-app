class Shortcode {
  late int id;
  late int ownerId;
  late String code;
  late String action;
  late String ownerType;
  late DateTime createdAt;
  late DateTime updatedAt;
  late DateTime expiresAt;
  late int? reservedForUserId;

  late Attributes attributes;

  Shortcode.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'];
    action = json['action'];
    ownerId = json['ownerId'];
    ownerType = json['ownerType'];
    expiresAt = DateTime.parse(json['expiresAt']);
    reservedForUserId = json['reservedForUserId'];
    createdAt = DateTime.parse(json['createdAt']);
    updatedAt = DateTime.parse(json['updatedAt']);
    attributes = Attributes.fromJson(json['attributes']);
  }
}

class Attributes {
  late Dial dial;

  Attributes.fromJson(Map<String, dynamic> json) {
    dial = Dial.fromJson(json['dial']);
  }
}

class Dial {
  late String code;
  late String instruction;

  Dial.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    instruction = json['instruction'];
  }
}