part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const login = _Paths.login;
  static const splash = _Paths.splash;
  static const home = _Paths.home;
  static const draw = _Paths.draw;
  static const community = _Paths.community;
  static const layout = _Paths.layout;
  static const profile = _Paths.profile;
  static const watch = _Paths.watch;
  static const view = _Paths.view;
  static const dashboard = _Paths.dashboard;
  static const portfolio = _Paths.portfolio;
  static const marketplace = _Paths.marketplace;
  static const settings = _Paths.settings;
  static const challenge = _Paths.challenge;
  static const studioUpgrade = _Paths.studioUpgrade;
  static const messaging = _Paths.messaging;
  static const chat = _Paths.chat;
  static const search = _Paths.search;
  static const notifications = _Paths.notifications;
  static const wallet = _Paths.wallet;
  static const visionaryHall = _Paths.visionaryHall;
}

abstract class _Paths {
  _Paths._();
  static const login = '/login';
  static const splash = '/splash';
  static const home = '/home';
  static const draw = '/draw';
  static const community = '/community';
  static const layout = '/layout';
  static const profile = '/profile';
  static const watch = '/watch';
  static const view = '/view';
  static const dashboard = '/dashboard';
  static const portfolio = '/portfolio';
  static const marketplace = '/marketplace';
  static const settings = '/settings';
  static const challenge = '/challenge';
  static const studioUpgrade = '/studio-upgrade';
  static const messaging = '/messaging';
  static const chat = '/chat/:id';
  static const search = '/search';
  static const notifications = '/notifications';
  static const wallet = '/wallet';
  static const visionaryHall = '/visionary-hall';
}
