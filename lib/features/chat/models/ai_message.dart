import 'package:perfect_order/core/shared_models/link.dart';

class AiMessage {
  late int? id;
  late String userContent;
  late DateTime updatedAt;
  late DateTime createdAt;
  late String assistantContent;

  AiMessage.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userContent = json['userContent'];
    assistantContent = json['assistantContent'];
    updatedAt = DateTime.parse(json['updatedAt']);
    createdAt = DateTime.parse(json['createdAt']);
  }
}

class Links {
  late Link self;
  late Link updateAiMessage;
  late Link deleteAiMessage;

  Links.fromJson(Map<String, dynamic> json) {
    self = Link.fromJson(json['self']);
    updateAiMessage = Link.fromJson(json['updateAiMessage']);
    deleteAiMessage = Link.fromJson(json['deleteAiMessage']);
  }
}