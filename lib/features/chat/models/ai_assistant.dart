import 'package:perfect_order/core/shared_models/percentage.dart';

class AiAssistant {
  late int id;
  late int userId;
  late int totalRequests;
  late int freeTokensUsed;
  late DateTime updatedAt;
  late DateTime createdAt;
  late int totalTokensUsed;
  late Attributes attributes;
  late int requestTokensUsed;
  late int responseTokensUsed;
  late int remainingPaidTokens;
  late bool requiresSubscription;
  late DateTime? remainingPaidTokensExpireAt;

  AiAssistant.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['userId'];
    totalRequests = json['totalRequests'];
    freeTokensUsed = json['freeTokensUsed'];
    totalTokensUsed = json['totalTokensUsed'];
    updatedAt = DateTime.parse(json['updatedAt']);
    createdAt = DateTime.parse(json['createdAt']);
    requestTokensUsed = json['requestTokensUsed'];
    responseTokensUsed = json['responseTokensUsed'];
    remainingPaidTokens = json['remainingPaidTokens'];
    requiresSubscription = json['requiresSubscription'];
    attributes = Attributes.fromJson(json['attributes']);
    remainingPaidTokensExpireAt = json['remainingPaidTokensExpireAt'] == null ? null : DateTime.parse(json['remainingPaidTokensExpireAt']);
  }
}

class Attributes {
  late Percentage usedTokensPercentage;
  late Percentage unusedTokensPercentage;

  Attributes.fromJson(Map<String, dynamic> json) {
    usedTokensPercentage = Percentage.fromJson(json['usedTokensPercentage']);
    unusedTokensPercentage = Percentage.fromJson(json['unusedTokensPercentage']);
  }
}