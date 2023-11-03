import 'package:bonako_demo/core/shared_models/user_order_collection_association.dart';
import 'package:bonako_demo/features/payment_methods/models/payment_method.dart';
import 'package:bonako_demo/features/addresses/models/delivery_address.dart';
import 'package:bonako_demo/features/transactions/models/transaction.dart';
import 'package:bonako_demo/features/occasions/models/occasion.dart';
import '../../../core/shared_models/name_and_description.dart';
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
  late int? occasionId;
  late Currency currency;
  late DateTime createdAt;
  late String? specialNote;
  late int? customerUserId;
  late Money amountPending;
  late int totalViewsByTeam;
  late int? paymentMethodId;
  late Attributes attributes;
  late int? deliveryAddressId;
  late int? transactionsCount;
  late int orderForTotalUsers;
  late Money amountOutstanding;
  late int? collectionByUserId;
  late String? destinationName;
  late int orderForTotalFriends;
  late String? customerLastName;
  late String? customerFirstName;
  late NameAndDescription status;
  late Status collectionVerified;
  late Relationships relationships;
  late DateTime? lastViewedByTeamAt;
  late DateTime? firstViewedByTeamAt;
  late DateTime? collectionVerifiedAt;
  late int? collectionVerifiedByUserId;
  late Percentage amountPaidPercentage;
  late String? collectionByUserLastName;
  late NameAndDescription paymentStatus;
  late String? collectionByUserFirstName;
  late Percentage amountPendingPercentage;
  late NameAndDescription? collectionType;
  late Percentage amountOutstandingPercentage;
  late String? collectionVerifiedByUserLastName;
  late String? collectionVerifiedByUserFirstName;

  Order.fromJson(Map<String, dynamic> json) {

    id = json['id'];
    summary = json['summary'];
    orderFor = json['orderFor'];
    occasionId = json['occasionId'];
    specialNote = json['specialNote'];
    links = Links.fromJson(json['links']);
    customerUserId = json['customerUserId'];
    paymentMethodId = json['paymentMethodId'];
    destinationName = json['destinationName'];
    totalViewsByTeam = json['totalViewsByTeam'];
    customerLastName = json['customerLastName'];
    customerFirstName = json['customerFirstName'];
    transactionsCount = json['transactionsCount'];
    deliveryAddressId = json['deliveryAddressId'];
    createdAt = DateTime.parse(json['createdAt']);
    currency = Currency.fromJson(json['currency']);
    amountPaid = Money.fromJson(json['amountPaid']);
    orderForTotalUsers = json['orderForTotalUsers'];
    orderForTotalFriends = json['orderForTotalFriends'];
    status = NameAndDescription.fromJson(json['status']);
    attributes = Attributes.fromJson(json['attributes']);
    amountPending = Money.fromJson(json['amountPending']);
    collectionByUserLastName = json['collectionByUserLastName'];
    collectionByUserFirstName = json['collectionByUserFirstName'];
    amountOutstanding = Money.fromJson(json['amountOutstanding']);
    collectionVerifiedByUserId = json['collectionVerifiedByUserId'];
    collectionVerified = Status.fromJson(json['collectionVerified']);
    paymentStatus = NameAndDescription.fromJson(json['paymentStatus']);
    amountPaidPercentage = Percentage.fromJson(json['amountPaidPercentage']);
    collectionVerifiedByUserLastName = json['collectionVerifiedByUserLastName'];
    collectionVerifiedByUserFirstName = json['collectionVerifiedByUserFirstName'];
    amountPendingPercentage = Percentage.fromJson(json['amountPendingPercentage']);
    amountOutstandingPercentage = Percentage.fromJson(json['amountOutstandingPercentage']);
    lastViewedByTeamAt = json['lastViewedByTeamAt'] == null ? null : DateTime.parse(json['lastViewedByTeamAt']);
    collectionType = json['collectionType'] == null ? null : NameAndDescription.fromJson(json['collectionType']);
    relationships = Relationships.fromJson(json['relationships'].runtimeType == List ? {} : json['relationships']);
    firstViewedByTeamAt = json['firstViewedByTeamAt'] == null ? null : DateTime.parse(json['firstViewedByTeamAt']);
    collectionVerifiedAt = json['collectionVerifiedAt'] == null ? null : DateTime.parse(json['collectionVerifiedAt']);
  }
}

class Attributes {
  late bool isPaid;
  late bool isUnpaid;
  late String? number;
  late bool isWaiting;
  late bool isOnItsWay;
  late bool isCancelled;
  late bool isCompleted;
  late bool canMarkAsPaid;
  late String? customerName;
  late bool isPartiallyPaid;
  late bool isPendingPayment;
  late bool isReadyForPickup;
  late bool canRequestPayment;
  late String? customerDisplayName;
  late String? collectionByUserName;
  late List<PayableAmount> payableAmounts;
  late String? collectionVerifiedByUserName;
  late List<NameAndDescription> followUpStatuses;
  late DialToShowCollectionCode dialToShowCollectionCode;
  late UserOrderCollectionAssociation? userOrderCollectionAssociation;

