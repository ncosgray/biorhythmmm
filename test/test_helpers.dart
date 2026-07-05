// Biorhythmmm
// - Shared test setup helpers

import 'package:biorhythmmm/data/localization.dart';
import 'package:biorhythmmm/data/prefs.dart';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// Fake notifications platform to stand in for flutter_local_notifications,
// which cannot run in unit tests (no host platform implementation). Extends
// the Android implementation because flutter_test reports TargetPlatform
// .android, so the plugin routes calls to the Android-specific API.
class FakeNotificationsPlatform extends AndroidFlutterLocalNotificationsPlugin {
  final List<String> calls = [];

  @override
  Future<bool?> requestNotificationsPermission() async {
    calls.add('requestNotificationsPermission');
    return true;
  }

  @override
  Future<void> zonedSchedule({
    required int id,
    String? title,
    String? body,
    required tz.TZDateTime scheduledDate,
    AndroidNotificationDetails? notificationDetails,
    AndroidScheduleMode? scheduleMode,
    String? payload,
    DateTimeComponents? matchDateTimeComponents,
  }) async => calls.add('zonedSchedule');

  @override
  Future<void> cancel({required int id, String? tag}) async =>
      calls.add('cancel');

  @override
  Future<void> cancelAll() async => calls.add('cancelAll');

  @override
  Future<void> cancelAllPendingNotifications() async =>
      calls.add('cancelAllPendingNotifications');

  @override
  Future<List<PendingNotificationRequest>>
  pendingNotificationRequests() async => [];

  @override
  Future<NotificationAppLaunchDetails?>
  getNotificationAppLaunchDetails() async => null;
}

// Set up a test environment: time zone, locale, in-memory preferences,
// fake notifications, and loaded (English) localizations
Future<FakeNotificationsPlatform> initTestEnvironment({
  Map<String, Object> prefs = const {},
  Map<String, Object> legacyPrefs = const {},
  String timeZone = 'America/Chicago',
}) async {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Drop asset futures cached in a previous test's async zone: their
  // completion callbacks would be scheduled on that dead zone and deadlock
  // any test that awaits them
  rootBundle.clear();

  // Time zone setup normally done in initApp
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation(timeZone));

  // Deterministic date formatting
  Intl.defaultLocale = 'en_US';

  // Replace the notifications plugin with a fake
  final FakeNotificationsPlatform fakeNotifications =
      FakeNotificationsPlatform();
  FlutterLocalNotificationsPlatform.instance = fakeNotifications;

  // Back shared preferences with fresh in-memory stores
  SharedPreferencesAsyncPlatform.instance = prefs.isEmpty
      ? InMemorySharedPreferencesAsync.empty()
      : InMemorySharedPreferencesAsync.withData(prefs);
  SharedPreferences.setMockInitialValues(legacyPrefs);
  await Prefs.init();

  // Load default (English) localizations
  await const AppLocalizationsDelegate().load(defaultLocale);

  return fakeNotifications;
}
