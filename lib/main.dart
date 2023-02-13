import 'features/team_members/widgets/team_members_show/team_members_page/team_members_page.dart';
import 'features/followers/widgets/followers_show/followers_page/followers_page.dart';
import 'features/introduction/widgets/introduction_role_selection_page.dart';
import 'features/reviews/widgets/reviews_show/reviews_page/reviews_page.dart';
import 'features/orders/widgets/orders_show/orders_page/orders_page.dart';
import 'features/friend_groups/providers/friend_group_provider.dart';
import 'features/introduction/widgets/introduction_slides_page.dart';
import 'features/authentication/widgets/reset_password_page.dart';
import 'features/authentication/providers/auth_provider.dart';
import 'features/stores/widgets/store_page/store_page.dart';
import 'features/authentication/widgets/signin_page.dart';
import 'features/authentication/widgets/signup_page.dart';
import 'features/introduction/widgets/landing_page.dart';
import 'features/orders/providers/order_provider.dart';
import 'features/stores/providers/store_provider.dart';
import 'features/api/providers/api_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';

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

}

class MyApp extends StatelessWidget {
  
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ApiProvider()
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
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme(),
        //  home: const AppHome(),
        initialRoute: LandingPage.routeName,
        routes: {
          IntroductionRoleSelectionPage.routeName: (_) => const IntroductionRoleSelectionPage(),
          IntroductionSlidesPage.routeName: (_) => const IntroductionSlidesPage(),
          ResetPasswordPage.routeName: (_) => const ResetPasswordPage(),
          //  StoreScreen.routeName: (_) => const StoreScreen(),
          TeamMembersPage.routeName: (_) => const TeamMembersPage(),
          FollowersPage.routeName: (_) => const FollowersPage(),
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