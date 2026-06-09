// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'TJ-Shipping';

  @override
  String get navLogin => 'Anmelden';

  @override
  String get navRegister => 'Registrieren';

  @override
  String get fieldEmail => 'E-Mail';

  @override
  String get fieldPassword => 'Passwort';

  @override
  String get fieldFirstName => 'Vorname';

  @override
  String get fieldLastName => 'Nachname';

  @override
  String get loginButton => 'Anmelden';

  @override
  String get registerButton => 'Konto erstellen';

  @override
  String get noAccount => 'Noch kein Konto? Registrieren';

  @override
  String get roleLabel => 'Ich möchte …';

  @override
  String get roleSender => 'Pakete senden';

  @override
  String get roleTraveler => 'Platz anbieten';

  @override
  String get roleBoth => 'Beides';

  @override
  String get homeWelcome => 'Willkommen bei TJ-Shipping!';

  @override
  String get homeSearchTrips => 'Trips suchen';

  @override
  String get homeMyBookings => 'Meine Buchungen';

  @override
  String get homeNotifications => 'Benachrichtigungen';

  @override
  String get homeVerify => 'Identität verifizieren';

  @override
  String get logout => 'Abmelden';

  @override
  String get validRequired => 'Pflichtfeld';

  @override
  String get validEmail => 'Gültige E-Mail eingeben';

  @override
  String get validPassword => 'Mindestens 8 Zeichen';

  @override
  String get language => 'Sprache';

  @override
  String get langDe => 'Deutsch';

  @override
  String get langRu => 'Russisch';

  @override
  String get langTj => 'Tadschikisch';

  @override
  String get refresh => 'Aktualisieren';

  @override
  String get tripsTitle => 'Trips suchen';

  @override
  String get fieldFrom => 'Von (IATA)';

  @override
  String get fieldTo => 'Nach (IATA)';

  @override
  String get fieldMinKg => 'Min. freie kg';

  @override
  String get searchButton => 'Suchen';

  @override
  String get noTrips => 'Keine Trips gefunden.';

  @override
  String tripSubtitle(Object date, Object kg, Object price, Object currency) {
    return 'Abflug $date · $kg kg frei · $price $currency/kg';
  }

  @override
  String get bookingsTitle => 'Meine Buchungen';

  @override
  String get filterAll => 'Alle';

  @override
  String get filterAsSender => 'Als Sender';

  @override
  String get filterAsTraveler => 'Als Traveler';

  @override
  String get noBookings => 'Noch keine Buchungen.';

  @override
  String get statusRequested => 'Angefragt';

  @override
  String get statusAccepted => 'Akzeptiert';

  @override
  String get statusPaid => 'Bezahlt';

  @override
  String get statusHandedOver => 'Übergeben';

  @override
  String get statusInTransit => 'Im Transit';

  @override
  String get statusDelivered => 'Zugestellt';

  @override
  String get statusConfirmed => 'Abgeschlossen';

  @override
  String get statusDisputed => 'Streitfall';

  @override
  String get statusRefunded => 'Erstattet';

  @override
  String get statusCancelled => 'Storniert';

  @override
  String get statusRejected => 'Abgelehnt';

  @override
  String get chatTitle => 'Chat';

  @override
  String get messageHint => 'Nachricht …';

  @override
  String get noMessages => 'Noch keine Nachrichten.';

  @override
  String get kycTitle => 'Identitätsprüfung';

  @override
  String get kycVerified => 'Verifiziert';

  @override
  String get kycPending => 'In Prüfung';

  @override
  String get kycRejected => 'Abgelehnt';

  @override
  String get kycNotStarted => 'Nicht gestartet';

  @override
  String get kycHint =>
      'Zum Anbieten von Trips ist eine einmalige Identitätsprüfung nötig.';

  @override
  String get kycStart => 'Verifizierung starten';

  @override
  String get kycRestart => 'Erneut starten';

  @override
  String get notificationsTitle => 'Benachrichtigungen';

  @override
  String get markAllRead => 'Alle gelesen';

  @override
  String get noNotifications => 'Keine Benachrichtigungen.';

  @override
  String bookTitle(Object route) {
    return 'Buchen · $route';
  }

  @override
  String bookTripInfo(Object date, Object price, Object currency) {
    return 'Abflug $date · $price $currency/kg';
  }

  @override
  String get fieldPackageTitle => 'Pakettitel';

  @override
  String get fieldWeightKg => 'Gewicht (kg)';

  @override
  String get fieldDeclaredValue => 'Warenwert (EUR)';

  @override
  String get recipientSection => 'Empfänger';

  @override
  String get fieldName => 'Name';

  @override
  String get fieldPhone => 'Telefon';

  @override
  String get fieldCity => 'Stadt';

  @override
  String get contentSection => 'Inhalt (Zoll-Deklaration)';

  @override
  String get fieldCategory => 'Kategorie';

  @override
  String get fieldDescription => 'Beschreibung';

  @override
  String get bookButton => 'Buchung anfragen';

  @override
  String get validNumber => 'Zahl > 0 eingeben';

  @override
  String get validMin3 => 'Mind. 3 Zeichen';

  @override
  String get bookingRequested => 'Buchung angefragt!';

  @override
  String get manifestTitle => 'Zoll-Manifest';

  @override
  String get manifestOpen => 'Manifest öffnen';

  @override
  String get manifestHashLabel => 'Integritäts-Hash';

  @override
  String manifestSize(Object kb) {
    return '$kb KB';
  }

  @override
  String get detailTitle => 'Buchungsdetails';

  @override
  String get timelineTitle => 'Statusverlauf';

  @override
  String get actionsTitle => 'Aktionen';

  @override
  String get openChat => 'Chat öffnen';

  @override
  String get amountLabel => 'Betrag';

  @override
  String get noEvents => 'Noch keine Statusänderungen.';

  @override
  String get actionAccept => 'Annehmen';

  @override
  String get actionReject => 'Ablehnen';

  @override
  String get actionPay => 'Bezahlen';

  @override
  String get actionAcceptTerms => 'Inhalt bestätigen';

  @override
  String get actionHandover => 'Übergeben';

  @override
  String get actionTransit => 'Im Flug';

  @override
  String get actionDelivered => 'Zugestellt';

  @override
  String get actionConfirm => 'Empfang bestätigen';

  @override
  String get actionCancel => 'Stornieren';
}
