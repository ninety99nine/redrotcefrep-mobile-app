import 'package:bonako_demo/core/utils/pusher.dart';
import 'package:bonako_demo/features/coupons/providers/coupon_provider.dart';
import 'package:bonako_demo/features/notifications/providers/notification_provider.dart';
import 'package:bonako_demo/features/occasions/providers/occasion_provider.dart';
import 'package:bonako_demo/features/transactions/providers/transaction_provider.dart';

import 'features/team_members/widgets/team_members_show/team_members_page/team_members_page.dart';
import 'features/followers/widgets/followers_show/followers_page/followers_page.dart';
import 'features/introduction/widgets/introduction_role_selection_page.dart';
import 'features/reviews/widgets/reviews_show/reviews_page/reviews_page.dart';
import 'features/orders/widgets/orders_show/orders_page/orders_page.dart';
import 'features/friend_groups/providers/friend_group_provider.dart';
import 'features/introduction/widgets/introduction_slides_page.dart';
import 'features/authentication/widgets/reset_password_page.dart';
import '../../../../core/constants/constants.dart' as constants;
import 'features/authentication/providers/auth_provider.dart';
import 'features/stores/widgets/store_page/store_page.dart';
import 'features/addresses/providers/address_provider.dart';
import 'features/products/providers/product_provider.dart';
import 'features/authentication/widgets/signup_page.dart';
import 'features/authentication/widgets/signin_page.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'features/introduction/widgets/landing_page.dart';
import 'features/search/providers/search_provider.dart';
import 'features/orders/providers/order_provider.dart';
import 'features/stores/providers/store_provider.dart';
import 'features/user/providers/user_provider.dart';
import 'features/home/providers/home_provider.dart';
import 'features/api/providers/api_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'package:get/get.dart';
import 'dart:io';

//  This is the first method that flutter runs on this file
void main() {

  /**
   *  Prevent landscape mode. We only allow portrait mode 
   *  for when the device is oriented up (upright) or 
   *  down (upside down)
   */ 
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]);

  /**
   *  Run the app
   * 
   *  This calls the build function of the widget
   *  specified to extract the widget tree and
   *  construct the output to be rendered on
   *  the screen.
   */
  runApp(const MyApp());

  /// Check if we are running on an Android device
  if(Platform.isAndroid) {

    /**
     *  Setup OneSignal for notifications
     *  
     *  Reference 1: https://www.youtube.com/watch?v=k0dHYObtshU
     *  Reference 2: https://documentation.onesignal.com/docs/flutter-sdk-setup
     *  
     *  Android Emulator SUBSCRIPTION ISSUE?
     *  ------------------------------------
     *  Incase the Android Emulator is failing to create the user push channel subscription,
     *  you might be facing the following issue (check your DEBUG CONSOLE to confirm this):
     * 
     *  Flutter OneSignal caused by: java.security.cert.CertPathValidatorException: Response is unreliable: its validity interval is out-of-date
     *  
     *  Check out the article below to resolve this issue by clearing the emulator cache
     *  as suggested by "Md Imran Choudhury":
     * 
     *  Reference: https://stackoverflow.com/questions/53265234/sslhandshakeexception-chain-chain-validation-failed-how-to-solve
     */
    OneSignal.initialize(constants.oneSignalApiKey);

  }

}

