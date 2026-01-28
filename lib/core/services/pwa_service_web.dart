import 'dart:html' as html;
import 'package:flutter/material.dart';

dynamic _deferredPrompt;
bool _canInstall = false;
bool _isIOS = false;
VoidCallback? _onStateChanged;

void initPWA(BuildContext context, VoidCallback onStateChanged) {
  _onStateChanged = onStateChanged;

  // Delay slightly to ensure window and navigator are fully settled
  Future.delayed(const Duration(seconds: 1), () {
    _checkPWAStatus();
  });
}

void _checkPWAStatus() {
  // Detect iOS
  final userAgent = html.window.navigator.userAgent.toLowerCase();

  bool standardIOS = userAgent.contains('iphone') ||
      userAgent.contains('ipad') ||
      userAgent.contains('ipod');

  bool modernIPad = userAgent.contains('macintosh') &&
      (html.window.navigator.maxTouchPoints ?? 0) > 0;

  _isIOS = standardIOS || modernIPad;

  final isStandalone =
      html.window.matchMedia('(display-mode: standalone)').matches ||
          (html.window.navigator as dynamic).standalone == true;

  if (_isIOS && !isStandalone) {
    _canInstall = true;
    _onStateChanged?.call();
    print('PWA: iOS detected, can install.');
  }

  html.window.addEventListener('beforeinstallprompt', (event) {
    event.preventDefault();
    _deferredPrompt = event;
    _canInstall = true;
    _onStateChanged?.call();
    print('PWA: beforeinstallprompt event caught.');
  });

  html.window.addEventListener('appinstalled', (event) {
    _deferredPrompt = null;
    _canInstall = false;
    _onStateChanged?.call();
    print('PWA: App installed.');
  });
}

void showInstallPrompt() {
  if (_deferredPrompt != null) {
    _deferredPrompt.prompt();
    _deferredPrompt.userChoice.then((choiceResult) {
      if (choiceResult['outcome'] == 'accepted') {
        _canInstall = false;
        _onStateChanged?.call();
      }
      _deferredPrompt = null;
    });
  }
}

bool get canInstall => _canInstall;
bool get isIOS => _isIOS;
