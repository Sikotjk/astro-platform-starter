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

  /// No description provided for @langTj.
  ///
  /// In de, this message translates to:
  /// **'Tadschikisch'**
  String get langTj;

  /// No description provided for @refresh.
  ///
  /// In de, this message translates to:
  /// **'Aktualisieren'**
  String get refresh;

  /// No description provided for @tripsTitle.
  ///
  /// In de, this message translates to:
  /// **'Trips suchen'**
  String get tripsTitle;

  /// No description provided for @fieldFrom.
  ///
  /// In de, this message translates to:
  /// **'Von (IATA)'**
  String get fieldFrom;

  /// No description provided for @fieldTo.
  ///
  /// In de, this message translates to:
  /// **'Nach (IATA)'**
  String get fieldTo;

  /// No description provided for @fieldMinKg.
  ///
  /// In de, this message translates to:
  /// **'Min. freie kg'**
  String get fieldMinKg;

  /// No description provided for @searchButton.
  ///
  /// In de, this message translates to:
  /// **'Suchen'**
  String get searchButton;

  /// No description provided for @noTrips.
  ///
  /// In de, this message translates to:
  /// **'Keine Trips gefunden.'**
  String get noTrips;

  /// No description provided for @newTraveler.
  ///
  /// In de, this message translates to:
  /// **'Neu'**
  String get newTraveler;

  /// No description provided for @tripSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Abflug {date} · {kg} kg frei · {price} {currency}/kg'**
  String tripSubtitle(Object date, Object kg, Object price, Object currency);

  /// No description provided for @bookingsTitle.
  ///
  /// In de, this message translates to:
  /// **'Meine Buchungen'**
  String get bookingsTitle;

  /// No description provided for @filterAll.
  ///
  /// In de, this message translates to:
  /// **'Alle'**
  String get filterAll;

  /// No description provided for @filterAsSender.
  ///
  /// In de, this message translates to:
  /// **'Als Sender'**
  String get filterAsSender;

  /// No description provided for @filterAsTraveler.
  ///
  /// In de, this message translates to:
  /// **'Als Traveler'**
  String get filterAsTraveler;

  /// No description provided for @noBookings.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Buchungen.'**
  String get noBookings;

  /// No description provided for @statusRequested.
  ///
  /// In de, this message translates to:
  /// **'Angefragt'**
  String get statusRequested;

  /// No description provided for @statusAccepted.
  ///
  /// In de, this message translates to:
  /// **'Akzeptiert'**
  String get statusAccepted;

  /// No description provided for @statusPaid.
  ///
  /// In de, this message translates to:
  /// **'Bezahlt'**
  String get statusPaid;

  /// No description provided for @statusHandedOver.
  ///
  /// In de, this message translates to:
  /// **'Übergeben'**
  String get statusHandedOver;

  /// No description provided for @statusInTransit.
  ///
  /// In de, this message translates to:
  /// **'Im Transit'**
  String get statusInTransit;

  /// No description provided for @statusDelivered.
  ///
  /// In de, this message translates to:
  /// **'Zugestellt'**
  String get statusDelivered;

  /// No description provided for @statusConfirmed.
  ///
  /// In de, this message translates to:
  /// **'Abgeschlossen'**
  String get statusConfirmed;

  /// No description provided for @statusDisputed.
  ///
  /// In de, this message translates to:
  /// **'Streitfall'**
  String get statusDisputed;

  /// No description provided for @statusRefunded.
  ///
  /// In de, this message translates to:
  /// **'Erstattet'**
  String get statusRefunded;

  /// No description provided for @statusCancelled.
  ///
  /// In de, this message translates to:
  /// **'Storniert'**
  String get statusCancelled;

  /// No description provided for @statusRejected.
  ///
  /// In de, this message translates to:
  /// **'Abgelehnt'**
  String get statusRejected;

  /// No description provided for @chatTitle.
  ///
  /// In de, this message translates to:
  /// **'Chat'**
  String get chatTitle;

  /// No description provided for @messageHint.
  ///
  /// In de, this message translates to:
  /// **'Nachricht …'**
  String get messageHint;

  /// No description provided for @noMessages.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Nachrichten.'**
  String get noMessages;

  /// No description provided for @kycTitle.
  ///
  /// In de, this message translates to:
  /// **'Identitätsprüfung'**
  String get kycTitle;

  /// No description provided for @kycVerified.
  ///
  /// In de, this message translates to:
  /// **'Verifiziert'**
  String get kycVerified;

  /// No description provided for @kycPending.
  ///
  /// In de, this message translates to:
  /// **'In Prüfung'**
  String get kycPending;

  /// No description provided for @kycRejected.
  ///
  /// In de, this message translates to:
  /// **'Abgelehnt'**
  String get kycRejected;

  /// No description provided for @kycNotStarted.
  ///
  /// In de, this message translates to:
  /// **'Nicht gestartet'**
  String get kycNotStarted;

  /// No description provided for @kycHint.
  ///
  /// In de, this message translates to:
  /// **'Zum Anbieten von Trips ist eine einmalige Identitätsprüfung nötig.'**
  String get kycHint;

  /// No description provided for @kycStart.
  ///
  /// In de, this message translates to:
  /// **'Verifizierung starten'**
  String get kycStart;

  /// No description provided for @kycRestart.
  ///
  /// In de, this message translates to:
  /// **'Erneut starten'**
  String get kycRestart;

  /// No description provided for @notificationsTitle.
  ///
  /// In de, this message translates to:
  /// **'Benachrichtigungen'**
  String get notificationsTitle;

  /// No description provided for @markAllRead.
  ///
  /// In de, this message translates to:
  /// **'Alle gelesen'**
  String get markAllRead;

  /// No description provided for @noNotifications.
  ///
  /// In de, this message translates to:
  /// **'Keine Benachrichtigungen.'**
  String get noNotifications;

  /// No description provided for @bookTitle.
  ///
  /// In de, this message translates to:
  /// **'Buchen · {route}'**
  String bookTitle(Object route);

  /// No description provided for @bookTripInfo.
  ///
  /// In de, this message translates to:
  /// **'Abflug {date} · {price} {currency}/kg'**
  String bookTripInfo(Object date, Object price, Object currency);

  /// No description provided for @fieldPackageTitle.
  ///
  /// In de, this message translates to:
  /// **'Pakettitel'**
  String get fieldPackageTitle;

  /// No description provided for @fieldWeightKg.
  ///
  /// In de, this message translates to:
  /// **'Gewicht (kg)'**
  String get fieldWeightKg;

  /// No description provided for @fieldDeclaredValue.
  ///
  /// In de, this message translates to:
  /// **'Warenwert (EUR)'**
  String get fieldDeclaredValue;

  /// No description provided for @recipientSection.
  ///
  /// In de, this message translates to:
  /// **'Empfänger'**
  String get recipientSection;

  /// No description provided for @fieldName.
  ///
  /// In de, this message translates to:
  /// **'Name'**
  String get fieldName;

  /// No description provided for @fieldPhone.
  ///
  /// In de, this message translates to:
  /// **'Telefon'**
  String get fieldPhone;

  /// No description provided for @fieldCity.
  ///
  /// In de, this message translates to:
  /// **'Stadt'**
  String get fieldCity;

  /// No description provided for @contentSection.
  ///
  /// In de, this message translates to:
  /// **'Inhalt (Zoll-Deklaration)'**
  String get contentSection;

  /// No description provided for @fieldCategory.
  ///
  /// In de, this message translates to:
  /// **'Kategorie'**
  String get fieldCategory;

  /// No description provided for @fieldDescription.
  ///
  /// In de, this message translates to:
  /// **'Beschreibung'**
  String get fieldDescription;

  /// No description provided for @bookButton.
  ///
  /// In de, this message translates to:
  /// **'Buchung anfragen'**
  String get bookButton;

  /// No description provided for @validNumber.
  ///
  /// In de, this message translates to:
  /// **'Zahl > 0 eingeben'**
  String get validNumber;

  /// No description provided for @validMin3.
  ///
  /// In de, this message translates to:
  /// **'Mind. 3 Zeichen'**
  String get validMin3;

  /// No description provided for @bookingRequested.
  ///
  /// In de, this message translates to:
  /// **'Buchung angefragt!'**
  String get bookingRequested;

  /// No description provided for @manifestTitle.
  ///
  /// In de, this message translates to:
  /// **'Zoll-Manifest'**
  String get manifestTitle;

  /// No description provided for @manifestOpen.
  ///
  /// In de, this message translates to:
  /// **'Manifest öffnen'**
  String get manifestOpen;

  /// No description provided for @manifestHashLabel.
  ///
  /// In de, this message translates to:
  /// **'Integritäts-Hash'**
  String get manifestHashLabel;

  /// No description provided for @manifestSize.
  ///
  /// In de, this message translates to:
  /// **'{kb} KB'**
  String manifestSize(Object kb);

  /// No description provided for @detailTitle.
  ///
  /// In de, this message translates to:
  /// **'Buchungsdetails'**
  String get detailTitle;

  /// No description provided for @timelineTitle.
  ///
  /// In de, this message translates to:
  /// **'Statusverlauf'**
  String get timelineTitle;

  /// No description provided for @actionsTitle.
  ///
  /// In de, this message translates to:
  /// **'Aktionen'**
  String get actionsTitle;

  /// No description provided for @openChat.
  ///
  /// In de, this message translates to:
  /// **'Chat öffnen'**
  String get openChat;

  /// No description provided for @amountLabel.
  ///
  /// In de, this message translates to:
  /// **'Betrag'**
  String get amountLabel;

  /// No description provided for @noEvents.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Statusänderungen.'**
  String get noEvents;

  /// No description provided for @actionAccept.
  ///
  /// In de, this message translates to:
  /// **'Annehmen'**
  String get actionAccept;

  /// No description provided for @actionReject.
  ///
  /// In de, this message translates to:
  /// **'Ablehnen'**
  String get actionReject;

  /// No description provided for @actionPay.
  ///
  /// In de, this message translates to:
  /// **'Bezahlen'**
  String get actionPay;

  /// No description provided for @actionAcceptTerms.
  ///
  /// In de, this message translates to:
  /// **'Inhalt bestätigen'**
  String get actionAcceptTerms;

  /// No description provided for @actionHandover.
  ///
  /// In de, this message translates to:
  /// **'Übergeben'**
  String get actionHandover;

  /// No description provided for @actionTransit.
  ///
  /// In de, this message translates to:
  /// **'Im Flug'**
  String get actionTransit;

  /// No description provided for @actionDelivered.
  ///
  /// In de, this message translates to:
  /// **'Zugestellt'**
  String get actionDelivered;

  /// No description provided for @actionConfirm.
  ///
  /// In de, this message translates to:
  /// **'Empfang bestätigen'**
  String get actionConfirm;

  /// No description provided for @actionCancel.
  ///
  /// In de, this message translates to:
  /// **'Stornieren'**
  String get actionCancel;

  /// No description provided for @cancel.
  ///
  /// In de, this message translates to:
  /// **'Abbrechen'**
  String get cancel;

  /// No description provided for @reviewAction.
  ///
  /// In de, this message translates to:
  /// **'Bewerten'**
  String get reviewAction;

  /// No description provided for @reviewTitle.
  ///
  /// In de, this message translates to:
  /// **'Bewertung abgeben'**
  String get reviewTitle;

  /// No description provided for @reviewSubmit.
  ///
  /// In de, this message translates to:
  /// **'Senden'**
  String get reviewSubmit;

  /// No description provided for @reviewCommentHint.
  ///
  /// In de, this message translates to:
  /// **'Kommentar (optional)'**
  String get reviewCommentHint;

  /// No description provided for @reviewSuccess.
  ///
  /// In de, this message translates to:
  /// **'Danke für deine Bewertung!'**
  String get reviewSuccess;

  /// No description provided for @reviewsTitle.
  ///
  /// In de, this message translates to:
  /// **'Bewertungen'**
  String get reviewsTitle;

  /// No description provided for @noReviews.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Bewertungen.'**
  String get noReviews;

  /// No description provided for @disputeAction.
  ///
  /// In de, this message translates to:
  /// **'Streitfall eröffnen'**
  String get disputeAction;

  /// No description provided for @disputeTitle.
  ///
  /// In de, this message translates to:
  /// **'Streitfall eröffnen'**
  String get disputeTitle;

  /// No description provided for @disputeHint.
  ///
  /// In de, this message translates to:
  /// **'Beschreibe das Problem. Ein Vermittler prüft den Fall und gibt das Geld frei oder erstattet es.'**
  String get disputeHint;

  /// No description provided for @disputeReasonHint.
  ///
  /// In de, this message translates to:
  /// **'Begründung (mind. 5 Zeichen)'**
  String get disputeReasonHint;

  /// No description provided for @disputeReasonTooShort.
  ///
  /// In de, this message translates to:
  /// **'Bitte mindestens 5 Zeichen angeben.'**
  String get disputeReasonTooShort;

  /// No description provided for @disputeSubmit.
  ///
  /// In de, this message translates to:
  /// **'Streitfall einreichen'**
  String get disputeSubmit;

  /// No description provided for @disputeSuccess.
  ///
  /// In de, this message translates to:
  /// **'Streitfall eröffnet. Ein Vermittler meldet sich.'**
  String get disputeSuccess;

  /// No description provided for @profileTitle.
  ///
  /// In de, this message translates to:
  /// **'Mein Profil'**
  String get profileTitle;

  /// No description provided for @reviewsCount.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{1 Bewertung} other{{count} Bewertungen}}'**
  String reviewsCount(int count);
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