class MyApp extends StatelessWidget {
  
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => HomeProvider()
        ),
        ChangeNotifierProvider(
          create: (_) => ApiProvider()
        ),
        ChangeNotifierProvider(
          create: (_) => PusherProvider.getInstance(),
        ),
        /**
         *  Note: We have to use the ChangeNotifierProxyProvider instead of 
         *  ChangeNotifierProvider because the SearchProvider requires the
         *  ApiProvider as a dependency. When the ApiProvider changes,
         *  then the SearchProvider will also rebuild.
         */
        ChangeNotifierProxyProvider<ApiProvider, SearchProvider>(
          create: (_) => SearchProvider(apiProvider: ApiProvider()),
          update: (ctx, apiProvider, previousSearchProvider) => SearchProvider(apiProvider: apiProvider)
        ),
        /**
         *  Note: We have to use the ChangeNotifierProxyProvider instead of 
         *  ChangeNotifierProvider because the AuthProvider requires the
         *  ApiProvider as a dependency. When the ApiProvider changes,
         *  then the AuthProvider will also rebuild.
         */
        ChangeNotifierProxyProvider<ApiProvider, AuthProvider>(
          create: (_) => AuthProvider(apiProvider: ApiProvider()),
          update: (ctx, apiProvider, previousAuthProvider) => AuthProvider(apiProvider: apiProvider)
        ),
        /**
         *  Note: We have to use the ChangeNotifierProxyProvider instead of 
         *  ChangeNotifierProvider because the UserProvider requires the
         *  ApiProvider as a dependency. When the ApiProvider changes,
         *  then the UserProvider will also rebuild.
         */
        ChangeNotifierProxyProvider<ApiProvider, UserProvider>(
          create: (_) => UserProvider(apiProvider: ApiProvider()),
          update: (ctx, apiProvider, previousUserProvider) => UserProvider(apiProvider: apiProvider)
        ),
        /**
         *  Note: We have to use the ChangeNotifierProxyProvider instead of 
         *  ChangeNotifierProvider because the StoreProvider requires the
         *  ApiProvider as a dependency. When the ApiProvider changes,
         *  then the StoreProvider will also rebuild.
         */
        ChangeNotifierProxyProvider<ApiProvider, StoreProvider>(
          create: (_) => StoreProvider(apiProvider: ApiProvider()),
          update: (ctx, apiProvider, previousStoreProvider) => StoreProvider(apiProvider: apiProvider)
        ),
        /**
         *  Note: We have to use the ChangeNotifierProxyProvider instead of 
         *  ChangeNotifierProvider because the ProductProvider requires the
         *  ApiProvider as a dependency. When the ApiProvider changes,
         *  then the ProductProvider will also rebuild.
         */
        ChangeNotifierProxyProvider<ApiProvider, ProductProvider>(
          create: (_) => ProductProvider(apiProvider: ApiProvider()),
          update: (ctx, apiProvider, previousProductProvider) => ProductProvider(apiProvider: apiProvider)
        ),
        /**
         *  Note: We have to use the ChangeNotifierProxyProvider instead of 
         *  ChangeNotifierProvider because the CouponProvider requires the
         *  ApiProvider as a dependency. When the ApiProvider changes,
         *  then the CouponProvider will also rebuild.
         */
        ChangeNotifierProxyProvider<ApiProvider, CouponProvider>(
          create: (_) => CouponProvider(apiProvider: ApiProvider()),
          update: (ctx, apiProvider, previousCouponProvider) => CouponProvider(apiProvider: apiProvider)
        ),
        /**
         *  Note: We have to use the ChangeNotifierProxyProvider instead of 
         *  ChangeNotifierProvider because the OrderProvider requires the
         *  ApiProvider as a dependency. When the ApiProvider changes,
         *  then the OrderProvider will also rebuild.
         */
        ChangeNotifierProxyProvider<ApiProvider, OrderProvider>(
          create: (_) => OrderProvider(apiProvider: ApiProvider()),
          update: (ctx, apiProvider, previousOrderProvider) => OrderProvider(apiProvider: apiProvider)
        ),
        /**
         *  Note: We have to use the ChangeNotifierProxyProvider instead of 
         *  ChangeNotifierProvider because the TransactionProvider requires the
         *  ApiProvider as a dependency. When the ApiProvider changes,
         *  then the TransactionProvider will also rebuild.
         */
        ChangeNotifierProxyProvider<ApiProvider, TransactionProvider>(
          create: (_) => TransactionProvider(apiProvider: ApiProvider()),
          update: (ctx, apiProvider, previousTransactionProvider) => TransactionProvider(apiProvider: apiProvider)
        ),
        /**
         *  Note: We have to use the ChangeNotifierProxyProvider instead of 
         *  ChangeNotifierProvider because the AddressProvider requires the
         *  ApiProvider as a dependency. When the ApiProvider changes,
         *  then the AddressProvider will also rebuild.
         */
        ChangeNotifierProxyProvider<ApiProvider, AddressProvider>(
          create: (_) => AddressProvider(apiProvider: ApiProvider()),
          update: (ctx, apiProvider, previousAddressProvider) => AddressProvider(apiProvider: apiProvider)
        ),
        /**
         *  Note: We have to use the ChangeNotifierProxyProvider instead of 
         *  ChangeNotifierProvider because the OccasionProvider requires the
         *  ApiProvider as a dependency. When the ApiProvider changes,
         *  then the OccasionProvider will also rebuild.
         */
        ChangeNotifierProxyProvider<ApiProvider, OccasionProvider>(
          create: (_) => OccasionProvider(apiProvider: ApiProvider()),
          update: (ctx, apiProvider, previousOccasionProvider) => OccasionProvider(apiProvider: apiProvider)
        ),
        /**
         *  Note: We have to use the ChangeNotifierProxyProvider instead of 
         *  ChangeNotifierProvider because the NotificationProvider requires 
         *  the AuthProvider as a dependency. When the AuthProvider changes,
         *  then the NotificationProvider will also rebuild.
         */
        ChangeNotifierProxyProvider<AuthProvider, NotificationProvider>(
          create: (_) => NotificationProvider(authProvider: AuthProvider(apiProvider: ApiProvider())),
          update: (ctx, authProvider, previousNotificationProvider) => NotificationProvider(authProvider: authProvider)
        ),
        /**
         *  Note: We have to use the ChangeNotifierProxyProvider instead of 
         *  ChangeNotifierProvider because the FriendGroupProvider requires the
         *  AuthProvider as a dependency. When the AuthProvider changes,
         *  then the FriendGroupProvider will also rebuild.
         */
        ChangeNotifierProxyProvider<AuthProvider, FriendGroupProvider>(
          create: (_) => FriendGroupProvider(authProvider: AuthProvider(apiProvider: ApiProvider())),
          update: (ctx, authProvider, previousFriendGroupProvider) => FriendGroupProvider(authProvider: authProvider)
        ),
        /**
         *  Note: We have to use the ChangeNotifierProxyProvider instead of 
         *  ChangeNotifierProvider because the AddressProvider requires the
         *  AuthProvider as a dependency. When the AuthProvider changes,
         *  then the AddressProvider will also rebuild.
         */
