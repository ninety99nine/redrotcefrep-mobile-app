import 'package:flutter/material.dart';

class AppTheme {
  
  static ThemeData lightTheme() {

    return ThemeData(
      //  primarySwatch: Colors.blue,
      //  primarySwatch: Colors.indigo,
      primaryColor: Colors.blue.shade800,
      
      splashColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade100,
      textTheme: ThemeData.light().textTheme.copyWith(

        //  Text title themes
        titleLarge: const TextStyle(fontWeight: FontWeight.bold),
        titleMedium: const TextStyle(fontWeight: FontWeight.bold),
        titleSmall: const TextStyle(fontWeight: FontWeight.bold),

      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        splashColor: Colors.white.withOpacity(0.5),
        backgroundColor: Colors.green.shade500,
        extendedTextStyle: const TextStyle(fontWeight: FontWeight.bold)
      ),
      
    );
    
  }

}