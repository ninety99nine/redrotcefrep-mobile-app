import 'package:bonako_demo/core/shared_models/user.dart';
import 'package:bonako_demo/features/introduction/widgets/introduction_role_selection_page.dart';
import 'package:bonako_demo/core/shared_widgets/Loader/custom_circular_progress_indicator.dart';
import 'package:bonako_demo/features/authentication/widgets/terms_and_conditions_page.dart';
import 'package:bonako_demo/features/introduction/services/introduction_service.dart';
import 'package:bonako_demo/features/authentication/providers/auth_provider.dart';
import 'package:bonako_demo/features/authentication/widgets/signin_page.dart';
import 'package:bonako_demo/core/exceptions/something_went_wrong_page.dart';
import 'package:bonako_demo/core/utils/internet_connectivity_utility.dart';
import 'package:bonako_demo/core/exceptions/request_failed_page.dart';
import 'package:bonako_demo/features/api/providers/api_provider.dart';
import 'package:bonako_demo/core/exceptions/no_internet_page.dart';
import 'package:bonako_demo/features/home/widgets/home_page.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:bonako_demo/core/utils/snackbar.dart';
import 'package:bonako_demo/core/utils/pusher.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'dart:convert';
import 'dart:async';

class LandingPage extends StatefulWidget {

