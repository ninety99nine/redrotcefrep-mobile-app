import 'package:bonako_demo/core/shared_models/store_payment_method_association.dart';
import 'package:bonako_demo/features/payment_methods/models/payment_method.dart';
import 'package:bonako_demo/features/stores/models/team_member_access.dart';
import '../../../core/shared_models/friend_group_store_association.dart';
import 'package:bonako_demo/features/stores/models/shopper_access.dart';
import 'package:bonako_demo/core/shared_models/mobile_number.dart';
import '../../../core/shared_models/user_store_association.dart';
import 'package:bonako_demo/core/shared_models/money.dart';
import '../../../../core/shared_models/shortcode.dart';
import '../../../../core/shared_models/link.dart';
import '../../products/models/product.dart';

class Store {
  late int id;
  late Links links;
  late bool online;
  late String name;
  late String? logo;
  late String? emoji;
  late bool verified;
  late String? rating;
  late int? ordersCount;
  late bool isBrandStore;
  late int? couponsCount;
  late int? reviewsCount;
  late String? coverPhoto;
  late int? productsCount;
  late DateTime createdAt;
  late DateTime updatedAt;
  late int? followersCount;
  late String? description;
  late List<String> adverts;
  late int? teamMembersCount;
  late String offlineMessage;
  late Attributes attributes;
  late String? smsSenderName;
  late bool perfectPayEnabled;
  late bool isInfluencerStore;
  late bool dpoPaymentEnabled;
  late String? dpoCompanyToken;
  late int? collectedOrdersCount;
  late bool allowDepositPayments;
  late MobileNumber mobileNumber;
  late Relationships relationships;
  late List<int> depositPercentages;
  late bool allowInstallmentPayments;
  late int? activeSubscriptionsCount;
  late bool orangeMoneyPaymentEnabled;
  late String? orangeMoneyMerchantCode;
  late List<int> installmentPercentages;

  late bool allowDelivery;
  late String? deliveryNote;
  late Money deliveryFlatFee;
  late bool allowFreeDelivery;
  late List<DeliveryDestination> deliveryDestinations;
  
  late bool allowPickup;
  late String? pickupNote;
  late List<PickupDestination> pickupDestinations;

  Store.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    logo = json['logo'];
    name = json['name'];
    emoji = json['emoji'];
    online = json['online'];
    rating = json['rating'];
    verified = json['verified'];
    coverPhoto = json['coverPhoto'];
    pickupNote = json['pickupNote'];
    description = json['description'];
    ordersCount = json['ordersCount'];
    allowPickup = json['allowPickup'];
    couponsCount = json['couponsCount'];
    reviewsCount = json['reviewsCount'];
    deliveryNote = json['deliveryNote'];
    isBrandStore = json['isBrandStore'];
    smsSenderName = json['smsSenderName'];
    productsCount = json['productsCount'];
    allowDelivery = json['allowDelivery'];
    links = Links.fromJson(json['links']);
    followersCount = json['followersCount'];
    offlineMessage = json['offlineMessage'];
    dpoCompanyToken = json['dpoCompanyToken'];
    teamMembersCount = json['teamMembersCount'];
    adverts = List<String>.from(json['adverts']);
    perfectPayEnabled = json['perfectPayEnabled'];
    dpoPaymentEnabled = json['dpoPaymentEnabled'];
    allowFreeDelivery = json['allowFreeDelivery'];
    isInfluencerStore = json['isInfluencerStore'];
    createdAt = DateTime.parse(json['createdAt']);
    updatedAt = DateTime.parse(json['updatedAt']);
    collectedOrdersCount = json['collectedOrdersCount'];
    allowDepositPayments = json['allowDepositPayments'];
    deliveryFlatFee = Money.fromJson(json['deliveryFlatFee']);
    orangeMoneyMerchantCode = json['orangeMoneyMerchantCode'];
    mobileNumber = MobileNumber.fromJson(json['mobileNumber']);
    activeSubscriptionsCount = json['activeSubscriptionsCount'];
    allowInstallmentPayments = json['allowInstallmentPayments'];
    orangeMoneyPaymentEnabled = json['orangeMoneyPaymentEnabled'];
    attributes = Attributes.fromJson(json['attributes'].runtimeType == List ? {} : json['attributes']);
    relationships = Relationships.fromJson(json['relationships'].runtimeType == List ? {} : json['relationships']);
    depositPercentages = (json['depositPercentages'] as List<dynamic>).map((percentage) => int.parse(percentage.toString())).toList();
    installmentPercentages = (json['installmentPercentages'] as List<dynamic>).map((percentage) => int.parse(percentage.toString())).toList();
    pickupDestinations = json['pickupDestinations'] == null ? [] : (json['pickupDestinations'] as List).map((destination) => PickupDestination.fromJson(destination)).toList();
    deliveryDestinations = json['deliveryDestinations'] == null ? [] : (json['deliveryDestinations'] as List).map((destination) => DeliveryDestination.fromJson(destination)).toList();
  }
  
}

