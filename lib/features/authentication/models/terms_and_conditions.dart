class TermsAndConditions {

  late String title;
  late String button;
  late List<Item> items;
  late String instruction;

  TermsAndConditions.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    button = json['button'];
    instruction = json['instruction'];
    items = (json['items'] as List).map((item) => Item.fromJson(item)).toList();
  }
  
}

class Item {
  late String name;
  late String href;

  Item.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    href = json['href'];
  }
}
