import '../../../../core/shared_models/user_and_store_association.dart';
import '../../../../core/shared_models/shortcode.dart';
import '../../subscriptions/models/subscription.dart';
import '../../../../core/shared_models/link.dart';
import '../../products/models/product.dart';

class Store {
  late int id;
  late Links links;
  late bool online;
  late String name;
  late String? logo;
  late bool verified;
  late String? rating;
  late int? ordersCount;
  late int? couponsCount;
  late int? reviewsCount;
  late DateTime createdAt;
  late DateTime updatedAt;
  late int? followersCount;
  late String? description;
  late List<String> adverts;
  late int? teamMembersCount;
  late String offlineMessage;
  late Attributes attributes;
  late Relationships relationships;

  Store.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    logo = json['logo'];
    name = json['name'];
    online = json['online'];
    rating = json['rating'];
    verified = json['verified'];
    description = json['description'];
    ordersCount = json['ordersCount'];
    couponsCount = json['couponsCount'];
    reviewsCount = json['reviewsCount'];
    links = Links.fromJson(json['links']);
    followersCount = json['followersCount'];
    offlineMessage = json['offlineMessage'];
    teamMembersCount = json['teamMembersCount'];
    createdAt = DateTime.parse(json['createdAt']);
    updatedAt = DateTime.parse(json['updatedAt']);
    adverts = List<String>.from(json['adverts']);
    attributes = Attributes.fromJson(json['attributes'].runtimeType == List ? {} : json['attributes']);
    relationships = Relationships.fromJson(json['relationships'].runtimeType == List ? {} : json['relationships']);
  }
  
}

class Attributes {
  late UserAndStoreAssociation? userAndStoreAssociation;

  Attributes.fromJson(Map<String, dynamic> json) {
    userAndStoreAssociation = json['userAndStoreAssociation'] == null ? null : UserAndStoreAssociation.fromJson(json['userAndStoreAssociation']);
  }
}

class Relationships {
  late List<Product> products;
  late Shortcode? activeVisitShortcode;
  late Subscription? authActiveSubscription;

  Relationships.fromJson(Map<String, dynamic> json) {
    products = json['products'] == null ? [] : (json['products'] as List).map((product) => Product.fromJson(product)).toList();
    activeVisitShortcode = json['activeVisitShortcode'] == null ? null : Shortcode.fromJson(json['activeVisitShortcode']);
  }
}

class Links {
  late Link self;
  late Link showOrders;
  late Link showReviews;
  late Link showCoupons;
  late Link createReviews;
  late Link showFollowers;
  late Link showFollowing;
  late Link showTeamMembers;
  late Link updateFollowing;
  late Link inviteFollowers;
  late Link inviteTeamMembers;
  late Link removeTeamMembers;
  late Link showOrderFilters;
  late Link showReviewFilters;
  late Link addToFriendGroups;
  late Link inspectShoppingCart;
  late Link convertShoppingCart;
  late Link showFollowerFilters;
  late Link showTeamMemberFilters;
  late Link removeFromFriendGroups;
  late Link showShoppingCartOrderForUsers;
  late Link showReviewRatingOptions;
  late Link acceptInvitationToFollow;
  late Link declineInvitationToFollow;
  late Link acceptInvitationToJoinTeam;
  late Link declineInvitationToJoinTeam;
  late Link countShoppingCartOrderForUsers;  
  late Link showShoppingCartOrderForOptions;  

  Links.fromJson(Map<String, dynamic> json) {
    self = Link.fromJson(json['self']);
    showOrders = Link.fromJson(json['showOrders']);
    showReviews = Link.fromJson(json['showReviews']);
    showCoupons = Link.fromJson(json['showCoupons']);
    createReviews = Link.fromJson(json['createReviews']);
    showFollowers = Link.fromJson(json['showFollowers']);
    showFollowing = Link.fromJson(json['showFollowing']);
    showTeamMembers = Link.fromJson(json['showTeamMembers']);
    inviteFollowers = Link.fromJson(json['inviteFollowers']);
    updateFollowing = Link.fromJson(json['updateFollowing']);
    showOrderFilters = Link.fromJson(json['showOrderFilters']);
    addToFriendGroups = Link.fromJson(json['addToFriendGroups']);
    inviteTeamMembers = Link.fromJson(json['inviteTeamMembers']);
    removeTeamMembers = Link.fromJson(json['removeTeamMembers']);
    showReviewFilters = Link.fromJson(json['showReviewFilters']);
    inspectShoppingCart = Link.fromJson(json['inspectShoppingCart']);
    convertShoppingCart = Link.fromJson(json['convertShoppingCart']);
    showFollowerFilters = Link.fromJson(json['showFollowerFilters']);
    showTeamMemberFilters = Link.fromJson(json['showTeamMemberFilters']);
    removeFromFriendGroups = Link.fromJson(json['removeFromFriendGroups']);
    showReviewRatingOptions = Link.fromJson(json['showReviewRatingOptions']);
    acceptInvitationToFollow = Link.fromJson(json['acceptInvitationToFollow']);
    declineInvitationToFollow = Link.fromJson(json['declineInvitationToFollow']);
    acceptInvitationToJoinTeam = Link.fromJson(json['acceptInvitationToJoinTeam']);
    declineInvitationToJoinTeam = Link.fromJson(json['declineInvitationToJoinTeam']);
    showShoppingCartOrderForUsers = Link.fromJson(json['showShoppingCartOrderForUsers']);
    countShoppingCartOrderForUsers = Link.fromJson(json['countShoppingCartOrderForUsers']);
    showShoppingCartOrderForOptions = Link.fromJson(json['showShoppingCartOrderForOptions']);
  }

}