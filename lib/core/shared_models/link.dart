class Link {
  late String href;
  late String description;

  Link.fromJson(Map<String, dynamic> json) {
    href = json['href'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['href'] = href;
    data['description'] = description;
    return data;
  }
}