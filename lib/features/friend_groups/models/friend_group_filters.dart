class FriendGroupFilters {
  late List<FriendGroupFilter> filters;

  FriendGroupFilters.fromJson(List<Map<String, dynamic>> json) {
    filters = List<FriendGroupFilter>.from(json.map((filter) => FriendGroupFilter.fromJson(filter)));
  }
}

class FriendGroupFilter {
  late String name;
  late int total;
  late String totalSummarized;

  FriendGroupFilter.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    total = json['total'];
    totalSummarized = json['totalSummarized'];
  }
}