  static const routeName = 'LandingPage';
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {

  String? fatalErrorMessage;
  bool hasSeenIntro = false;
  bool isAuthenticated = false;
  dio.Response? failedResponse;
  PusherProvider? pusherProvider;
  bool isLoadingApiRequest = false;
  bool isCheckingHasSeenIntro = false;
  bool hasAcceptedTermsAndConditions = false;
  final IntroductionService introductionService = IntroductionService();
  InternetConnectivityUtility internetConnectivityUtility = InternetConnectivityUtility();

  bool get hasNotSeenIntro => hasSeenIntro == false;
  bool get isDisconnected => hasConnection == false;
  bool get hasFailedResponse => failedResponse != null;
  bool get isNotAuthenticated => isAuthenticated == false;
  bool get hasFatalErrorMessage => fatalErrorMessage != null;
  bool get hasConnection => internetConnectivityUtility.hasConnection;
  ApiProvider get apiProvider => Provider.of<ApiProvider>(context, listen: false);
  AuthProvider get authProvider => Provider.of<AuthProvider>(context, listen: false);
  bool get hasNotAcceptedTermsAndConditions => hasAcceptedTermsAndConditions == false;
  bool get isCheckingInternetConnectivity => internetConnectivityUtility.isCheckingInternetConnectivity;

  void _startApiRequestLoader() => setState(() => isLoadingApiRequest = true);
  void _stopApiRequestLoader() => setState(() => isLoadingApiRequest = false);
  void _startHasSeenIntroLoader() => setState(() => isCheckingHasSeenIntro = true);
  void _stopHasSeenIntroLoader() => setState(() => isCheckingHasSeenIntro = false);

  @override
  void initState() {
    super.initState();
    
    /// Check and update the has seen app introduction page status
    _checkAndUpdateHasSeenIntroStatus();

    /// Check and update the internet connectivity status
    internetConnectivityUtility.checkAndUpdateInternetConnectivityStatus(
      setState: setState
    );

    /// Setup the internet connectivity listener - Continue listening for connectivity changes
    internetConnectivityUtility.setupInternetConnectivityListener(
      onDisconnected: _onDisconnected,
      onConnected: _onConnected,
      setState: setState
    );

    //  Clear the device storage
    //  await SharedPreferences.getInstance().then((prefs) => prefs.clear());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    /// Re-run the startSetup() in cases such as after
    /// user signin, signup or password reset success.
    /// Refer to the build() method comments for more
    /// information.
    if(!isLoadingApiRequest) setApiHome();
  }

  @override
  void dispose() {
    
    super.dispose();

    /// Cancel the internet connectivity listener
    internetConnectivityUtility.dispose();
  
    /// Unsubscribe from this specified event on this channel
    if(pusherProvider != null) pusherProvider!.unsubscribeToAuthLogin(identifier: 'LandingPage');

  }
  
  /// Check and update the has seen introduction status
  void _checkAndUpdateHasSeenIntroStatus() async {

    /// Start the loader to indicate that we are checking the has seen introduction status
    _startHasSeenIntroLoader();

    //  Check if the user has seen the app introduction page
    hasSeenIntro = await introductionService.checkIfHasSeenAnyIntroFromDeviceStorage();

    /// Stop the loader to indicate that we are no longer checking the has seen introduction status
    _stopHasSeenIntroLoader();

  }

  /// Internet connected callback
  void _onConnected() {

  }

  /// Internet disconnected callback
  void _onDisconnected() {

  }

  /// Listen for external login alerts
  void _listenForExternalLoginAlerts() async {

    /// Subscribe to login alerts
    pusherProvider!.subscribeToAuthLogin(
      identifier: 'LandingPage', 
      onEvent: _onLoginAlerts
    );

  }

  /// Handle external login alerts
  void _onLoginAlerts(event) async {

    if (event.eventName == "App\\Events\\LoginSuccess") {

      // Parse event.data into a Map
      var eventData = jsonDecode(event.data);

      //  Check if the bearer token has changed
      if (eventData['bearerToken'] != authProvider.bearerToken) {

        // Show the message that tells the user that they have been logged out
        SnackbarUtility.showSuccessMessage(
          message: eventData['loggingOutUsersMessage'] ?? 'Signing out',
          duration: 6
        );

        /**
         *  OneSignal Logout
         *  ----------------
         *  It is only recommended to call this method if you do not want to send transactional push notifications 
         *  to this device upon logout. For example, if your app sends targeted or personalized messages to users 
         *  based on their aliases and its expected that upon logout, that device should not get those types of 
         *  messages anymore, then it is a good idea to call OneSignal.logout()
         * 
         *  https://documentation.onesignal.com/docs/aliases-external-id#when-should-i-call-onesignallogout
         */
        await OneSignal.logout();

        /// Reload to verify unauthentication and show the signin page
        await setApiHome();

        /// Unsubscribe from everything
        /// Execute this unsubscribeFromEverything() method after the startSetup()
        /// otherwise running unsubscribeFromEverything() will delete this _onLoginAlerts() 
        /// event handler before it can execute the startSetup() method. In such a scenerio,
        /// we will not be able to re-run the setApiHome() which should make the API call to
        /// verify that this user is indeed unauthenticated thereby showing the signin page.
        pusherProvider!.unsubscribeFromEverything();

      }
    }

  }

  /// Reset the failed response if exists
  void _resetFailedResponse() {

    /// If we have a failed response
    if(hasFailedResponse) {

      /// Reset the failed response
      failedResponse = null;

    }

  }

  /// Reset the fatal error message if exists
  void _resetFatalErrorMessage() {

    /// If we have a failed response
    if(hasFatalErrorMessage) {

      /// Reset the fatal error message
      fatalErrorMessage = null;

    }

  }

  /// Request the API Home
  Future<dio.Response> setApiHome() async {

    /// Start the loader to indicate that we are making the Home API Request
    _startApiRequestLoader();

    /// Reset the fatal error message
    _resetFatalErrorMessage();

    /// Reset the failed response
    _resetFailedResponse();

    // Make the Api Call to the Api Home route
    return await apiProvider.setApiHome().then((response) async {

      //  Successful request to Api Home request
      if( response.statusCode == 200 ) {

        //  Determine if the user is authenticated
        isAuthenticated = apiProvider.apiHome!.authenticated;

        //  If the user is authenticated
        if( isAuthenticated ) {

          //  Get the Api Home
          final apiHome = apiProvider.apiHome!;

          //  Get the Authenticated User
          final User authUser = apiHome.user!;

          //  Set the authenticated user
          authProvider.setUser(authUser);

          //  Check if the user accepted their terms and conditions
          hasAcceptedTermsAndConditions = apiHome.acceptedTermsAndConditions;
    
          /// Set the Pusher Provider
          pusherProvider = Provider.of<PusherProvider>(context, listen: false);

          /// Update the Auth Provider on this Pusher Provider
          /// This is important so that we can authorize private or presence
          /// channels that require the authenticated user id and bearer token
          PusherProvider.setAuthProvider(pusherProvider!, authProvider);

          ///  Subcribe to login alerts by other devices
          _listenForExternalLoginAlerts();

          /**
           * OneSignal creates subscription-level records under a unique ID called the subscription_id. 
           * A single user can have multiple subscription_id records based on how many devices, email 
           * addresses, and phone numbers they use to interact with your app. If your app has its own
           * login system to track users, call login at any time to link all channels to a single
           * user. For more details, see Aliases & External ID.
           * 
           * If your app has its own login system to track users, call login at any time to link all 
           * channels to a single user. For more details, see Aliases & External ID.
           * 
           *  Learn more: https://documentation.onesignal.com/docs/flutter-sdk-setup#identify-users
           */
          await OneSignal.login(authUser.id.toString()).then((value) => null);

          /// Set the mobile number alias
          OneSignal.User.addAlias('mobileNumber', authUser.mobileNumber?.withoutExtension);

        }

      //  Failed request to Api Home request
      }else{

        /// Capture the failed response
        setState(() => failedResponse = response);

      }

      return response;

    }).onError((dio.DioException exception, stackTrace) {

      /// Capture the failed response
      setState(() => failedResponse = exception.response);

      /// Rethrow the exception
      throw exception;

    }).catchError((error) {

      printError(info: error.toString());

      fatalErrorMessage = error.toString();

      return error;

    }).whenComplete(() {

      /// Stop the loader to indicate that we are no longer making the Home API Request
      _stopApiRequestLoader();

    });

  }

  /// Loader
  Widget get loader {
    return const Scaffold(
      body: CustomCircularProgressIndicator(),
    );
  }

  @override
  Widget build(BuildContext context) {
    
    /// Set this listener on the ApiProvider so that we are notified of any changes 
    /// on the ApiProvider state. Any changes will fire the didChangeDependencies()
    /// method which allows us to run our startSetup() method. This is important if
    /// the ApiProvider setBearerTokenFromResponse() method is executed and thereby
    /// setting the bearer token and notifying listeners. We then can run the 
    /// startSetup() method knowing that this time the setApiHome() request
    /// will be executed with the bearer token as part of the request 
    /// headers. This will return the Api Home intial routes as well 
    /// as the current authenticated user. This information will
    /// help us update the Auth Provider on the Pusher Provider
    /// so that we can authorize private or presence channels 
    /// that require the authenticated user id and bearer 
    /// token. Refer to the setApiHome() method.
    Provider.of<ApiProvider>(context);

    /// Check if we are currently loading
    if(isCheckingHasSeenIntro || isCheckingInternetConnectivity || isLoadingApiRequest) {

      /// Show the loader
      return loader;

    }else{

      //  Initialize the page
      Widget page;

      /// Check if the internet is disconnected
      if(isDisconnected) {

        //  Show the no internet page
        page = NoInternetPage(
          onTryAgain: setApiHome
        );

      /// Check if the API Call failed
      }else if(hasFailedResponse) {

        //  Show the request failed page
        page = RequestFailedPage(
          onTryAgain: setApiHome,
          failedResponse: failedResponse!
        );

      /// Check if we have a fatal error
      }else if(hasFatalErrorMessage) {

        //  Show the request failed page
        page = SomethingWentWrongPage(
          onTryAgain: setApiHome,
          fatalErrorMessage: fatalErrorMessage!
        );

      /// Check if the user has not seen the app introduction page
      }else if(hasNotSeenIntro) {

        //  Show the introduction role selection page
        page = const IntroductionRoleSelectionPage();

      /// Check if the user is not authenticated
      }else if(isNotAuthenticated) {
      
        //  Show the signin page
        page = const SigninPage();

      /// Check if the user has not accepted the terms and conditions
      }else if(hasNotAcceptedTermsAndConditions) {

        //  Show the terms and conditions page
        page = const TermsAndConditionsPage();

      }else{

        //  Show the application home page
        page = const HomePage();

      }

      return page;

    }

  }

}