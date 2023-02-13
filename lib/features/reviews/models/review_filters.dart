class ReviewFilters {
  late List<Filter> filters;

  ReviewFilters.fromJson(List<Map<String, dynamic>> json) {
    filters = List<Filter>.from(json.map((reviewSubject) => Filter.fromJson(reviewSubject)));
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