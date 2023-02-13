import 'package:shared_preferences/shared_preferences.dart';

class IntroductionService {

  /// Checks if the user has seen the seller introduction slides page
  Future<bool> checkIfHasSeenSellerIntroFromDeviceStorage() async {
    
    return await SharedPreferences.getInstance().then((prefs) {

      return prefs.getBool('hasSeenSellerIntro') ?? false;

    });

  }

  /// Checks if the user has seen the buyer introduction slides page
  Future<bool> checkIfHasSeenBuyerIntroFromDeviceStorage() async {
    
    return await SharedPreferences.getInstance().then((prefs) {

      return prefs.getBool('hasSeenBuyerIntro') ?? false;

    });

  }

  /// Checks if the user has seen either the seller introduction
  /// slides page or the buyer introduction slides page
  Future<bool> checkIfHasSeenAnyIntroFromDeviceStorage() async {
    
    return await checkIfHasSeenSellerIntroFromDeviceStorage().then((hasSeenSellerIntro) async {

      if( hasSeenSellerIntro ) return hasSeenSellerIntro;

      return await checkIfHasSeenBuyerIntroFromDeviceStorage().then((hasSeenBuyerIntro) {

        return hasSeenBuyerIntro;

      });

    });

  }

  /// Checks if the user has seen both the seller introduction
  /// slides page or the buyer introduction slides page
  Future<bool> checkIfHasSeenEveryIntroFromDeviceStorage() async {
    
    return await checkIfHasSeenSellerIntroFromDeviceStorage().then((hasSeenSellerIntro) async {

      return await checkIfHasSeenBuyerIntroFromDeviceStorage().then((hasSeenBuyerIntro) {

        return hasSeenSellerIntro == true && hasSeenBuyerIntro == true;

      });

    });

  }

  /// Save an indication of whether the user has seen the seller introduction slides page
  saveHasSeenSellerIntroOnDeviceStorage(bool status) {
    
    //  Save changes on local storage
    SharedPreferences.getInstance().then((prefs) {

      prefs.setBool('hasSeenSellerIntro', status);

    });

  }

  /// Save an indication of whether the user has seen the buyer introduction slides page
  saveHasSeenBuyerIntroOnDeviceStorage(bool status) {
    
    //  Save changes on local storage
    SharedPreferences.getInstance().then((prefs) {

      prefs.setBool('hasSeenBuyerIntro', status);

    });

  }

}