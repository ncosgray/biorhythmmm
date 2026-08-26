// Biorhythmmm
// - Localization tests: language files, locale resolution, translations

import 'package:biorhythmmm/data/biorhythm.dart';
import 'package:biorhythmmm/data/localization.dart';

import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> loadLanguageFile(String languageCode) {
  final File file = File('langs/$languageCode.json');
  return json.decode(file.readAsStringSync()) as Map<String, dynamic>;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('language files', () {
    test('every supported locale has a language file', () {
      for (final String code in supportedLanguageCodes) {
        expect(
          File('langs/$code.json').existsSync(),
          isTrue,
          reason: 'missing langs/$code.json',
        );
      }
    });

    test('English file defines every AppString key', () {
      final Map<String, dynamic> en = loadLanguageFile('en');
      for (final AppString string in AppString.values) {
        expect(
          en[string.key],
          isA<String>().having((s) => s.isNotEmpty, 'non-empty', isTrue),
          reason: 'en.json missing or empty: ${string.key}',
        );
      }
    });

    test('translated files contain no unknown keys', () {
      final Set<String> knownKeys = AppString.values.map((s) => s.key).toSet();
      for (final String code in supportedLanguageCodes) {
        final Map<String, dynamic> lang = loadLanguageFile(code);
        for (final String key in lang.keys) {
          expect(
            knownKeys,
            contains(key),
            reason: '$code.json has unused key: $key',
          );
        }
      }
    });

    test('translated values are non-empty strings', () {
      for (final String code in supportedLanguageCodes) {
        loadLanguageFile(code).forEach((key, value) {
          expect(
            value,
            isA<String>().having((s) => s.isNotEmpty, 'non-empty', isTrue),
            reason: '$code.json has empty value for $key',
          );
        });
      }
    });

    test('placeholders in translations match the English source', () {
      final RegExp placeholder = RegExp(r'\{\{\w+\}\}');
      final Map<String, dynamic> en = loadLanguageFile('en');
      for (final String code in supportedLanguageCodes) {
        loadLanguageFile(code).forEach((key, value) {
          final Set<String> enPlaceholders = placeholder
              .allMatches(en[key].toString())
              .map((m) => m.group(0)!)
              .toSet();
          final Set<String> langPlaceholders = placeholder
              .allMatches(value.toString())
              .map((m) => m.group(0)!)
              .toSet();
          expect(
            langPlaceholders,
            enPlaceholders,
            reason: '$code.json placeholder mismatch for $key',
          );
        });
      }
    });
  });

  group('translation loading', () {
    test(
      'translate returns localized strings for each supported locale',
      () async {
        for (final Locale locale in supportedLocales) {
          await const AppLocalizationsDelegate().load(locale);
          final Map<String, dynamic> lang = loadLanguageFile(
            locale.languageCode,
          );
          final Map<String, dynamic> en = loadLanguageFile('en');

          for (final AppString string in AppString.values) {
            final String expected = (lang[string.key] ?? en[string.key])
                .toString();
            expect(
              AppLocalizations.translate(string.key),
              expected,
              reason: '${locale.languageCode}: ${string.key}',
            );
          }
        }
      },
    );

    test('missing keys fall back to English', () async {
      // Verify the fallback path works for every non-English locale by
      // translating all keys without errors (some may be untranslated)
      for (final Locale locale in supportedLocales) {
        await const AppLocalizationsDelegate().load(locale);
        for (final AppString string in AppString.values) {
          expect(string.translate(), isNotEmpty);
        }
      }
    });

    test('biorhythm names are localized', () async {
      for (final Locale locale in supportedLocales) {
        await const AppLocalizationsDelegate().load(locale);
        final Map<String, dynamic> lang = loadLanguageFile(locale.languageCode);
        final Map<String, dynamic> en = loadLanguageFile('en');
        expect(
          Biorhythm.intellectual.localizedName,
          (lang['biorhythmIntellectual'] ?? en['biorhythmIntellectual'])
              .toString(),
          reason: locale.languageCode,
        );
      }
    });

    test('translate applies substitutions', () async {
      await const AppLocalizationsDelegate().load(defaultLocale);
      expect(
        AppString.notifyTitleName.translate(name: 'Alice'),
        'Biorhythms for Alice',
      );
      expect(
        AppString.aboutBiorhythmDays.translate(biorhythm: 'Physical', days: 23),
        '• Physical (23 days)',
      );
      expect(AppString.zoomWeeks.translate(weeks: 4), '4 weeks');
      expect(AppString.aboutApp.translate(), contains(appName));
    });
  });

  group('locale string parsing', () {
    test('localeString flattens locale subtags', () {
      expect(localeString(const Locale('en')), 'en');
      expect(localeString(const Locale('pt', 'BR')), 'pt_BR');
      expect(
        localeString(
          const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
        ),
        'zh_Hant',
      );
    });

    test('parseLocaleString round-trips', () {
      for (final String name in ['en', 'pt_BR', 'zh_Hant']) {
        expect(localeString(parseLocaleString(name)), name);
      }
    });
  });

  group('locale resolution', () {
    test('exact match resolves to the device locale', () {
      expect(
        localeResolutionCallback(const Locale('de'), supportedLocales),
        const Locale('de'),
      );
    });

    test('language match ignores country code', () {
      expect(
        localeResolutionCallback(const Locale('de', 'AT'), supportedLocales),
        const Locale('de'),
      );
      expect(
        localeResolutionCallback(const Locale('zh', 'TW'), supportedLocales),
        const Locale('zh'),
      );
    });

    test('unsupported locale falls back to default', () {
      expect(
        localeResolutionCallback(const Locale('ko'), supportedLocales),
        defaultLocale,
      );
    });

    test('null device locale falls back to default', () {
      expect(localeResolutionCallback(null, supportedLocales), defaultLocale);
    });
  });
}
