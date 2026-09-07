// Biorhythmmm
// - Widget tests: home page across locales and screen sizes, settings sheet

import 'package:biorhythmmm/common/notifications.dart' show NotificationType;
import 'package:biorhythmmm/common/themes.dart';
import 'package:biorhythmmm/data/app_state.dart';
import 'package:biorhythmmm/data/biorhythm.dart';
import 'package:biorhythmmm/data/localization.dart';
import 'package:biorhythmmm/data/prefs.dart';
import 'package:biorhythmmm/widgets/home_page.dart';

import 'dart:convert';
import 'dart:io';

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:fl_chart/fl_chart.dart' show LineChart;
import 'package:flutter/foundation.dart' show FlutterExceptionHandler;
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart' as fl;
import 'package:flutter_test/flutter_test.dart';

import 'test_helpers.dart';

// Build the app the same way main.dart does, with an optional forced locale
Widget buildTestApp({Locale? locale}) => BlocProvider<AppStateCubit>(
  create: (_) => AppStateCubit(),
  child: MaterialApp(
    home: const HomePage(),
    title: appName,
    theme: lightTheme,
    darkTheme: darkTheme,
    locale: locale,
    supportedLocales: supportedLocales,
    localizationsDelegates: const [
      AppLocalizationsDelegate(),
      GlobalMaterialLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      fl.GlobalWidgetsLocalizations.delegate,
      FallbackMaterialLocalizationsDelegate(),
      FallbackCupertinoLocalizationsDelegate(),
    ],
    localeResolutionCallback: localeResolutionCallback,
  ),
);

// Initialize the test environment and pump the app.
// Note: initTestEnvironment must run inside the test body (not setUp) so
// that async asset loading completes within the test's fake async zone.
Future<void> pumpTestApp(WidgetTester tester, {Locale? locale}) async {
  await initTestEnvironment();
  // Set a birthday so the home page doesn't prompt for one
  Prefs.birthdays = [
    BirthdayEntry(name: 'Me', date: DateTime(1990, 6, 15), notify: true),
  ];
  await tester.pumpWidget(buildTestApp(locale: locale));
  await tester.pumpAndSettle();
}

// Read a language file from disk
Map<String, dynamic> loadLanguageFile(String languageCode) =>
    json.decode(File('langs/$languageCode.json').readAsStringSync())
        as Map<String, dynamic>;

// Screen dimensions to test (logical pixels)
const Map<String, Size> screenSizes = {
  'small phone': Size(320, 568),
  'phone': Size(390, 844),
  'tablet': Size(1024, 1366),
};