class Attributes {
  late ShopperAccess? shopperAccess;
  late TeamMemberAccess? teamMemberAccess;
  late UserStoreAssociation? userStoreAssociation;
  late FriendGroupStoreAssociation? friendGroupStoreAssociation;
  late StorePaymentMethodAssociation? storePaymentMethodAssociation;

  Attributes.fromJson(Map<String, dynamic> json) {
    shopperAccess = json['shopperAccess'] == null ? null : ShopperAccess.fromJson(json['shopperAccess']);
    teamMemberAccess = json['teamMemberAccess'] == null ? null : TeamMemberAccess.fromJson(json['teamMemberAccess']);
    userStoreAssociation = json['userStoreAssociation'] == null ? null : UserStoreAssociation.fromJson(json['userStoreAssociation']);
    friendGroupStoreAssociation = json['friendGroupStoreAssociation'] == null ? null : FriendGroupStoreAssociation.fromJson(json['friendGroupStoreAssociation']);
    storePaymentMethodAssociation = json['storePaymentMethodAssociation'] == null ? null : StorePaymentMethodAssociation.fromJson(json['storePaymentMethodAssociation']);
  }
}

class Relationships {
  late List<Product> products;
  late Shortcode? visitShortcode;
  late List<PaymentMethod> paymentMethods;

  Relationships.fromJson(Map<String, dynamic> json) {
    visitShortcode = json['visitShortcode'] == null ? null : Shortcode.fromJson(json['visitShortcode']);
    products = json['products'] == null ? [] : (json['products'] as List).map((product) => Product.fromJson(product)).toList();
    paymentMethods = json['paymentMethods'] == null ? [] : (json['paymentMethods'] as List).map((paymentMethod) => PaymentMethod.fromJson(paymentMethod)).toList();
  }
}

class DeliveryDestination {
  late Money cost;
  late String name;
  late bool allowFreeDelivery;

  DeliveryDestination.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    cost = Money.fromJson(json['cost']);
    allowFreeDelivery = json['allowFreeDelivery'];
  }

  Map toJson() {
    return {
      'name': name,
      'cost': cost.amount.toStringAsFixed(2),
      'allow_free_delivery': allowFreeDelivery
    };
  }
}

class PickupDestination {
  late String name;
  late String address;

  PickupDestination.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    address = json['address'];
  }

  Map toJson() {
    return {
      'name': name,
      'address': address,
    };
  }
}

