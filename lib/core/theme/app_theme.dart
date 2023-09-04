import 'package:flutter/material.dart';

class AppTheme {
  
  static ThemeData lightTheme() {

    return ThemeData(

      fontFamily: 'OpenSans',
      
      //  primarySwatch: Colors.blue,
      //  primarySwatch: Colors.indigo,
      primaryColor: Colors.black,

      splashColor: Colors.black,
      highlightColor: Colors.yellow.shade100,
      textTheme: ThemeData.light().textTheme.copyWith(

        //  Text title themes
        titleLarge: const TextStyle(fontWeight: FontWeight.bold),
        titleMedium: const TextStyle(fontWeight: FontWeight.bold),
        titleSmall: const TextStyle(fontWeight: FontWeight.bold),

      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        foregroundColor: Colors.white,
        backgroundColor: Colors.yellow.shade800,  /// Colors.redAccent
        extendedTextStyle: const TextStyle(fontWeight: FontWeight.bold)
      ),
      
    );
    
  }

}