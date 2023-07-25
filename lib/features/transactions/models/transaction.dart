import 'package:bonako_demo/core/shared_models/name_and_description.dart';
import 'package:bonako_demo/core/shared_models/percentage.dart';
import 'package:bonako_demo/core/shared_models/currency.dart';
import 'package:bonako_demo/core/shared_models/link.dart';
import 'package:bonako_demo/core/shared_models/user.dart';
import '../../../../core/shared_models/money.dart';

class Transaction {
  late int id;
  late NameAndDescription paymentStatus;
  late String description;
  late Currency currency;
  late Money amount;
  late Percentage percentage;
  late int? paymentMethodId;
  late String? dpoPaymentUrl;
  late DateTime? dpoPaymentUrlExpiresAt;
  late int? payerUserId;
  late int? verifiedByUserId;
  late int? requestedByUserId;
  late bool isCancelled;
  late String? cancellationReason;
  late int? cancelledByUserId;
  late int? ownerId;
  late String? ownerType;
  late Attributes attributes;
  late Relationships relationships;
  late DateTime createdAt;
  late DateTime updatedAt;

  Transaction.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    paymentStatus = NameAndDescription.fromJson(json['paymentStatus']);
    description = json['description'];
    currency = Currency.fromJson(json['currency']);
    amount = Money.fromJson(json['amount']);
    percentage = Percentage.fromJson(json['percentage']);
    paymentMethodId = json['paymentMethodId'];
    dpoPaymentUrl = json['dpoPaymentUrl'];
    dpoPaymentUrlExpiresAt = json['dpoPaymentUrlExpiresAt'] == null ? null : DateTime.parse(json['dpoPaymentUrlExpiresAt']);
    payerUserId = json['payerUserId'];
    verifiedByUserId = json['verifiedByUserId'];
    requestedByUserId = json['requestedByUserId'];
    isCancelled = json['isCancelled'];
    cancellationReason = json['cancellationReason'];
    cancelledByUserId = json['cancelledByUserId'];
    ownerId = json['ownerId'];
    ownerType = json['ownerType'];
    attributes = Attributes.fromJson(json['attributes']);
    relationships = Relationships.fromJson(json['relationships'].runtimeType == List ? {} : json['relationships']);
    createdAt = DateTime.parse(json['createdAt']);
    updatedAt = DateTime.parse(json['updatedAt']);
  }
}

class Attributes {
  late bool isPaid;
  late String number;
  late bool isPendingPayment;
  late bool isVerifiedByUser;
  late bool isVerifiedBySystem;

  Attributes.fromJson(Map<String, dynamic> json) {
    isPaid = json['isPaid'];
    number = json['number'];
    isVerifiedByUser = json['isVerifiedByUser'];
    isPendingPayment = json['isPendingPayment'];
    isVerifiedBySystem = json['isVerifiedBySystem'];
  }
}

class Relationships {
  late User? payingUser;
  late User? requestingUser;

  Relationships.fromJson(Map<String, dynamic> json) {
    payingUser = json['payingUser'] == null ? null : User.fromJson(json['payingUser']);
    requestingUser = json['requestingUser'] == null ? null : User.fromJson(json['requestingUser']);
  }
}

class Links {
  late Link self;

  Links.fromJson(Map<String, dynamic> json) {
    self = Link.fromJson(json['self']);
  }
}