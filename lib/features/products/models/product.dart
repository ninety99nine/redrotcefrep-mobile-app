import '../../../../core/shared_models/status.dart';
import '../../../../core/shared_models/money.dart';

class Quantitative {
  int quantity = 1;
}

class Product extends Quantitative {
  late int id;
  late String name;
  late Money unitPrice;
  late String? description;
  late Status showDescription;

  Product.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    unitPrice = Money.fromJson(json['unitPrice']);
    showDescription = Status.fromJson(json['showDescription']);
  }
}