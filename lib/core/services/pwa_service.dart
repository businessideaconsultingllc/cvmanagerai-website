import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pwa_service_stub.dart' if (dart.library.html) 'pwa_service_web.dart'
    as impl;

final pwaServiceProvider = ChangeNotifierProvider((ref) => PWAService());

class PWAService extends ChangeNotifier {
  void init(BuildContext context) {
    impl.initPWA(context, () {
      notifyListeners();
    });
  }

  void showInstallPrompt() {
    impl.showInstallPrompt();
    notifyListeners();
  }

  bool get canInstall => impl.canInstall;
  bool get isIOS => impl.isIOS;
}
