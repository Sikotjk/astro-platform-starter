// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'TJ-Shipping';

  @override
  String get navLogin => 'Вход';

  @override
  String get navRegister => 'Регистрация';

  @override
  String get fieldEmail => 'Эл. почта';

  @override
  String get fieldPassword => 'Пароль';

  @override
  String get fieldFirstName => 'Имя';

  @override
  String get fieldLastName => 'Фамилия';

  @override
  String get loginButton => 'Войти';

  @override
  String get registerButton => 'Создать аккаунт';

  @override
  String get noAccount => 'Нет аккаунта? Зарегистрироваться';

  @override
  String get roleLabel => 'Я хочу …';

  @override
  String get roleSender => 'Отправлять посылки';

  @override
  String get roleTraveler => 'Предложить место';

  @override
  String get roleBoth => 'И то, и другое';

  @override
  String get homeWelcome => 'Добро пожаловать в TJ-Shipping!';

  @override
  String get homeSearchTrips => 'Поиск рейсов';

  @override
  String get homeMyBookings => 'Мои бронирования';

  @override
  String get homeNotifications => 'Уведомления';

  @override
  String get homeVerify => 'Подтвердить личность';

  @override
  String get logout => 'Выйти';

  @override
  String get logoutConfirm => 'Вы действительно хотите выйти?';

  @override
  String get validRequired => 'Обязательное поле';

  @override
  String get validEmail => 'Введите корректную эл. почту';

  @override
  String get validPassword => 'Минимум 8 символов';

  @override
  String get language => 'Язык';

  @override
  String get langDe => 'Немецкий';

  @override
  String get langRu => 'Русский';

  @override
  String get langTj => 'Таджикский';

  @override
  String get refresh => 'Обновить';

  @override
  String get retry => 'Повторить';

  @override
  String get timeJustNow => 'только что';

  @override
  String timeMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count мин. назад',
      few: '$count мин. назад',
      one: '$count мин. назад',
    );
    return '$_temp0';
  }

  @override
  String timeHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ч. назад',
      few: '$count ч. назад',
      one: '$count ч. назад',
    );
    return '$_temp0';
  }

  @override
  String timeDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дн. назад',
      few: '$count дн. назад',
      one: 'вчера',
    );
    return '$_temp0';
  }

  @override
  String get tripsTitle => 'Поиск рейсов';

  @override
  String get fieldFrom => 'Откуда (IATA)';

  @override
  String get fieldTo => 'Куда (IATA)';

  @override
  String get fieldMinKg => 'Мин. свободно кг';

  @override
  String get searchButton => 'Искать';

  @override
  String get noTrips => 'Рейсы не найдены.';

  @override
  String get newTraveler => 'Новый';

  @override
  String get saveSearch => 'Сохранить поиск';

  @override
  String get searchSaved => 'Поиск сохранён. Мы уведомим вас о совпадениях.';

  @override
  String get savedSearches => 'Сохранённые поиски';

  @override
  String get noSavedSearches => 'Нет сохранённых поисков.';

  @override
  String get deleteSearch => 'Удалить';

  @override
  String tripSubtitle(Object date, Object kg, Object price, Object currency) {
    return 'Вылет $date · $kg кг свободно · $price $currency/кг';
  }

  @override
  String get bookingsTitle => 'Мои бронирования';

  @override
  String get filterAll => 'Все';

  @override
  String get filterAsSender => 'Как отправитель';

  @override
  String get filterAsTraveler => 'Как путешественник';

  @override
  String get filterUnread => 'Непрочитанные';

  @override
  String get filterActive => 'Активные';

  @override
  String get filterDone => 'Завершённые';

  @override
  String get noBookings => 'Пока нет бронирований.';

  @override
  String get statusRequested => 'Запрошено';

  @override
  String get statusAccepted => 'Принято';

  @override
  String get statusPaid => 'Оплачено';

  @override
  String get statusHandedOver => 'Передано';

  @override
  String get statusInTransit => 'В пути';

  @override
  String get statusDelivered => 'Доставлено';

  @override
  String get statusConfirmed => 'Завершено';

  @override
  String get statusDisputed => 'Спор';

  @override
  String get statusRefunded => 'Возвращено';

  @override
  String get statusCancelled => 'Отменено';

  @override
  String get statusRejected => 'Отклонено';

  @override
  String get chatTitle => 'Чат';

  @override
  String get messageHint => 'Сообщение …';

  @override
  String get noMessages => 'Пока нет сообщений.';

  @override
  String get kycTitle => 'Проверка личности';

  @override
  String get kycVerified => 'Подтверждено';

  @override
  String get kycPending => 'На проверке';

  @override
  String get kycRejected => 'Отклонено';

  @override
  String get kycNotStarted => 'Не начато';

  @override
  String get kycHint =>
      'Для предложения рейсов нужна однократная проверка личности.';

  @override
  String get kycStart => 'Начать проверку';

  @override
  String get kycRestart => 'Начать заново';

  @override
  String get notificationsTitle => 'Уведомления';

  @override
  String get markAllRead => 'Прочитать все';

  @override
  String get noNotifications => 'Нет уведомлений.';

  @override
  String bookTitle(Object route) {
    return 'Бронь · $route';
  }

  @override
  String bookTripInfo(Object date, Object price, Object currency) {
    return 'Вылет $date · $price $currency/кг';
  }

  @override
  String get fieldPackageTitle => 'Название посылки';

  @override
  String get fieldWeightKg => 'Вес (кг)';

  @override
  String get fieldDeclaredValue => 'Стоимость (EUR)';

  @override
  String get recipientSection => 'Получатель';

  @override
  String get fieldName => 'Имя';

  @override
  String get fieldPhone => 'Телефон';

  @override
  String get fieldCity => 'Город';

  @override
  String get contentSection => 'Содержимое (таможенная декларация)';

  @override
  String get fieldCategory => 'Категория';

  @override
  String get categoryDocuments => 'Документы';

  @override
  String get categoryClothing => 'Одежда';

  @override
  String get categoryFoodDry => 'Продукты (сухие)';

  @override
  String get categoryElectronics => 'Электроника';

  @override
  String get categoryMedicine => 'Лекарства';

  @override
  String get categoryGifts => 'Подарки';

  @override
  String get categoryCosmetics => 'Косметика';

  @override
  String get categoryOther => 'Прочее';

  @override
  String get fieldDescription => 'Описание';

  @override
  String get bookButton => 'Запросить бронь';

  @override
  String get complianceDeclaration =>
      'Подтверждаю: без оружия, наркотиков, подделок, скоропортящихся продуктов и рецептурных лекарств.';

  @override
  String get complianceRequired => 'Подтвердите декларацию, чтобы продолжить.';

  @override
  String estimatedCost(Object amount, Object currency) {
    return 'Примерная стоимость доставки: $amount $currency';
  }

  @override
  String get plusServiceFee => 'плюс сервисный сбор';

  @override
  String get validNumber => 'Введите число > 0';

  @override
  String get validMin3 => 'Минимум 3 символа';

  @override
  String get bookingRequested => 'Бронь запрошена!';

  @override
  String get manifestTitle => 'Таможенный манифест';

  @override
  String get manifestOpen => 'Открыть манифест';

  @override
  String get manifestHashLabel => 'Хеш целостности';

  @override
  String get manifestOfflineCopy => 'Офлайн-копия (последняя сохранённая)';

  @override
  String manifestSize(Object kb) {
    return '$kb КБ';
  }

  @override
  String get detailTitle => 'Детали бронирования';

  @override
  String get bookingPartner => 'Партнёр по бронированию';

  @override
  String get timelineTitle => 'История статусов';

  @override
  String get actionsTitle => 'Действия';

  @override
  String get openChat => 'Открыть чат';

  @override
  String get amountLabel => 'Сумма';

  @override
  String get payStatusPending => 'Ожидает оплаты';

  @override
  String get payStatusEscrowHeld => 'На эскроу-счёте';

  @override
  String get payStatusReleased => 'Выплачено';

  @override
  String get payStatusRefunded => 'Возвращено';

  @override
  String get payStatusFailed => 'Платёж не прошёл';

  @override
  String get noEvents => 'Изменений статуса пока нет.';

  @override
  String get actionAccept => 'Принять';

  @override
  String get actionReject => 'Отклонить';

  @override
  String get actionPay => 'Оплатить';

  @override
  String get paymentSuccess =>
      'Платёж отправлен. Статус обновится в ближайшее время.';

  @override
  String get paymentNotConfigured =>
      'Платежи не активированы в этой версии приложения.';

  @override
  String get actionAcceptTerms => 'Подтвердить содержимое';

  @override
  String get actionHandover => 'Передать';

  @override
  String get actionTransit => 'В пути';

  @override
  String get actionDelivered => 'Доставлено';

  @override
  String get actionConfirm => 'Подтвердить получение';

  @override
  String get actionCancel => 'Отменить';

  @override
  String get cancel => 'Отмена';

  @override
  String get reviewAction => 'Оценить';

  @override
  String get reviewTitle => 'Оставить отзыв';

  @override
  String get reviewSubmit => 'Отправить';

  @override
  String get reviewCommentHint => 'Комментарий (необязательно)';

  @override
  String get reviewSuccess => 'Спасибо за ваш отзыв!';

  @override
  String get reviewsTitle => 'Отзывы';

  @override
  String get noReviews => 'Отзывов пока нет.';

  @override
  String get disputeAction => 'Открыть спор';

  @override
  String get disputeTitle => 'Открыть спор';

  @override
  String get disputeHint =>
      'Опишите проблему. Посредник рассмотрит дело и переведёт деньги или вернёт их.';

  @override
  String get disputeReasonHint => 'Причина (мин. 5 символов)';

  @override
  String get disputeReasonTooShort => 'Укажите не менее 5 символов.';

  @override
  String get disputeSubmit => 'Отправить спор';

  @override
  String get disputeSuccess => 'Спор открыт. Посредник свяжется с вами.';

  @override
  String get profileTitle => 'Мой профиль';

  @override
  String get editProfile => 'Редактировать профиль';

  @override
  String get save => 'Сохранить';

  @override
  String get profileSaved => 'Профиль сохранён.';

  @override
  String reviewsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count отзывов',
      few: '$count отзыва',
      one: '1 отзыв',
    );
    return '$_temp0';
  }
}