  late bool isOrderingForMe;
  late bool isOrderingForBusiness;
  late bool isOrderingForFriendsOnly;
  late bool isOrderingForMeAndFriends;
  late String? otherAssociatedFriends;

  Attributes.fromJson(Map<String, dynamic> json) {

    number = json['number'];
    isPaid = json['isPaid'];
    isUnpaid = json['isUnpaid'];
    isWaiting = json['isWaiting'];
    isOnItsWay = json['isOnItsWay'];
    isCancelled = json['isCancelled'];
    isCompleted = json['isCompleted'];
    customerName = json['customerName'];
    canMarkAsPaid = json['canMarkAsPaid'];
    isOrderingForMe = json['isOrderingForMe'];
    isPartiallyPaid = json['isPartiallyPaid'];
    isPendingPayment = json['isPendingPayment'];
    isReadyForPickup = json['isReadyForPickup'];
    canRequestPayment = json['canRequestPayment'];
    customerDisplayName = json['customerDisplayName'];
    collectionByUserName = json['collectionByUserName'];
    isOrderingForBusiness = json['isOrderingForBusiness'];
    otherAssociatedFriends = json['otherAssociatedFriends'];
    isOrderingForFriendsOnly = json['isOrderingForFriendsOnly'];
    isOrderingForMeAndFriends = json['isOrderingForMeAndFriends'];
    collectionVerifiedByUserName = json['collectionVerifiedByUserName'];
    dialToShowCollectionCode = DialToShowCollectionCode.fromJson(json['dialToShowCollectionCode']);
    payableAmounts = List<PayableAmount>.from(json['payableAmounts'].map((payableAmount) {
      return PayableAmount.fromJson(payableAmount);
    })).toList();
    followUpStatuses = List<NameAndDescription>.from(json['followUpStatuses'].map((followUpStatus) {
      return NameAndDescription.fromJson(followUpStatus);
    })).toList();
    userOrderCollectionAssociation = json['userOrderCollectionAssociation'] == null ? null : UserOrderCollectionAssociation.fromJson(json['userOrderCollectionAssociation']);
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

class PayableAmount {

  late String name;
  late String type;
  late Money amount;
  late int percentage;

  PayableAmount.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    type = json['type'];
    percentage = json['percentage'];
    amount = Money.fromJson(json['amount']);
  }
}

class Relationships {
  late Cart? cart;
  late User? customer;
  late Occasion? occasion;
  late ShoppableStore? store;
  late PaymentMethod? paymentMethod;
  late List<Transaction>? transactions;
  late DeliveryAddress? deliveryAddress;

  Relationships.fromJson(Map<String, dynamic> json) {
    cart = json['cart'] == null ? null : Cart.fromJson(json['cart']);
    customer = json['customer'] == null ? null : User.fromJson(json['customer']);
    store = json['store'] == null ? null : ShoppableStore.fromJson(json['store']);
    occasion = json['occasion'] == null ? null : Occasion.fromJson(json['occasion']);
    paymentMethod = json['paymentMethod'] == null ? null : PaymentMethod.fromJson(json['paymentMethod']);
    deliveryAddress = json['deliveryAddress'] == null ? null : DeliveryAddress.fromJson(json['deliveryAddress']);
    transactions = json['transactions'] == null ? null : (json['transactions'] as List).map((transaction) => Transaction.fromJson(transaction)).toList();
  }
}

class Links {
  late Link self;
  late Link showCart;
  late Link showViewers;
  late Link showCustomer;
  late Link updateStatus;
  late Link showOccasion;
  late Link requestPayment;
  late Link showTransactions;
  late Link showDeliveryAddress;
  late Link revokeCollectionCode;
  late Link showTransactionsCount;
  late Link generateCollectionCode;
  late Link showTransactionFilters;
  late Link markAsUnverifiedPayment;
  late Link showRequestPaymentPaymentMethods;
  late Link showMarkAsUnverifiedPaymentPaymentMethods;

  Links.fromJson(Map<String, dynamic> json) {
    self = Link.fromJson(json['self']);
    showCart = Link.fromJson(json['showCart']);
    showViewers = Link.fromJson(json['showViewers']);
    showCustomer = Link.fromJson(json['showCustomer']);
    updateStatus = Link.fromJson(json['updateStatus']);
    showOccasion = Link.fromJson(json['showOccasion']);
    requestPayment = Link.fromJson(json['requestPayment']);
    showTransactions = Link.fromJson(json['showTransactions']);
    showDeliveryAddress = Link.fromJson(json['showDeliveryAddress']);
    revokeCollectionCode = Link.fromJson(json['revokeCollectionCode']);
    showTransactionsCount = Link.fromJson(json['showTransactionsCount']);
    generateCollectionCode = Link.fromJson(json['generateCollectionCode']);
    showTransactionFilters = Link.fromJson(json['showTransactionFilters']);
    markAsUnverifiedPayment = Link.fromJson(json['markAsUnverifiedPayment']);
    showRequestPaymentPaymentMethods = Link.fromJson(json['showRequestPaymentPaymentMethods']);
    showMarkAsUnverifiedPaymentPaymentMethods = Link.fromJson(json['showMarkAsUnverifiedPaymentPaymentMethods']);
  }
}