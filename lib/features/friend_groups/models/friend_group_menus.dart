class FriendGroupMenus {
  late List<Menu> menus;

  FriendGroupMenus.fromJson(List<Map<String, dynamic>> json) {
    menus = List<Menu>.from(json.map((menu) => Menu.fromJson(menu)));
  }
}

class Menu {
  late String name;
  late int total;
  late String totalSummarized;

  Menu.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    total = json['total'];
    totalSummarized = json['totalSummarized'];
  }
}