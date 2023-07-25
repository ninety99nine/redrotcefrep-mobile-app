import 'dart:convert';

import 'package:bonako_demo/core/utils/pusher.dart';
import 'package:bonako_demo/core/utils/snackbar.dart';
import 'package:get/get.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

import '../../../core/shared_widgets/Loader/custom_circular_progress_indicator.dart';
import '../../authentication/widgets/terms_and_conditions_page.dart';
import '../../authentication/providers/auth_provider.dart';
import '../../../core/exceptions/request_failed_page.dart';
import '../../authentication/widgets/signin_page.dart';
import '../services/introduction_service.dart';
import '../../api/providers/api_provider.dart';
import 'introduction_role_selection_page.dart';
import '../../home/widgets/home_page.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class LandingPage extends StatefulWidget {

  static const routeName = 'LandingPage';
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {

  bool isLoading = false;
  String errorMessage = '';
  bool hasSeenIntro = false;
  bool isAuthenticated = false;
  PusherChannelsFlutter? pusher;
  bool homeApiRequestFailed = false;
  late PusherProvider pusherProvider;
  bool hasAcceptedTermsAndConditions = false;
  final IntroductionService introductionServices = IntroductionService();

  void _startLoader() => setState(() => isLoading = true);
  void _stopLoader() => setState(() => isLoading = false);
  void _handleHomeApiRequestFailed() => homeApiRequestFailed = true;
  
  ApiProvider get apiProvider => Provider.of<ApiProvider>(context, listen: false);
  AuthProvider get authProvider => Provider.of<AuthProvider>(context, listen: false);

  @override
  void initState() {
    super.initState();
    
    /// Set the Pusher Provider
    pusherProvider = Provider.of<PusherProvider>(context, listen: false);
  }

  @override
  void dispose() {
    super.dispose();
    /// Unsubscribe from this specified event on this channel
    pusherProvider.unsubscribeToAuthLogin(identifier: 'LandingPage');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    startSetup();
  }

  void startSetup() async {

    _startLoader();

    //  Clear the device storage
    //  await SharedPreferences.getInstance().then((prefs) => prefs.clear());
  
    //  Check if the user has seen any introduction page
    hasSeenIntro = await introductionServices.checkIfHasSeenAnyIntroFromDeviceStorage();

    //  Set the Api Home
    await apiProvider.setApiHome().then((response) async {

      errorMessage += '\n\nStatus Code: ${response.statusCode}';

      //  Successful request to Api Home request
      if( response.statusCode == 200 ) {

        //  Determine if the request acquired an authenticated user
        isAuthenticated = apiProvider.apiHome!.authenticated;

        //  If the request acquired an authenticated user
        if( isAuthenticated ) {

          //  Get the Api Home
          final apiHome = apiProvider.apiHome!;

          //  Set the authenticated user
          authProvider.setUser(apiHome.user!);

          //  Check if the user accepted their terms and conditions
          hasAcceptedTermsAndConditions = apiHome.acceptedTermsAndConditions;

          //  Subcribe to login by other devices
          listenToExternalLoginAlerts();

        }

      //  Failed request to Api Home request
      }else{

        /// Get the response body
        final responseBody = jsonDecode(response.body);

        /// If the response body contains a server message
        if(responseBody.containsKey('message')) {
          
          errorMessage = responseBody['message'];

        /// If the response body contains an server error
        }else if(responseBody.containsKey('error')) {
          
          errorMessage = responseBody['error'];

        }

        _handleHomeApiRequestFailed();

      }

    }).catchError((error) {

      errorMessage = error.toString();

      _handleHomeApiRequestFailed();

    }).whenComplete(() {

      _stopLoader();

    });
  }

  void onTryAgain() {
    homeApiRequestFailed = false;
    startSetup();
  }

  void listenToExternalLoginAlerts() async {

    /// Subscribe to login alerts
    pusherProvider.subscribeToAuthLogin(
      identifier: 'LandingPage', 
      onEvent: onLoginAlerts
    );

  }

  void onLoginAlerts(event) {

    print('onLoginAlerts');
    print(event);
    print(event.eventName);

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

        /// Unsubscribe from this channel
        pusher!.unsubscribe(channelName: 'private-login.${authProvider.userId}');

        /// Reload
        startSetup();

      }
    }

  }

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
    /// as the current authenticated user.
    Provider.of<ApiProvider>(context);

    //  Set the landing page
    Widget page;

    //  If the Home Api request failed
    if(homeApiRequestFailed) {

      //  Show the request failed page
      page = RequestFailedPage(
        onTryAgain: onTryAgain,
        errorMessage: errorMessage
      );

    //  If the user has not seen the introduction page
    }else if(!hasSeenIntro) {

      //  Show the introduction role selection page
      page = const IntroductionRoleSelectionPage();

    //  If the user is not authenticated
    }else if(!isAuthenticated) {
      
      //  Show the signin page
      page = const SigninPage();

    //  If the authenticated user has not accepted terms and conditions
    }else if(!hasAcceptedTermsAndConditions) {

      //  Show the terms and conditions page
      page = const TermsAndConditionsPage();

    }else{

      //  Show the application home page
      page = const HomePage();

    }

    return isLoading ? loader : page;

  }

}