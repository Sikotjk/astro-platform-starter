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
  String get langTg => 'Таджикский';
}
