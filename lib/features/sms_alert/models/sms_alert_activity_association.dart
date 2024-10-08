import 'package:perfect_order/core/shared_models/link.dart';
import 'package:perfect_order/features/sms_alert/models/sms_alert_activity.dart';
import 'package:perfect_order/features/stores/models/shoppable_store.dart';

class SmsAlertActivityAssociation {
  late int id;
  late Links links;
  late bool enabled;
  late int smsAlertId;
  late DateTime createdAt;
  late DateTime updatedAt;
  late int totalAlertsSent;
  late int smsAlertActivityId;
  late Relationships relationships;

  SmsAlertActivityAssociation.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    enabled = json['enabled'];
    smsAlertId = json['smsAlertId'];
    links = Links.fromJson(json['links']);
    totalAlertsSent = json['totalAlertsSent'];
    createdAt = DateTime.parse(json['createdAt']);
    updatedAt = DateTime.parse(json['updatedAt']);
    smsAlertActivityId = json['smsAlertActivityId'];
    relationships = Relationships.fromJson(json['relationships'].runtimeType == List ? {} : json['relationships']);
  }
}

class Links {
  late Link updateSmsAlertActivityAssociation; 

  Links.fromJson(Map<String, dynamic> json) {
    updateSmsAlertActivityAssociation = Link.fromJson(json['updateSmsAlertActivityAssociation']);
  }
}

class Relationships {
  late SmsAlertActivity smsAlertActivity;
  late List<ShoppableStore> stores;

  Relationships.fromJson(Map<String, dynamic> json) {
    smsAlertActivity = SmsAlertActivity.fromJson(json['smsAlertActivity']);
    stores = (json['stores'] as List).map((store) => ShoppableStore.fromJson(store)).toList();
  }
}