class Links {
  late Link self;
  late Link updateStore;
  late Link deleteStore;
  late Link confirmDeleteStore;
  late Link showLogo;
  late Link updateLogo;
  late Link deleteLogo;
  late Link showCoverPhoto;
  late Link updateCoverPhoto;
  late Link deleteCoverPhoto;
  late Link showAdverts;
  late Link createAdvert;
  late Link updateAdvert;
  late Link deleteAdvert;
  late Link showProductFilters;
  late Link showProducts;
  late Link createProducts;
  late Link updateProductArrangement;
  late Link showCouponFilters;
  late Link showCoupons;
  late Link createCoupons;
  late Link showOrders;
  late Link showOrderFilters;
  late Link showReviews;
  late Link createReviews;
  late Link showReviewFilters;
  late Link showReviewRatingOptions;
  late Link showFollowerFilters;
  late Link showFollowers;
  late Link inviteFollowers;
  late Link showFollowing;
  late Link updateFollowing;
  late Link acceptInvitationToFollow;
  late Link declineInvitationToFollow;
  late Link showAllTeamMemberPermissions;
  late Link showTeamMemberFilters;
  late Link showTeamMembers;
  late Link inviteTeamMembers;
  late Link removeTeamMembers;
  late Link acceptInvitationToJoinTeam;
  late Link declineInvitationToJoinTeam;
  late Link showMyPermissions;
  late Link showCustomerFilters;
  late Link showCustomers;
  late Link showSupportedPaymentMethods;
  late Link showAvailablePaymentMethods;
  late Link showMySubscriptions;
  late Link createStoreAccessSubscriptions;
  late Link calculateStoreAccessSubscriptionAmount;
  late Link addToFriendGroups;
  late Link removeFromFriendGroups;
  late Link addToBrandStores;
  late Link removeFromBrandStores;
  late Link addOrRemoveFromBrandStores;
  late Link addToInfluencerStores;
  late Link removeFromInfluencerStores;
  late Link addOrRemoveFromInfluencerStores;
  late Link addToAssignedStores;
  late Link removeFromAssignedStores;
  late Link addOrRemoveFromAssignedStores;
  late Link showVisitShortcode;
  late Link generatePaymentShortcode;
  late Link countShoppingCartOrderForUsers;
  late Link showShoppingCartOrderForOptions;
  late Link showShoppingCartOrderForUsers;
  late Link inspectShoppingCart;
  late Link convertShoppingCart;
  late Link showSharableContent;
  late Link showSharableContentChoices;

