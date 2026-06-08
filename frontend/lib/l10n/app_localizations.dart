import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tg.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('ru'),
    Locale('tg'),
  ];

  /// App-Name
  ///
  /// In de, this message translates to:
  /// **'TJ-Shipping'**
  String get appTitle;

  /// No description provided for @navLogin.
  ///
  /// In de, this message translates to:
  /// **'Anmelden'**
  String get navLogin;

  /// No description provided for @navRegister.
  ///
  /// In de, this message translates to:
  /// **'Registrieren'**
  String get navRegister;

  /// No description provided for @fieldEmail.
  ///
  /// In de, this message translates to:
  /// **'E-Mail'**
  String get fieldEmail;

  /// No description provided for @fieldPassword.
  ///
  /// In de, this message translates to:
  /// **'Passwort'**
  String get fieldPassword;

  /// No description provided for @fieldFirstName.
  ///
  /// In de, this message translates to:
  /// **'Vorname'**
  String get fieldFirstName;

  /// No description provided for @fieldLastName.
  ///
  /// In de, this message translates to:
  /// **'Nachname'**
  String get fieldLastName;

  /// No description provided for @loginButton.
  ///
  /// In de, this message translates to:
  /// **'Anmelden'**
  String get loginButton;

  /// No description provided for @registerButton.
  ///
  /// In de, this message translates to:
  /// **'Konto erstellen'**
  String get registerButton;

  /// No description provided for @noAccount.
  ///
  /// In de, this message translates to:
  /// **'Noch kein Konto? Registrieren'**
  String get noAccount;

  /// No description provided for @roleLabel.
  ///
  /// In de, this message translates to:
  /// **'Ich möchte …'**
  String get roleLabel;

  /// No description provided for @roleSender.
  ///
  /// In de, this message translates to:
  /// **'Pakete senden'**
  String get roleSender;

  /// No description provided for @roleTraveler.
  ///
  /// In de, this message translates to:
  /// **'Platz anbieten'**
  String get roleTraveler;

  /// No description provided for @roleBoth.
  ///
  /// In de, this message translates to:
  /// **'Beides'**
  String get roleBoth;

  /// No description provided for @homeWelcome.
  ///
  /// In de, this message translates to:
  /// **'Willkommen bei TJ-Shipping!'**
  String get homeWelcome;

  /// No description provided for @homeSearchTrips.
  ///
  /// In de, this message translates to:
  /// **'Trips suchen'**
  String get homeSearchTrips;

  /// No description provided for @homeMyBookings.
  ///
  /// In de, this message translates to:
  /// **'Meine Buchungen'**
  String get homeMyBookings;

  /// No description provided for @homeNotifications.
  ///
  /// In de, this message translates to:
  /// **'Benachrichtigungen'**
  String get homeNotifications;

  /// No description provided for @homeVerify.
  ///
  /// In de, this message translates to:
  /// **'Identität verifizieren'**
  String get homeVerify;

  /// No description provided for @logout.
  ///
  /// In de, this message translates to:
  /// **'Abmelden'**
  String get logout;

  /// No description provided for @validRequired.
  ///
  /// In de, this message translates to:
  /// **'Pflichtfeld'**
  String get validRequired;

  /// No description provided for @validEmail.
  ///
  /// In de, this message translates to:
  /// **'Gültige E-Mail eingeben'**
  String get validEmail;

  /// No description provided for @validPassword.
  ///
  /// In de, this message translates to:
  /// **'Mindestens 8 Zeichen'**
  String get validPassword;

  /// No description provided for @language.
  ///
  /// In de, this message translates to:
  /// **'Sprache'**
  String get language;

  /// No description provided for @langDe.
  ///
  /// In de, this message translates to:
  /// **'Deutsch'**
  String get langDe;

  /// No description provided for @langRu.
  ///
  /// In de, this message translates to:
  /// **'Russisch'**
  String get langRu;

  /// No description provided for @langTg.
  ///
  /// In de, this message translates to:
  /// **'Tadschikisch'**
  String get langTg;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'ru', 'tg'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'ru':
      return AppLocalizationsRu();
    case 'tg':
      return AppLocalizationsTg();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
