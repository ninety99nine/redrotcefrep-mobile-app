class OrderFilters {
  late List<Filter> filters;

  OrderFilters.fromJson(List<Map<String, dynamic>> json) {
    filters = List<Filter>.from(json.map((filter) => Filter.fromJson(filter)));
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