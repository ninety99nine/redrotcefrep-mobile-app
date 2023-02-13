import 'package:flutter/material.dart';
import 'dart:async';

class DebouncerUtility {
  final int milliseconds;
  Timer? _timer;

  DebouncerUtility({this.milliseconds = 500});

  run(VoidCallback action) {
    cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  cancel() {
    if(_timer != null) _timer!.cancel();
  }
}