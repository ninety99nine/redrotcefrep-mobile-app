import 'currency.dart';
import 'permission.dart';
import 'mobile_number.dart';

class UserStoreAssociation {
  late int id;
  late MobileNumber? mobileNumber;

  /*  Team Member Information  */
  late String? teamMemberRole;
  late String? teamMemberStatus;
  late List<Permission> teamMemberPermissions;

  /*  Follower Information  */
  late String? followerStatus;

  /*  Assigned Information  */
  late bool isAssigned;
  late int? assignedPosition;

  /*  Customer Information  */
  late Currency? currency;
  late int? totalOrdersRequested;
  late bool? isAssociatedAsCustomer;

  late bool isFollower;
  late bool isUnfollower;
  late bool isTeamMemberWhoHasJoined;
  late bool isTeamMemberWhoHasLeft;
  late bool isTeamMemberWhoIsInvited;
  late bool isTeamMemberWhoHasDeclined;
  late bool isTeamMemberAsCreatorOrAdmin;
  late bool isTeamMemberAsCreator;
  late bool isTeamMemberAsAdmin;
  late bool canManageEverything;
  late bool canManageOrders;
  late bool canManageProducts;
  late bool canManageCustomers;
  late bool canManageTeamMembers;
  late bool canManageInstantCarts;
  late bool canManageSettings;

  late DateTime createdAt;
  late DateTime updatedAt;
  late DateTime? lastSeenAt;

  UserStoreAssociation.fromJson(Map<String, dynamic> json) {

    id = json['id'];
    mobileNumber = json['mobileNumber'] == null ? null : MobileNumber.fromJson(json['mobileNumber']);

    /*  Team Member Information  */
    teamMemberRole = json['teamMemberRole'];
    teamMemberStatus = json['teamMemberStatus'];
    teamMemberPermissions = List.from(((json['teamMemberPermissions'] ?? []) as List).map((permission) => Permission.fromJson(permission)).toList());

    /*  Follower Information  */
    followerStatus = json['followerStatus'];

    /*  Assigned Information  */
    isAssigned = json['isAssigned'];
    assignedPosition = json['assignedPosition'];

    /*  Customer Information  */
    isAssociatedAsCustomer = json['isAssociatedAsCustomer'];

    currency = json['currency'] == null ? null : Currency.fromJson(json['currency']);
    totalOrdersRequested = json['totalOrdersRequested'];

    isFollower = json['isFollower'];
    isUnfollower = json['isUnfollower'];
    isTeamMemberWhoHasJoined = json['isTeamMemberWhoHasJoined'];
    isTeamMemberWhoHasLeft = json['isTeamMemberWhoHasLeft'];
    isTeamMemberWhoIsInvited = json['isTeamMemberWhoIsInvited'];
    isTeamMemberWhoHasDeclined = json['isTeamMemberWhoHasDeclined'];
    isTeamMemberAsCreatorOrAdmin = json['isTeamMemberAsCreatorOrAdmin'];
    isTeamMemberAsCreator = json['isTeamMemberAsCreator'];
    isTeamMemberAsAdmin = json['isTeamMemberAsAdmin'];
    canManageEverything = json['canManageEverything'];
    canManageOrders = json['canManageOrders'];
    canManageProducts = json['canManageProducts'];
    canManageCustomers = json['canManageCustomers'];
    canManageTeamMembers = json['canManageTeamMembers'];
    canManageInstantCarts = json['canManageInstantCarts'];
    canManageSettings = json['canManageSettings'];

    /*  Timestamp Information  */
    createdAt = DateTime.parse(json['createdAt']);
    updatedAt = DateTime.parse(json['updatedAt']);
    lastSeenAt = json['lastSeenAt'] == null ? null : DateTime.parse(json['lastSeenAt']);
    
  }
}