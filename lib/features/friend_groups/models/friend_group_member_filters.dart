class FriendGroupMemberFilters {
  late List<FriendGroupMemberFilter> filters;

  FriendGroupMemberFilters.fromJson(List<Map<String, dynamic>> json) {
    filters = List<FriendGroupMemberFilter>.from(json.map((filter) => FriendGroupMemberFilter.fromJson(filter)));
  }
}

class FriendGroupMemberFilter {
  late String name;
  late int total;
  late String totalSummarized;

  FriendGroupMemberFilter.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    total = json['total'];
    totalSummarized = json['totalSummarized'];
  }
}