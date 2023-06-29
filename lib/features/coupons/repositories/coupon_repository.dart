import 'package:bonako_demo/features/coupons/enums/coupon_enums.dart';
import 'package:intl/intl.dart';

import '../../api/repositories/api_repository.dart';
import '../../api/providers/api_provider.dart';
import '../../coupons/models/coupon.dart';
import 'package:http/http.dart' as http;

class CouponRepository {

  /// The coupon does not exist until it is set.
  final Coupon? coupon;

  /// The Api Provider is provided to enable requests using the
  /// Bearer Token that has or has not been set
  final ApiProvider apiProvider;

  /// Constructor: Set the provided User and Api Provider
  CouponRepository({ this.coupon, required this.apiProvider });

  /// Get the Api Repository required to make requests with the set Bearer Token
  ApiRepository get apiRepository => apiProvider.apiRepository;

  /// Update the specified coupon
  Future<http.Response> updateCoupon({ 
    required String name, bool active = false, String? description, DiscountType discountType = DiscountType.percentage,
    bool offerDiscount = false, String? discountFixedRate, String? discountPercentageRate, bool offerFreeDelivery = false,
    bool activateUsingCode = false, String? code, bool activateUsingMinimumGrandTotal = false, String? minimumGrandTotal,
    bool activateUsingMinimumTotalProducts = false, String? minimumTotalProducts, bool activateUsingMinimumTotalProductQuantities = false,
    String? minimumTotalProductQuantities, bool activateUsingStartDatetime = false, DateTime? startDatetime, bool activateUsingEndDatetime = false,
    DateTime? endDatetime, bool activateUsingHoursOfDay = false, List hoursOfDay = const [], bool activateUsingDaysOfTheWeek = false,
    List daysOfTheWeek = const [], bool activateUsingDaysOfTheMonth = false, List daysOfTheMonth = const [],
    bool activateUsingMonthsOfTheYear = false, List monthsOfTheYear = const [], bool activateUsingUsageLimit = false,
    String? remainingQuantity, bool activateForNewCustomer = false, bool activateForExistingCustomer = false
  }) {

    if(coupon == null) throw Exception('The coupon must be set to update');

    String url = coupon!.links.updateCoupon.href;
    
    Map body = {
      'name': name,
      'active': active,
      'offerDiscount': offerDiscount,
      'discountType': discountType.name,
      'offerFreeDelivery': offerFreeDelivery,
      'activateUsingCode': activateUsingCode,
      'activateForNewCustomer': activateForNewCustomer,
      'activateUsingUsageLimit': activateUsingUsageLimit,
      'activateUsingHoursOfDay': activateUsingHoursOfDay,
      'activateUsingEndDatetime': activateUsingEndDatetime,
      'activateUsingStartDatetime': activateUsingStartDatetime,
      'activateUsingDaysOfTheWeek': activateUsingDaysOfTheWeek,
      'activateForExistingCustomer': activateForExistingCustomer,
      'activateUsingDaysOfTheMonth': activateUsingDaysOfTheMonth,
      'activateUsingMonthsOfTheYear': activateUsingMonthsOfTheYear,
      'activateUsingMinimumGrandTotal': activateUsingMinimumGrandTotal,
      'activateUsingMinimumTotalProducts': activateUsingMinimumTotalProducts,
      'activateUsingMinimumTotalProductQuantities': activateUsingMinimumTotalProductQuantities,
    };

    if(code != null) body['code'] = code;
    if(hoursOfDay.isNotEmpty) body['hoursOfDay'] = hoursOfDay;
    if(daysOfTheWeek.isNotEmpty) body['daysOfTheWeek'] = daysOfTheWeek;
    if(daysOfTheMonth.isNotEmpty) body['daysOfTheMonth'] = daysOfTheMonth;
    if(monthsOfTheYear.isNotEmpty) body['monthsOfTheYear'] = monthsOfTheYear;
    if(remainingQuantity != null) body['remainingQuantity'] = remainingQuantity;
    if(minimumGrandTotal != null) body['minimumGrandTotal'] = minimumGrandTotal;
    if(discountFixedRate != null) body['discountFixedRate'] = discountFixedRate;
    if(description != null && description.isNotEmpty) body['description'] = description;
    if(minimumTotalProducts != null) body['minimumTotalProducts'] = minimumTotalProducts;
    if(discountPercentageRate != null) body['discountPercentageRate'] = discountPercentageRate;
    if(endDatetime != null) body['endDatetime'] = DateFormat('yyyy-MM-dd HH:mm:ss').format(endDatetime);
    if(startDatetime != null) body['startDatetime'] = DateFormat('yyyy-MM-dd HH:mm:ss').format(startDatetime);
    if(minimumTotalProductQuantities != null) body['minimumTotalProductQuantities'] = minimumTotalProductQuantities;


    return apiRepository.put(url: url, body: body);
    
  }

  /// Delete the specified coupon
  Future<http.Response> deleteCoupon() {

    if(coupon == null) throw Exception('The coupon must be set to delete');
    String url = coupon!.links.deleteCoupon.href;
    return apiRepository.delete(url: url);
    
  }

}