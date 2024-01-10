import 'package:intl/intl.dart';

class StringUtility {

  /// Capitalise the first letter of a string
  static String capitalize(String string) => string[0].toUpperCase() + string.substring(1);

  /// Remove line breaks from a string
  static String removeLineBreaks(String string) => string.replaceAll("\n", " ");

  /// Removes characters that are not digits from a string
  static String removeNonDigits(String string) => string.replaceAll(RegExp(r"\D"), "");

  /// Convert a number to a shortened prefix
  static String convertNumberToShortenedPrefix(int number) {
    
    String input = NumberFormat('#,###').format(number);
    int inputCount = input.split(',').length - 1;

    if (inputCount != 0) {
      if (inputCount == 1) {
        return '${input.substring(0, input.length - 4)}k';
      } else if (inputCount == 2) {
        return '${input.substring(0, input.length - 8)}m';
      } else if (inputCount == 3) {
        return '${input.substring(0, input.length - 12)}b';
      } else {
        return '';
      }
    } else {
      return input;
    }
  }
}