  Links.fromJson(Map<String, dynamic> json) {
    self = Link.fromJson(json['self']);
    updateStore = Link.fromJson(json['updateStore']);
    deleteStore = Link.fromJson(json['deleteStore']);
    confirmDeleteStore = Link.fromJson(json['confirmDeleteStore']);
    showLogo = Link.fromJson(json['showLogo']);
    updateLogo = Link.fromJson(json['updateLogo']);
    deleteLogo = Link.fromJson(json['deleteLogo']);
    showCoverPhoto = Link.fromJson(json['showCoverPhoto']);
    updateCoverPhoto = Link.fromJson(json['updateCoverPhoto']);
    deleteCoverPhoto = Link.fromJson(json['deleteCoverPhoto']);
    showAdverts = Link.fromJson(json['showAdverts']);
    createAdvert = Link.fromJson(json['createAdvert']);
    updateAdvert = Link.fromJson(json['updateAdvert']);
    deleteAdvert = Link.fromJson(json['deleteAdvert']);
    showProductFilters = Link.fromJson(json['showProductFilters']);
    showProducts = Link.fromJson(json['showProducts']);
    createProducts = Link.fromJson(json['createProducts']);
    updateProductArrangement = Link.fromJson(json['updateProductArrangement']);
    showCouponFilters = Link.fromJson(json['showCouponFilters']);
    showCoupons = Link.fromJson(json['showCoupons']);
    createCoupons = Link.fromJson(json['createCoupons']);
    showOrders = Link.fromJson(json['showOrders']);
    showOrderFilters = Link.fromJson(json['showOrderFilters']);
    showReviews = Link.fromJson(json['showReviews']);
    createReviews = Link.fromJson(json['createReviews']);
    showReviewFilters = Link.fromJson(json['showReviewFilters']);
    showReviewRatingOptions = Link.fromJson(json['showReviewRatingOptions']);
    showFollowerFilters = Link.fromJson(json['showFollowerFilters']);
    showFollowers = Link.fromJson(json['showFollowers']);
    inviteFollowers = Link.fromJson(json['inviteFollowers']);
    showFollowing = Link.fromJson(json['showFollowing']);
    updateFollowing = Link.fromJson(json['updateFollowing']);
    acceptInvitationToFollow = Link.fromJson(json['acceptInvitationToFollow']);
    declineInvitationToFollow = Link.fromJson(json['declineInvitationToFollow']);
    showAllTeamMemberPermissions = Link.fromJson(json['showAllTeamMemberPermissions']);
    showTeamMemberFilters = Link.fromJson(json['showTeamMemberFilters']);
    showTeamMembers = Link.fromJson(json['showTeamMembers']);
    inviteTeamMembers = Link.fromJson(json['inviteTeamMembers']);
    removeTeamMembers = Link.fromJson(json['removeTeamMembers']);
    acceptInvitationToJoinTeam = Link.fromJson(json['acceptInvitationToJoinTeam']);
    declineInvitationToJoinTeam = Link.fromJson(json['declineInvitationToJoinTeam']);
    showMyPermissions = Link.fromJson(json['showMyPermissions']);
    showCustomerFilters = Link.fromJson(json['showCustomerFilters']);
    showCustomers = Link.fromJson(json['showCustomers']);
    showSupportedPaymentMethods = Link.fromJson(json['showSupportedPaymentMethods']);
    showAvailablePaymentMethods = Link.fromJson(json['showAvailablePaymentMethods']);
    showMySubscriptions = Link.fromJson(json['showMySubscriptions']);
    createStoreAccessSubscriptions = Link.fromJson(json['createStoreAccessSubscriptions']);
    calculateStoreAccessSubscriptionAmount = Link.fromJson(json['calculateStoreAccessSubscriptionAmount']);
    addToFriendGroups = Link.fromJson(json['addToFriendGroups']);
    removeFromFriendGroups = Link.fromJson(json['removeFromFriendGroups']);
    addToBrandStores = Link.fromJson(json['addToBrandStores']);
    removeFromBrandStores = Link.fromJson(json['removeFromBrandStores']);
    addOrRemoveFromBrandStores = Link.fromJson(json['addOrRemoveFromBrandStores']);
    addToInfluencerStores = Link.fromJson(json['addToInfluencerStores']);
    removeFromInfluencerStores = Link.fromJson(json['removeFromInfluencerStores']);
    addOrRemoveFromInfluencerStores = Link.fromJson(json['addOrRemoveFromInfluencerStores']);
    addToAssignedStores = Link.fromJson(json['addToAssignedStores']);
    removeFromAssignedStores = Link.fromJson(json['removeFromAssignedStores']);
    addOrRemoveFromAssignedStores = Link.fromJson(json['addOrRemoveFromAssignedStores']);
    showVisitShortcode = Link.fromJson(json['showVisitShortcode']);
    generatePaymentShortcode = Link.fromJson(json['generatePaymentShortcode']);
    countShoppingCartOrderForUsers = Link.fromJson(json['countShoppingCartOrderForUsers']);
    showShoppingCartOrderForOptions = Link.fromJson(json['showShoppingCartOrderForOptions']);
    showShoppingCartOrderForUsers = Link.fromJson(json['showShoppingCartOrderForUsers']);
    inspectShoppingCart = Link.fromJson(json['inspectShoppingCart']);
    convertShoppingCart = Link.fromJson(json['convertShoppingCart']);
    showSharableContent = Link.fromJson(json['showSharableContent']);
    showSharableContentChoices = Link.fromJson(json['showSharableContentChoices']);
  }

}