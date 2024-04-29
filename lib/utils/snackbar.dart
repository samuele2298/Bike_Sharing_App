import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

enum ABC {
  a,
  b,
  c,
}

class Snackbar {
  static final snackBarKeyBlueOffScreen = GlobalKey<ScaffoldMessengerState>();
  static final snackBarKeyBatteryPairing = GlobalKey<ScaffoldMessengerState>();
  static final snackBarKeyModifyBattery = GlobalKey<ScaffoldMessengerState>();

  static GlobalKey<ScaffoldMessengerState> getSnackbar(ABC abcd) {
    switch (abcd) {
      case ABC.a:
        return snackBarKeyBlueOffScreen;
      case ABC.b:
        return snackBarKeyBatteryPairing;
      case ABC.c:
        return snackBarKeyModifyBattery;

    }
  }

  static show(ABC abc, String msg, {required bool success}) {
    final snackBar = success
        ? SnackBar(content: Text(msg), backgroundColor: Colors.blue)
        : SnackBar(content: Text(msg), backgroundColor: Colors.red);
    getSnackbar(abc).currentState?.removeCurrentSnackBar();
    getSnackbar(abc).currentState?.showSnackBar(snackBar);
  }
}


String prettyException(String prefix, dynamic e) {
  if (e is FlutterBluePlusException) {
    return "$prefix ${e.description}";
  } else if (e is PlatformException) {
    return "$prefix ${e.message}";
  }
  return prefix + e.toString();
}
