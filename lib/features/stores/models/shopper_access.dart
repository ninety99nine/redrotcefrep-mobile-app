class ShopperAccess {
  
  late bool status;
  late String? description;
  late DateTime? expiresAt;

  ShopperAccess.fromJson(Map<String, dynamic> json) {

    status = json['status'];
    description = json['description'];
    expiresAt = json['expiresAt'] == null ? null : DateTime.parse(json['expiresAt']);
    
  }

}