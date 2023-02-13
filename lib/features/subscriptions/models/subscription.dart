class Subscription {
  late int id;
  late int userId;
  late int ownerId;
  late DateTime endAt;
  late String ownerType;
  late DateTime startAt;
  late DateTime createdAt;
  late DateTime updatedAt;
  late int subscriptionPlanId;

  Subscription.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['userId'];
    ownerId = json['ownerId'];
    ownerType = json['ownerType'];
    endAt = DateTime.parse(json['endAt']);
    startAt = DateTime.parse(json['startAt']);
    createdAt = DateTime.parse(json['createdAt']);
    updatedAt = DateTime.parse(json['updatedAt']);
    subscriptionPlanId = json['subscriptionPlanId'];
  }
}