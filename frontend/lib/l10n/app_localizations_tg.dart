// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tajik (`tg`).
class AppLocalizationsTg extends AppLocalizations {
  AppLocalizationsTg([String locale = 'tg']) : super(locale);

  @override
  String get appTitle => 'TJ-Shipping';

  @override
  String get navLogin => 'Воридшавӣ';

  @override
  String get navRegister => 'Бақайдгирӣ';

  @override
  String get fieldEmail => 'Почтаи электронӣ';

  @override
  String get fieldPassword => 'Парол';

  @override
  String get fieldFirstName => 'Ном';

  @override
  String get fieldLastName => 'Насаб';

  @override
  String get loginButton => 'Ворид шудан';

  @override
  String get registerButton => 'Сохтани ҳисоб';

  @override
  String get noAccount => 'Ҳисоб надоред? Бақайдгирӣ';

  @override
  String get roleLabel => 'Ман мехоҳам …';

  @override
  String get roleSender => 'Бастаҳо фиристам';

  @override
  String get roleTraveler => 'Ҷой пешниҳод кунам';

  @override
  String get roleBoth => 'Ҳар ду';

  @override
  String get homeWelcome => 'Хуш омадед ба TJ-Shipping!';

  @override
  String get homeSearchTrips => 'Ҷустуҷӯи парвозҳо';

  @override
  String get homeMyBookings => 'Фармоишҳои ман';

  @override
  String get homeNotifications => 'Огоҳиномаҳо';

  @override
  String get homeVerify => 'Тасдиқи шахсият';

  @override
  String get logout => 'Баромадан';

  @override
  String get validRequired => 'Майдони ҳатмӣ';

  @override
  String get validEmail => 'Почтаи дурусти электрониро ворид кунед';

  @override
  String get validPassword => 'Ҳадди ақал 8 аломат';

  @override
  String get language => 'Забон';

  @override
  String get langDe => 'Олмонӣ';

  @override
  String get langRu => 'Русӣ';

  @override
  String get langTj => 'Тоҷикӣ';

  @override
  String get refresh => 'Навсозӣ';

  @override
  String get tripsTitle => 'Ҷустуҷӯи парвозҳо';

  @override
  String get fieldFrom => 'Аз (IATA)';

  @override
  String get fieldTo => 'Ба (IATA)';

  @override
  String get fieldMinKg => 'Ҳадди ақал кг озод';

  @override
  String get searchButton => 'Ҷустуҷӯ';

  @override
  String get noTrips => 'Парвоз ёфт нашуд.';

  @override
  String tripSubtitle(Object date, Object kg, Object price, Object currency) {
    return 'Парвоз $date · $kg кг озод · $price $currency/кг';
  }

  @override
  String get bookingsTitle => 'Фармоишҳои ман';

  @override
  String get filterAll => 'Ҳама';

  @override
  String get filterAsSender => 'Ҳамчун фиристанда';

  @override
  String get filterAsTraveler => 'Ҳамчун мусофир';

  @override
  String get noBookings => 'Ҳоло фармоиш нест.';

  @override
  String get statusRequested => 'Дархостшуда';

  @override
  String get statusAccepted => 'Қабулшуда';

  @override
  String get statusPaid => 'Пардохтшуда';

  @override
  String get statusHandedOver => 'Супоридашуда';

  @override
  String get statusInTransit => 'Дар роҳ';

  @override
  String get statusDelivered => 'Расонидашуда';

  @override
  String get statusConfirmed => 'Анҷомёфта';

  @override
  String get statusDisputed => 'Баҳс';

  @override
  String get statusRefunded => 'Баргардонида';

  @override
  String get statusCancelled => 'Бекоршуда';

  @override
  String get statusRejected => 'Радшуда';

  @override
  String get chatTitle => 'Чат';

  @override
  String get messageHint => 'Паём …';

  @override
  String get noMessages => 'Ҳоло паём нест.';

  @override
  String get kycTitle => 'Тасдиқи шахсият';

  @override
  String get kycVerified => 'Тасдиқшуда';

  @override
  String get kycPending => 'Дар тафтиш';

  @override
  String get kycRejected => 'Радшуда';

  @override
  String get kycNotStarted => 'Оғоз нашуда';

  @override
  String get kycHint =>
      'Барои пешниҳоди парвозҳо як маротиба тасдиқи шахсият лозим аст.';

  @override
  String get kycStart => 'Оғози тасдиқ';

  @override
  String get kycRestart => 'Аз нав оғоз кардан';

  @override
  String get notificationsTitle => 'Огоҳиномаҳо';

  @override
  String get markAllRead => 'Ҳамаро хонда қайд кардан';

  @override
  String get noNotifications => 'Огоҳинома нест.';

  @override
  String bookTitle(Object route) {
    return 'Фармоиш · $route';
  }

  @override
  String bookTripInfo(Object date, Object price, Object currency) {
    return 'Парвоз $date · $price $currency/кг';
  }

  @override
  String get fieldPackageTitle => 'Номи баста';

  @override
  String get fieldWeightKg => 'Вазн (кг)';

  @override
  String get fieldDeclaredValue => 'Арзиш (EUR)';

  @override
  String get recipientSection => 'Гиранда';

  @override
  String get fieldName => 'Ном';

  @override
  String get fieldPhone => 'Телефон';

  @override
  String get fieldCity => 'Шаҳр';

  @override
  String get contentSection => 'Мӯҳтаво (декларатсияи гумрукӣ)';

  @override
  String get fieldCategory => 'Категория';

  @override
  String get fieldDescription => 'Тавсиф';

  @override
  String get bookButton => 'Дархости фармоиш';

  @override
  String get validNumber => 'Рақами > 0 ворид кунед';

  @override
  String get validMin3 => 'Ҳадди ақал 3 аломат';

  @override
  String get bookingRequested => 'Фармоиш дархост шуд!';
}
