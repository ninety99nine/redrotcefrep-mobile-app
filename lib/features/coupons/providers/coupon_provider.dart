import '../repositories/coupon_repository.dart';
import '../../api/providers/api_provider.dart';
import 'package:flutter/material.dart';
import '../models/coupon.dart';

/// The CouponProvider is strictly responsible for maintaining the state 
/// of the coupon. This state can then be shared with the rest of the 
/// application. Coupon related requests are managed by the 
/// CouponRepository which is responsible for communicating 
/// with data sources via a REST API connection provided
/// by the ApiProvider
class CouponProvider with ChangeNotifier {
  
  Coupon? _coupon;
  final ApiProvider apiProvider;

  /// Constructor: Set the provided Api Provider
  CouponProvider({ required this.apiProvider });

  /// Return the coupon
  Coupon? get coupon => _coupon;

  /// Return the Coupon Repository
  CouponRepository get couponRepository => CouponRepository(coupon: coupon, apiProvider: apiProvider);

  /// Set the specified coupon
  CouponProvider setCoupon(Coupon coupon) {
    _coupon = coupon;
    return this;
  }
}