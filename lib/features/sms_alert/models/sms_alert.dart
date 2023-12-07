import 'package:bonako_demo/features/stores/models/shoppable_store.dart';
import 'sms_alert_activity_association.dart';

class SmsAlert {
  late int id;
  late int userId;
  late int smsCredits;
  late DateTime createdAt;
  late DateTime updatedAt;
  late Relationships relationships;

  SmsAlert.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['userId'];
    smsCredits = json['smsCredits'];
    createdAt = DateTime.parse(json['createdAt']);
    updatedAt = DateTime.parse(json['updatedAt']);
    relationships = Relationships.fromJson(json['relationships'].runtimeType == List ? {} : json['relationships']);
  }
}

class Relationships {
  late List<SmsAlertActivityAssociation> smsAlertActivityAssociations;

  Relationships.fromJson(Map<String, dynamic> json) {
    smsAlertActivityAssociations = (json['smsAlertActivityAssociations'] as List).map((smsAlertActivityAssociation) => SmsAlertActivityAssociation.fromJson(smsAlertActivityAssociation)).toList();
  }
}