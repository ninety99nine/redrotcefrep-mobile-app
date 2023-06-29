import 'package:bonako_demo/core/shared_models/percentage.dart';
import 'package:bonako_demo/core/shared_models/status.dart';
import 'package:bonako_demo/features/coupons/enums/coupon_enums.dart';
import 'package:bonako_demo/core/shared_models/link.dart';
import '../../../../core/shared_models/money.dart';

class Coupon {
  late int id;
  late String name;
  late Links links;
  late String? code;
  late Status active;
  late List hoursOfDay;
  late List daysOfTheWeek;
  late List daysOfTheMonth;
  late String? description;
  late List monthsOfTheYear;
  late Status offerDiscount;
  late int remainingQuantity;
  late DateTime? endDatetime;
  late Attributes attributes;
  late Money discountFixedRate;
  late Money minimumGrandTotal;
  late DateTime? startDatetime;
  late Status activateUsingCode;
  late Status offerFreeDelivery;
  late int minimumTotalProducts;
  late DiscountType discountType;
  late Status activateForNewCustomer;
  late Status activateUsingHoursOfDay;
  late Status activateUsingUsageLimit;
  late Status activateUsingEndDatetime;
  late Percentage discountPercentageRate;
  late Status activateUsingDaysOfTheWeek;
  late Status activateUsingStartDatetime;
  late int minimumTotalProductQuantities;
  late Status activateForExistingCustomer;
  late Status activateUsingDaysOfTheMonth;
  late Status activateUsingMonthsOfTheYear;
  late Status activateUsingMinimumGrandTotal;
  late Status activateUsingMinimumTotalProducts;
  late Status activateUsingMinimumTotalProductQuantities;

  Coupon.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    code = json['code'];
    hoursOfDay = json['hoursOfDay'];
    description = json['description'];
    links = Links.fromJson(json['links']);
    daysOfTheWeek = json['daysOfTheWeek'];
    active = Status.fromJson(json['active']);
    daysOfTheMonth = json['daysOfTheMonth'];
    monthsOfTheYear = json['monthsOfTheYear'];
    remainingQuantity = json['remainingQuantity'];
    minimumTotalProducts = json['minimumTotalProducts'];
    attributes = Attributes.fromJson(json['attributes']);
    offerDiscount = Status.fromJson(json['offerDiscount']);
    minimumGrandTotal = Money.fromJson(json['minimumGrandTotal']);
    discountFixedRate = Money.fromJson(json['discountFixedRate']);
    activateUsingCode = Status.fromJson(json['activateUsingCode']);
    offerFreeDelivery = Status.fromJson(json['offerFreeDelivery']);
    minimumTotalProductQuantities = json['minimumTotalProductQuantities'];
    activateForNewCustomer = Status.fromJson(json['activateForNewCustomer']);
    activateUsingUsageLimit = Status.fromJson(json['activateUsingUsageLimit']);
    activateUsingHoursOfDay = Status.fromJson(json['activateUsingHoursOfDay']);
    discountPercentageRate = Percentage.fromJson(json['discountPercentageRate']);
    activateUsingEndDatetime = Status.fromJson(json['activateUsingEndDatetime']);
    activateUsingDaysOfTheWeek = Status.fromJson(json['activateUsingDaysOfTheWeek']);
    activateUsingStartDatetime = Status.fromJson(json['activateUsingStartDatetime']);
    activateForExistingCustomer = Status.fromJson(json['activateForExistingCustomer']);
    activateUsingDaysOfTheMonth = Status.fromJson(json['activateUsingDaysOfTheMonth']);
    activateUsingMonthsOfTheYear = Status.fromJson(json['activateUsingMonthsOfTheYear']);
    endDatetime = json['endDatetime'] == null ? null : DateTime.parse(json['endDatetime']);
    activateUsingMinimumGrandTotal = Status.fromJson(json['activateUsingMinimumGrandTotal']);
    startDatetime = json['startDatetime'] == null ? null : DateTime.parse(json['startDatetime']);
    activateUsingMinimumTotalProducts = Status.fromJson(json['activateUsingMinimumTotalProducts']);
    activateUsingMinimumTotalProductQuantities = Status.fromJson(json['activateUsingMinimumTotalProductQuantities']);
    discountType = DiscountType.values.firstWhere((discountType) => discountType.name.toLowerCase() == json['discountType'].toLowerCase());
  }
}

class Attributes {
  late List<String> instructions;

  Attributes.fromJson(Map<String, dynamic> json) {
    instructions = List<String>.from(json['instructions']);
  }
}

class Links {
  late Link self;
  late Link updateCoupon;
  late Link deleteCoupon;

  Links.fromJson(Map<String, dynamic> json) {
    self = Link.fromJson(json['self']);
    updateCoupon = Link.fromJson(json['updateCoupon']);
    deleteCoupon = Link.fromJson(json['deleteCoupon']);
  }

}