class StringUtility {

  /// Capitalise the first letter of a string
  static String capitalize(String string) => string[0].toUpperCase() + string.substring(1);

  /// Remove line breaks from a string
  static String removeLineBreaks(String string) => string.replaceAll("\n", " ");

  /// Removes characters that are not digits from a string
  static String removeNonDigits(String string) => string.replaceAll(RegExp(r"\D"), "");

}