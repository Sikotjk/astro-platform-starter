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
  String get logoutConfirm => 'Шумо дар ҳақиқат баромадан мехоҳед?';

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
  String get retry => 'Аз нав кӯшиш кардан';

  @override
  String get timeJustNow => 'ҳозир';

  @override
  String timeMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дақ. пеш',
    );
    return '$_temp0';
  }

  @override
  String timeHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count соат пеш',
    );
    return '$_temp0';
  }

  @override
  String timeDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count рӯз пеш',
      one: 'дирӯз',
    );
    return '$_temp0';
  }

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
  String get newTraveler => 'Нав';

  @override
  String get saveSearch => 'Ҷустуҷӯро захира кардан';

  @override
  String get searchSaved =>
      'Ҷустуҷӯ захира шуд. Ҳангоми мувофиқат хабардор мешавед.';

  @override
  String get savedSearches => 'Ҷустуҷӯҳои захирашуда';

  @override
  String get noSavedSearches => 'Ҷустуҷӯи захирашуда нест.';

  @override
  String get deleteSearch => 'Нест кардан';

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
  String get filterUnread => 'Хонданашуда';

  @override
  String get filterActive => 'Фаъол';

  @override
  String get filterDone => 'Анҷомёфта';

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
  String get categoryDocuments => 'Ҳуҷҷатҳо';

  @override
  String get categoryClothing => 'Сару либос';

  @override
  String get categoryFoodDry => 'Озуқа (хушк)';

  @override
  String get categoryElectronics => 'Электроника';

  @override
  String get categoryMedicine => 'Доруҳо';

  @override
  String get categoryGifts => 'Тӯҳфаҳо';

  @override
  String get categoryCosmetics => 'Косметика';

  @override
  String get categoryOther => 'Дигар';

  @override
  String get fieldDescription => 'Тавсиф';

  @override
  String get bookButton => 'Дархости фармоиш';

  @override
  String get complianceDeclaration =>
      'Тасдиқ мекунам: бе силоҳ, маводи мухаддир, қалбакӣ, маҳсулоти зудвайроншаванда ё доруҳои рецептӣ.';

  @override
  String get complianceRequired => 'Барои идома эъломияро тасдиқ кунед.';

  @override
  String estimatedCost(Object amount, Object currency) {
    return 'Хароҷоти тахминии интиқол: $amount $currency';
  }

  @override
  String get plusServiceFee => 'илова бар ин ҳаққи хизматрасонӣ';

  @override
  String get validNumber => 'Рақами > 0 ворид кунед';

  @override
  String get validMin3 => 'Ҳадди ақал 3 аломат';

  @override
  String get bookingRequested => 'Фармоиш дархост шуд!';

  @override
  String get manifestTitle => 'Манифести гумрукӣ';

  @override
  String get manifestOpen => 'Кушодани манифест';

  @override
  String get manifestHashLabel => 'Ҳэши яклухтӣ';

  @override
  String get manifestOfflineCopy => 'Нусхаи офлайн (охирин захирашуда)';

  @override
  String manifestSize(Object kb) {
    return '$kb КБ';
  }

  @override
  String get detailTitle => 'Тафсилоти фармоиш';

  @override
  String get bookingPartner => 'Шарики фармоиш';

  @override
  String get timelineTitle => 'Таърихи ҳолат';

  @override
  String get actionsTitle => 'Амалҳо';

  @override
  String get openChat => 'Кушодани чат';

  @override
  String get amountLabel => 'Маблағ';

  @override
  String get payStatusPending => 'Дар интизори пардохт';

  @override
  String get payStatusEscrowHeld => 'Дар эскроу нигоҳ дошта мешавад';

  @override
  String get payStatusReleased => 'Пардохт шуд';

  @override
  String get payStatusRefunded => 'Баргардонида шуд';

  @override
  String get payStatusFailed => 'Пардохт ноком шуд';

  @override
  String get noEvents => 'Ҳоло тағйироти ҳолат нест.';

  @override
  String get actionAccept => 'Қабул кардан';

  @override
  String get actionReject => 'Рад кардан';

  @override
  String get actionPay => 'Пардохт';

  @override
  String get paymentSuccess =>
      'Пардохт фиристода шуд. Ҳолат ба зудӣ нав мешавад.';

  @override
  String get paymentNotConfigured =>
      'Пардохтҳо дар ин версияи барнома фаъол нестанд.';

  @override
  String get actionAcceptTerms => 'Тасдиқи мӯҳтаво';

  @override
  String get actionHandover => 'Супоридан';

  @override
  String get actionTransit => 'Дар парвоз';

  @override
  String get actionDelivered => 'Расонида шуд';

  @override
  String get actionConfirm => 'Тасдиқи қабул';

  @override
  String get actionCancel => 'Бекор кардан';

  @override
  String get cancel => 'Бекор';

  @override
  String get reviewAction => 'Баҳо додан';

  @override
  String get reviewTitle => 'Баҳо гузоштан';

  @override
  String get reviewSubmit => 'Фиристодан';

  @override
  String get reviewCommentHint => 'Шарҳ (ихтиёрӣ)';

  @override
  String get reviewSuccess => 'Ташаккур барои баҳои шумо!';

  @override
  String get reviewsTitle => 'Баҳоҳо';

  @override
  String get noReviews => 'Ҳоло баҳо нест.';

  @override
  String get disputeAction => 'Кушодани баҳс';

  @override
  String get disputeTitle => 'Кушодани баҳс';

  @override
  String get disputeHint =>
      'Мушкилотро тавсиф кунед. Миёнарав парвандаро баррасӣ карда, пулро озод мекунад ё бармегардонад.';

  @override
  String get disputeReasonHint => 'Сабаб (ҳадди ақал 5 аломат)';

  @override
  String get disputeReasonTooShort => 'Лутфан ҳадди ақал 5 аломат нависед.';

  @override
  String get disputeSubmit => 'Фиристодани баҳс';

  @override
  String get disputeSuccess =>
      'Баҳс кушода шуд. Миёнарав бо шумо тамос мегирад.';

  @override
  String get profileTitle => 'Профили ман';

  @override
  String get editProfile => 'Профилро таҳрир кардан';

  @override
  String get save => 'Захира кардан';

  @override
  String get profileSaved => 'Профил захира шуд.';

  @override
  String reviewsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count баҳо',
      one: '1 баҳо',
    );
    return '$_temp0';
  }
}
