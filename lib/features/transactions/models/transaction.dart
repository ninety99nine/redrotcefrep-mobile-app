import 'package:perfect_order/core/shared_models/name_and_description.dart';
import 'package:perfect_order/core/shared_models/percentage.dart';
import 'package:perfect_order/core/shared_models/currency.dart';
import 'package:perfect_order/core/shared_models/link.dart';
import 'package:perfect_order/core/shared_models/user.dart';
import 'package:perfect_order/features/payment_methods/models/payment_method.dart';
import '../../../../core/shared_models/money.dart';

class Transaction {
  late int id;
  late Links links;
  late NameAndDescription paymentStatus;
  late String description;
  late String? proofOfPaymentPhoto;
  late Currency currency;
  late Money amount;
  late Percentage percentage;
  late int? paymentMethodId;
  late String? dpoPaymentUrl;
  late DateTime? dpoPaymentUrlExpiresAt;
  late int? paidByUserId;
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
    proofOfPaymentPhoto = json['proofOfPaymentPhoto'];
    description = json['description'];
    currency = Currency.fromJson(json['currency']);
    amount = Money.fromJson(json['amount']);
    percentage = Percentage.fromJson(json['percentage']);
    paymentMethodId = json['paymentMethodId'];
    dpoPaymentUrl = json['dpoPaymentUrl'];
    links = Links.fromJson(json['links']);
    dpoPaymentUrlExpiresAt = json['dpoPaymentUrlExpiresAt'] == null ? null : DateTime.parse(json['dpoPaymentUrlExpiresAt']);
    paidByUserId = json['paidByUserId'];
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
  late bool isSubjectToUserVerification;
  late bool isSubjectToSystemVerification;

  Attributes.fromJson(Map<String, dynamic> json) {
    isPaid = json['isPaid'];
    number = json['number'];
    isVerifiedByUser = json['isVerifiedByUser'];
    isPendingPayment = json['isPendingPayment'];
    isVerifiedBySystem = json['isVerifiedBySystem'];
    isSubjectToUserVerification = json['isSubjectToUserVerification'];
    isSubjectToSystemVerification = json['isSubjectToSystemVerification'];
  }
}

class Relationships {
  late User? paidByUser;
  late User? verifiedByUser;
  late User? requestedByUser;
  late PaymentMethod? paymentMethod;

  Relationships.fromJson(Map<String, dynamic> json) {
    paidByUser = json['paidByUser'] == null ? null : User.fromJson(json['paidByUser']);
    verifiedByUser = json['verifiedByUser'] == null ? null : User.fromJson(json['verifiedByUser']);
    requestedByUser = json['requestedByUser'] == null ? null : User.fromJson(json['requestedByUser']);
    paymentMethod = json['paymentMethod'] == null ? null : PaymentMethod.fromJson(json['paymentMethod']);
  }
}

class Links {
  late Link self;
  late Link deleteTransaction;
  late Link showProofOfPaymentPhoto;
  late Link updateProofOfPaymentPhoto;
  late Link deleteProofOfPaymentPhoto;

  Links.fromJson(Map<String, dynamic> json) {
    self = Link.fromJson(json['self']);
    deleteTransaction = Link.fromJson(json['deleteTransaction']);
    showProofOfPaymentPhoto = Link.fromJson(json['showProofOfPaymentPhoto']);
    updateProofOfPaymentPhoto = Link.fromJson(json['updateProofOfPaymentPhoto']);
    deleteProofOfPaymentPhoto = Link.fromJson(json['deleteProofOfPaymentPhoto']);
  }
}