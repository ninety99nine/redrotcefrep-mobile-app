import 'currency.dart';
import 'permission.dart';
import 'mobile_number.dart';
import 'name_description.dart';

class UserAndStoreAssociation {
  late int id;
  late MobileNumber? mobileNumber;

  /*  Team Member Information  */
  late String? teamMemberRole;
  late String teamMemberStatus;
  late List<Permission> teamMemberPermissions;

  /*  Follower Information  */
  late String followerStatus;

  /*  Customer Information  */
  late Currency? currency;
  late bool? isAssociatedAsCustomer;
  late int? totalOrdersRequested;

  late DateTime createdAt;
  late DateTime updatedAt;
  late DateTime? lastSeenAt;

  UserAndStoreAssociation.fromJson(Map<String, dynamic> json) {

    id = json['id'];
    mobileNumber = json['mobileNumber'] == null ? null : MobileNumber.fromJson(json['mobileNumber']);

    /*  Team Member Information  */
    teamMemberRole = json['teamMemberRole'];
    teamMemberStatus = json['teamMemberStatus'];
    teamMemberPermissions = List.from(((json['teamMemberPermissions'] ?? []) as List).map((permission) => Permission.fromJson(permission)).toList());

    /*  Follower Information  */
    followerStatus = json['followerStatus'];

    /*  Customer Information  */
    isAssociatedAsCustomer = json['isAssociatedAsCustomer'];

    currency = json['currency'] == null ? null : Currency.fromJson(json['currency']);
    totalOrdersRequested = json['totalOrdersRequested'];

    /*  Timestamp Information  */
    createdAt = DateTime.parse(json['createdAt']);
    updatedAt = DateTime.parse(json['updatedAt']);
    lastSeenAt = json['lastSeenAt'] == null ? null : DateTime.parse(json['lastSeenAt']);
    
  }
}