void main() {
  group('home page renders in every supported language', () {
    for (final Locale locale in supportedLocales) {
      testWidgets('locale ${locale.languageCode}', (WidgetTester tester) async {
        await pumpTestApp(tester, locale: locale);

        final Map<String, dynamic> en = loadLanguageFile('en');
        final Map<String, dynamic> lang = loadLanguageFile(locale.languageCode);

        // App bar shows the localized chart title
        final String chartTitle = (lang['chartTitle'] ?? en['chartTitle'])
            .toString();
        expect(find.text(chartTitle), findsOneWidget);

        // Localized names of the primary biorhythms are displayed
        for (final Biorhythm b in primaryBiorhythms) {
          final String name =
              (lang['biorhythm${b.name}'] ?? en['biorhythm${b.name}'])
                  .toString();
          expect(
            find.textContaining(name),
            findsWidgets,
            reason: '${locale.languageCode}: $name',
          );
        }
      });
    }
  });

  group('home page renders at different screen sizes', () {
    for (final MapEntry<String, Size> screen in screenSizes.entries) {
      testWidgets(screen.key, (WidgetTester tester) async {
        tester.view.physicalSize = screen.value * 3;
        tester.view.devicePixelRatio = 3;
        addTearDown(tester.view.reset);

        // Ignore overflow errors: the Ahem test font is wider than
        // production fonts, so text overflows that can't happen on device
        final FlutterExceptionHandler? onError = FlutterError.onError;
        FlutterError.onError = (FlutterErrorDetails details) {
          if (!details.exception.toString().contains('overflowed')) {
            onError?.call(details);
          }
        };
        addTearDown(() => FlutterError.onError = onError);

        await pumpTestApp(tester);

        expect(find.text('Today’s Biorhythms'), findsOneWidget);
      });
    }
  });

  group('home page does not overflow at larger font scales', () {
    // The percent tiles have a fixed height, so taller-than-expected text
    // (font upgrades, device font scale settings) must scale down instead of
    // overflowing the bottom. Regression test for a "BOTTOM OVERFLOWED BY
    // 1.2 PIXELS" banner seen in Android screenshots, which reproduces with
    // real Roboto metrics at scale 1.3 (the FlutterTest font is too wide to
    // trigger it, so load the production font)
    for (final double scale in [1.0, 1.3, 1.5]) {
      testWidgets('font scale $scale', (WidgetTester tester) async {
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

        await loadRobotoFonts();
        await pumpTestApp(tester);

        expect(find.textContaining('%'), findsWidgets);
      });
    }
  });

  group('settings sheet', () {
    Future<void> openSettings(WidgetTester tester) async {
      await pumpTestApp(tester);
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
    }

    testWidgets('shows a checkbox for each biorhythm', (
      WidgetTester tester,
    ) async {
      await openSettings(tester);

      expect(find.text('Settings'), findsOneWidget);
      expect(
        find.byType(CheckboxListTile),
        findsNWidgets(allBiorhythms.length),
      );
    });

    testWidgets('selecting a biorhythm updates preferences', (
      WidgetTester tester,
    ) async {
      await openSettings(tester);

      await tester.tap(find.text('Intuition'));
      await tester.pumpAndSettle();
      expect(Prefs.biorhythms, contains(Biorhythm.intuition));

      await tester.tap(find.text('Intuition'));
      await tester.pumpAndSettle();
      expect(Prefs.biorhythms, isNot(contains(Biorhythm.intuition)));
    });

    testWidgets('changing notification type reveals the time setting', (
      WidgetTester tester,
    ) async {
      await openSettings(tester);
      expect(find.text('Set notification time'), findsNothing);

      // Select daily notifications from the dropdown
      await tester.tap(find.byType(DropdownButton<NotificationType>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Every day').last);
      await tester.pumpAndSettle();

      expect(Prefs.notifications, NotificationType.daily);
      expect(find.text('Set notification time'), findsOneWidget);
    });

    testWidgets('toggling switches updates display preferences', (
      WidgetTester tester,
    ) async {
      await openSettings(tester);

      // Colorblind safe palette switch (off by default)
      final Finder paletteSwitch = find.byType(Switch).first;
      await tester.ensureVisible(paletteSwitch);
      await tester.tap(paletteSwitch);
      await tester.pumpAndSettle();
      expect(Prefs.useAccessibleColors, isTrue);

      // Critical zone switch (on by default)
      final Finder criticalSwitch = find.byType(Switch).last;
      await tester.ensureVisible(criticalSwitch);
      await tester.tap(criticalSwitch);
      await tester.pumpAndSettle();
      expect(Prefs.showCriticalZone, isFalse);
    });

    testWidgets('changing default zoom updates preferences', (
      WidgetTester tester,
    ) async {
      await openSettings(tester);

      // Zoom dropdown shows the default selection
      final Finder zoomDropdown = find.byType(DropdownButton<int>);
      await tester.ensureVisible(zoomDropdown);
      expect(find.text('Default zoom level'), findsOneWidget);
      expect(find.text('4 weeks'), findsOneWidget);

      // Select a different zoom level from the dropdown
      await tester.tap(zoomDropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text('8 weeks').last);
      await tester.pumpAndSettle();

      expect(Prefs.defaultZoom, ZoomLevel.large.days);
      expect(find.text('8 weeks'), findsOneWidget);

      // Returning to the home page shows the chart at the new zoom level
      await tester.tap(find.byType(CloseButton));
      await tester.pumpAndSettle();
      final LineChart chart = tester.widget<LineChart>(find.byType(LineChart));
      expect(chart.transformationConfig.maxScale, ZoomLevel.large.days + 2);
    });
  });
}
