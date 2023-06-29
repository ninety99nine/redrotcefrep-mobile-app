class FriendAndFriendGroupFilters {
  late List<Filter> menus;

  FriendAndFriendGroupFilters.fromJson(List<Map<String, dynamic>> json) {
    menus = List<Filter>.from(json.map((menu) => Filter.fromJson(menu)));
  }
}

class Filter {
  late String name;
  late int total;
  late String totalSummarized;

  Filter.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    total = json['total'];
    totalSummarized = json['totalSummarized'];
  }
}