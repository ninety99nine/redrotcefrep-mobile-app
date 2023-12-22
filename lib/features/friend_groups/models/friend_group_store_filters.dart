class FriendGroupStoreFilters {
  late List<FriendGroupStoreFilter> filters;

  FriendGroupStoreFilters.fromJson(List<Map<String, dynamic>> json) {
    filters = List<FriendGroupStoreFilter>.from(json.map((filter) => FriendGroupStoreFilter.fromJson(filter)));
  }
}

class FriendGroupStoreFilter {
  late String name;
  late int total;
  late String totalSummarized;

  FriendGroupStoreFilter.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    total = json['total'];
    totalSummarized = json['totalSummarized'];
  }
}