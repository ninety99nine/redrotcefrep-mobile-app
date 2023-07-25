import 'package:bonako_demo/core/shared_models/link.dart';

class Notification {
  late String id;
  late String type;
  late Links links;
  late DateTime? readAt;
  late int notifiableId;
  late DateTime createdAt;
  late DateTime updatedAt;
  late String notifiableType;
  late Map<String, dynamic> data;

  Notification.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    data = json['data'];
    type = json['type'];
    notifiableId = json['notifiableId'];
    links = Links.fromJson(json['links']);
    notifiableType = json['notifiableType'];
    createdAt = DateTime.parse(json['createdAt']);
    updatedAt = DateTime.parse(json['updatedAt']);
    readAt = json['readAt'] == null ? null : DateTime.parse(json['readAt']);
  }
}

class Links {
  late Link self;
  late Link markAsRead;

  Links.fromJson(Map<String, dynamic> json) {
    self = Link.fromJson(json['self']);
    markAsRead = Link.fromJson(json['markAsRead']);
  }

}