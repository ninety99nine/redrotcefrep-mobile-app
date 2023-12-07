import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'dart:async';

class InternetConnectivityUtility {

  bool hasConnection = false;
  bool isCheckingInternetConnectivity = false;
  StreamSubscription<InternetConnectionStatus>? internetConnectionCheckerListener;

  /// Check and update the internet connectivity status
  Future<bool> checkAndUpdateInternetConnectivityStatus({ required Function setState }) async {

    /// Start the loader to indicate that we are checking the internet connectivity status
    setState(() => isCheckingInternetConnectivity = true);

    /// Check and update the internet connection status
    hasConnection = await InternetConnectionCheckerPlus().hasConnection;

    /// Stop the loader to indicate that we are no longer checking the internet connectivity status
    setState(() => isCheckingInternetConnectivity = false);

    /// Return the current internet connection status
    return hasConnection;

  }

  /// Setup the internet connectivity listener
  void setupInternetConnectivityListener({ required Function setState, Function? onConnected, Function? onDisconnected }) {

    /// Listen for changes on the internet connectivity status
    internetConnectionCheckerListener = InternetConnectionCheckerPlus().onStatusChange.listen((InternetConnectionStatus status) {

      /// Continue only if the internet connectivity loader is inactive
      if(isCheckingInternetConnectivity == false) {

        /// If the status has changed to "connected"
        if(hasConnection == false && status == InternetConnectionStatus.connected) {

          /// Update the internet connection status
          setState(() => hasConnection = true);

          // Fire the onConnected method if present
          if(onConnected != null) onConnected();

        /// If the status has changed to "disconnected"
        }else if(hasConnection == true && status == InternetConnectionStatus.disconnected) {

          /// Update the internet connection status
          setState(() => hasConnection = false);

          // Fire the onDisconnected method if present
          if(onDisconnected != null) onDisconnected();

        }

      }

    });

  }

  void dispose() {

    /// Cancel the internet connectivity listener
    if(internetConnectionCheckerListener != null) internetConnectionCheckerListener!.cancel();

  }

}