//        ChangeNotifierProxyProvider<AuthProvider, AddressProvider>(
//          create: (_) => AddressProvider(authProvider: AuthProvider(apiProvider: ApiProvider())),
//          update: (ctx, authProvider, previousAddressProvider) => AddressProvider(authProvider: authProvider)
//        ),
      ],
      /**
       *  Using GetMaterialApp instead of MaterialApp because we can use the 
       *  GetX snackbars, modals, http, utils and e.t.c which are easier and
       *  more flexible than those offered by MaterialApp e.g MaterialApp
       *  Snackbar require context to be provided to show a Snackbar
       *  while GetX Snackbar does not require the content to be
       *  provided
       * 
       *  Check out the GetX Package: https://pub.dev/packages/get
       */
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme(),
        //  home: const AppHome(),
        initialRoute: LandingPage.routeName,
        routes: {
          IntroductionRoleSelectionPage.routeName: (_) => const IntroductionRoleSelectionPage(),
          IntroductionSlidesPage.routeName: (_) => const IntroductionSlidesPage(),
          ResetPasswordPage.routeName: (_) => const ResetPasswordPage(),
          TeamMembersPage.routeName: (_) => const TeamMembersPage(),
          FollowersPage.routeName: (_) => const FollowersPage(),
          //  StoreScreen.routeName: (_) => const StoreScreen(),
          ReviewsPage.routeName: (_) => const ReviewsPage(),
          LandingPage.routeName: (_) => const LandingPage(),
          SigninPage.routeName: (_) => const SigninPage(),
          SignupPage.routeName: (_) => const SignupPage(),
          OrdersPage.routeName: (_) => const OrdersPage(),
          StorePage.routeName: (_) => const StorePage(),
        },
      ),
    );
  }
}