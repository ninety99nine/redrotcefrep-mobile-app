import '../constants/constants.dart' as constants;
import 'string.dart';

enum MobileNetworkName {
  orange,
  mascom,
  btc
}

class MobileNumberUtility {

  /// Get the mobile network by name
  /// Reference: https://en.wikipedia.org/wiki/Telephone_numbers_in_Botswana
  static MobileNetworkName? getMobileNetworkName(String mobileNumber) {

    mobileNumber = simplify(mobileNumber);

    if(int.tryParse(mobileNumber) == null) return null;

    int number = int.parse(mobileNumber);
    
    bool isMascomRange = 
      (number >= 71000000 && number <= 71999999) ||
      (number >= 74000000 && number <= 74299999) ||
      (number >= 74500000 && number <= 74799999) ||
      (number >= 75400000 && number <= 75699999) ||
      (number >= 75900000 && number <= 75999999) ||
      (number >= 76000000 && number <= 76299999) ||
      (number >= 76600000 && number <= 76799999) ||
      (number >= 77000000 && number <= 77199999) ||
      (number >= 77600000 && number <= 77799999) ||
      (number >= 77800000 && number <= 77899999);

    bool isOrangeRange = 
      (number >= 72000000 && number <= 72999999) ||
      (number >= 74300000 && number <= 74499999) ||
      (number >= 74800000 && number <= 74899999) ||
      (number >= 75000000 && number <= 75399999) ||
      (number >= 75700000 && number <= 75799999) ||
      (number >= 76300000 && number <= 76599999) ||
      (number >= 76900000 && number <= 76999999) ||
      (number >= 77400000 && number <= 77599999) ||
      (number >= 77900000 && number <= 77999999) ||
      (number >= 77300000 && number <= 77399999);

    bool isBtcRange = 
      (number >= 73000000 && number <= 73999999) ||
      (number >= 74900000 && number <= 74999999) ||
      (number >= 75800000 && number <= 75899999) ||
      (number >= 76800000 && number <= 76899999) ||
      (number >= 77200000 && number <= 77200999);

    if(isMascomRange) {

      return MobileNetworkName.mascom;

    }else if(isOrangeRange) {

      return MobileNetworkName.orange;

    }else if(isBtcRange) {

      return MobileNetworkName.btc;

    }else{

      return null;

    }

  }

  /// Removes mobile number extension and characters that are not digits
  static String simplify(String mobileNumber) {
    mobileNumber = StringUtility.removeNonDigits(mobileNumber);
    return removeMobileNumberExtension(mobileNumber);
  }

  /// Adds the mobile number extension
  static String addMobileNumberExtension(String mobileNumber) {
    mobileNumber = simplify(mobileNumber);
    return '${constants.mobileNumberExtension}$mobileNumber';
  }

  /// Removes characters that match the mobile number extension
  static String removeMobileNumberExtension(String mobileNumber) {
    return mobileNumber.replaceAll(RegExp('^${constants.mobileNumberExtension}'), '');
  }

  /// Check if the mobile number is valid
  static bool isValidMobileNumber(String mobileNumber) {
    return getMobileNetworkName(mobileNumber) != null;
  }

  /// Check if the Orange mobile number is valid
  static bool isValidOrangeMobileNumber(String mobileNumber) {
    return getMobileNetworkName(mobileNumber) == MobileNetworkName.orange;
  }

  /// Check if the Mascom mobile number is valid
  static bool isValidMascomMobileNumber(String mobileNumber) {
    return getMobileNetworkName(mobileNumber) == MobileNetworkName.mascom;
  }

  /// Check if the Btc mobile number is valid
  static bool isValidBtcMobileNumber(String mobileNumber) {
    return getMobileNetworkName(mobileNumber) == MobileNetworkName.btc;
  }
}
