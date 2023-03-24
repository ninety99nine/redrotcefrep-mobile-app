import 'package:bonako_demo/core/shared_models/user_and_order_association.dart';

import '../../../core/shared_models/name_and_description.dart';
import '../../../../core/shared_models/mobile_number.dart';
import '../../../../core/shared_models/percentage.dart';
import '../../../../core/shared_models/currency.dart';
import '../../../../core/shared_models/status.dart';
import '../../../../core/shared_models/money.dart';
import '../../../../core/shared_models/link.dart';
import '../../../../core/shared_models/user.dart';
import '../../../../core/shared_models/cart.dart';
import '../../stores/models/shoppable_store.dart';

class Order {
  late int id;
  late Links links;
  late String summary;
  late String orderFor;
  late Money amountPaid;
  late Currency currency;
  late DateTime createdAt;
  late int customerUserId;
  late Money amountPending;
  late int totalViewsByTeam;
  late Attributes attributes;
  late int orderForTotalUsers;
  late Money amountOutstanding;
  late String customerLastName;
  late int orderForTotalFriends;
  late String customerFirstName;
  late NameAndDescription status;
  late Status collectionVerified;
  late Relationships relationships;
  late DateTime? lastViewedByTeamAt;
  late DateTime? firstViewedByTeamAt;
  late DateTime? collectionVerifiedAt;
  late Percentage amountPaidPercentage;
  late NameAndDescription paymentStatus;
  late MobileNumber customerMobileNumber;
  late Percentage amountPendingPercentage;
  late Percentage amountOutstandingPercentage;

  Order.fromJson(Map<String, dynamic> json) {

    id = json['id'];
    summary = json['summary'];
    orderFor = json['orderFor'];
    links = Links.fromJson(json['links']);
    customerUserId = json['customerUserId'];
    totalViewsByTeam = json['totalViewsByTeam'];
    customerLastName = json['customerLastName'];
    customerFirstName = json['customerFirstName'];
    createdAt = DateTime.parse(json['createdAt']);
    currency = Currency.fromJson(json['currency']);
    amountPaid = Money.fromJson(json['amountPaid']);
    orderForTotalUsers = json['orderForTotalUsers'];
    orderForTotalFriends = json['orderForTotalFriends'];
    status = NameAndDescription.fromJson(json['status']);
    attributes = Attributes.fromJson(json['attributes']);
    amountPending = Money.fromJson(json['amountPending']);
    amountOutstanding = Money.fromJson(json['amountOutstanding']);
    collectionVerified = Status.fromJson(json['collectionVerified']);
    paymentStatus = NameAndDescription.fromJson(json['paymentStatus']);
    amountPaidPercentage = Percentage.fromJson(json['amountPaidPercentage']);
    customerMobileNumber = MobileNumber.fromJson(json['customerMobileNumber']);
    amountPendingPercentage = Percentage.fromJson(json['amountPendingPercentage']);
    amountOutstandingPercentage = Percentage.fromJson(json['amountOutstandingPercentage']);
    lastViewedByTeamAt = json['lastViewedByTeamAt'] == null ? null : DateTime.parse(json['lastViewedByTeamAt']);
    relationships = Relationships.fromJson(json['relationships'].runtimeType == List ? {} : json['relationships']);
    firstViewedByTeamAt = json['firstViewedByTeamAt'] == null ? null : DateTime.parse(json['firstViewedByTeamAt']);
    collectionVerifiedAt = json['collectionVerifiedAt'] == null ? null : DateTime.parse(json['collectionVerifiedAt']);
  }
}

class Attributes {
  late String number;
  late String customerName;
  late List<NameAndDescription> followUpStatuses;
  late UserAndOrderAssociation? userAndOrderAssociation;
  late DialToShowCollectionCode dialToShowCollectionCode;

  Attributes.fromJson(Map<String, dynamic> json) {
    number = json['number'];
    customerName = json['customerName'];
    followUpStatuses = List<NameAndDescription>.from(json['followUpStatuses'].map((followUpStatus) {
      return NameAndDescription.fromJson(followUpStatus);
    })).toList();
    dialToShowCollectionCode = DialToShowCollectionCode.fromJson(json['dialToShowCollectionCode']);
    userAndOrderAssociation = json['userAndOrderAssociation'] == null ? null : UserAndOrderAssociation.fromJson(json['userAndOrderAssociation']);
  }
}

class DialToShowCollectionCode {
  late String code;
  late String instruction;

  DialToShowCollectionCode.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    instruction = json['instruction'];
  }
}

class Relationships {
  late Cart? cart;
  late User? customer;
  late ShoppableStore? store;
  //  late List<Transaction> transactions;

  Relationships.fromJson(Map<String, dynamic> json) {
    cart = json['cart'] == null ? null : Cart.fromJson(json['cart']);
    customer = json['customer'] == null ? null : User.fromJson(json['customer']);
    store = json['store'] == null ? null : ShoppableStore.fromJson(json['store']);
    //  transactions = (json['transactions'] as List).map((transaction) => Transaction.fromJson(transaction)).toList();
  }
}

class Links {
  late Link self;
  late Link showViewers;
  late Link updateStatus;
  late Link revokeCollectionCode;
  late Link generateCollectionCode;

  Links.fromJson(Map<String, dynamic> json) {
    self = Link.fromJson(json['self']);
    showViewers = Link.fromJson(json['showViewers']);
    updateStatus = Link.fromJson(json['updateStatus']);
    revokeCollectionCode = Link.fromJson(json['revokeCollectionCode']);
    generateCollectionCode = Link.fromJson(json['generateCollectionCode']);
  }
}