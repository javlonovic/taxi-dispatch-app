// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'Такси Диспетчер';

  @override
  String get welcome => 'Добро пожаловать';

  @override
  String get login => 'Войти';

  @override
  String get register => 'Регистрация';

  @override
  String get logout => 'Выйти';

  @override
  String get cancel => 'Отмена';

  @override
  String get confirm => 'Подтвердить';

  @override
  String get save => 'Сохранить';

  @override
  String get delete => 'Удалить';

  @override
  String get edit => 'Редактировать';

  @override
  String get add => 'Добавить';

  @override
  String get skip => 'Пропустить';

  @override
  String get next => 'Далее';

  @override
  String get back => 'Назад';

  @override
  String get done => 'Готово';

  @override
  String get ok => 'ОК';

  @override
  String get yes => 'Да';

  @override
  String get no => 'Нет';

  @override
  String get username => 'Имя пользователя';

  @override
  String get password => 'Пароль';

  @override
  String get email => 'Электронная почта';

  @override
  String get phone => 'Телефон';

  @override
  String get address => 'Адрес';

  @override
  String get usernameHint => 'Введите имя пользователя';

  @override
  String get passwordHint => 'Введите пароль';

  @override
  String get phoneHint => 'Введите номер телефона';

  @override
  String get invalidUsername => 'Неверное имя пользователя';

  @override
  String get invalidPassword => 'Пароль должен содержать минимум 8 символов';

  @override
  String get invalidPhone => 'Неверный номер телефона';

  @override
  String get usernameRequired => 'Имя пользователя обязательно';

  @override
  String get passwordRequired => 'Пароль обязателен';

  @override
  String get usernameAlreadyExists => 'Имя пользователя уже занято';

  @override
  String get invalidCredentials => 'Неверное имя пользователя или пароль';

  @override
  String get weakPassword => 'Пароль слишком слабый (минимум 8 символов)';

  @override
  String get networkError => 'Нет подключения к интернету';

  @override
  String get home => 'Главная';

  @override
  String get history => 'История';

  @override
  String get transactions => 'Транзакции';

  @override
  String get profile => 'Профиль';

  @override
  String get settings => 'Настройки';

  @override
  String get companyRole => 'Я компания';

  @override
  String get driverRole => 'Я водитель';

  @override
  String get companyName => 'Название компании';

  @override
  String get companyNameHint => 'Введите название компании';

  @override
  String get companyNameRequired => 'Название компании обязательно';

  @override
  String get firstName => 'Имя';

  @override
  String get lastName => 'Фамилия';

  @override
  String get age => 'Возраст';

  @override
  String get carModel => 'Модель автомобиля';

  @override
  String get carNumber => 'Номер автомобиля';

  @override
  String get carColor => 'Цвет автомобиля';

  @override
  String get firstNameHint => 'Введите имя';

  @override
  String get lastNameHint => 'Введите фамилию';

  @override
  String get ageHint => 'Введите возраст';

  @override
  String get carModelHint => 'Введите модель автомобиля';

  @override
  String get carNumberHint => 'Введите номер автомобиля';

  @override
  String get carColorHint => 'Введите цвет автомобиля';

  @override
  String get firstNameRequired => 'Имя обязательно';

  @override
  String get lastNameRequired => 'Фамилия обязательна';

  @override
  String get ageRequired => 'Возраст обязателен';

  @override
  String get carModelRequired => 'Модель автомобиля обязательна';

  @override
  String get carNumberRequired => 'Номер автомобиля обязателен';

  @override
  String get carColorRequired => 'Цвет автомобиля обязателен';

  @override
  String get headquartersLocation => 'Расположение главного офиса';

  @override
  String get selectLocation => 'Выбрать местоположение';

  @override
  String get selectLocationOnMap => 'Выберите местоположение на карте';

  @override
  String get branches => 'Филиалы';

  @override
  String get addBranch => 'Добавить филиал';

  @override
  String get editBranch => 'Редактировать филиал';

  @override
  String get deleteBranch => 'Удалить филиал';

  @override
  String get branchName => 'Название филиала';

  @override
  String get branchNameHint => 'Введите название филиала';

  @override
  String get branchNameRequired => 'Название филиала обязательно';

  @override
  String get cannotDeleteLastBranch => 'Нельзя удалить последний филиал';

  @override
  String get confirmDeleteBranch =>
      'Вы уверены, что хотите удалить этот филиал?';

  @override
  String get searchForTaxi => 'Найти такси';

  @override
  String get recipientName => 'Имя получателя';

  @override
  String get recipientPhone => 'Телефон получателя';

  @override
  String get deliveryAddress => 'Адрес доставки';

  @override
  String get pickupAddress => 'Адрес отправления';

  @override
  String get recipientNameHint => 'Введите имя получателя';

  @override
  String get recipientPhoneHint => 'Введите телефон получателя';

  @override
  String get deliveryAddressHint => 'Введите адрес доставки';

  @override
  String get recipientNameRequired => 'Имя получателя обязательно';

  @override
  String get recipientPhoneRequired => 'Телефон получателя обязателен';

  @override
  String get deliveryAddressRequired => 'Адрес доставки обязателен';

  @override
  String get readyTime => 'Когда готов к отправке?';

  @override
  String get readyNow => 'Сейчас';

  @override
  String get readyIn15 => '15 мин';

  @override
  String get readyIn30 => '30 мин';

  @override
  String get readyIn45 => '45 мин';

  @override
  String get readyIn60 => '60 мин';

  @override
  String get driverWillBeNotified =>
      'Водитель будет уведомлен о времени готовности';

  @override
  String get selectBranch => 'Выбрать филиал';

  @override
  String get selectBranchForDelivery => 'Выберите филиал для доставки';

  @override
  String get driverStatus => 'Статус работы';

  @override
  String get active => 'Активен';

  @override
  String get inactive => 'Неактивен';

  @override
  String get activeDescription => 'Активен - вы получаете заказы';

  @override
  String get inactiveDescription => 'Неактивен - вы не получаете заказы';

  @override
  String get changeStatus => 'Изменить статус?';

  @override
  String get confirmActivateStatus =>
      'Вы начнете получать уведомления о новых заказах в радиусе 5-6 км';

  @override
  String get confirmDeactivateStatus =>
      'Вы перестанете получать заказы. Вы сможете включить статус в любое время.';

  @override
  String get statusChangedToActive => 'Статус изменен на Активен';

  @override
  String get statusChangedToInactive => 'Статус изменен на Неактивен';

  @override
  String get searching => 'Ищем';

  @override
  String get searchingForDriver => 'Ищем доступных водителей поблизости';

  @override
  String get stillSearching => 'Все еще ищем, пожалуйста подождите';

  @override
  String get driverOnTheWay => 'Водитель в пути';

  @override
  String get delivered => 'Доставлено';

  @override
  String get cancelled => 'Отменено';

  @override
  String get noDriverFound => 'Такси не найдено, попробуйте позже';

  @override
  String get driverInfo => 'Информация о водителе';

  @override
  String get driverName => 'Имя водителя';

  @override
  String get carInfo => 'Информация об автомобиле';

  @override
  String get rating => 'Рейтинг';

  @override
  String get eta => 'Время прибытия';

  @override
  String get orderDetails => 'Детали заказа';

  @override
  String get acceptOrder => 'Принять';

  @override
  String get skipOrder => 'Пропустить';

  @override
  String get orderAccepted => 'Заказ принят';

  @override
  String get recentOrders => 'Недавние заказы';

  @override
  String get noOrdersYet => 'У вас пока нет заказов';

  @override
  String get firstTimeUserBanner => 'Это ваш первый заказ? Мы поможем!';

  @override
  String get howToOrder => 'Как заказать доставку';

  @override
  String get deliveryHistory => 'История доставок';

  @override
  String get noHistory => 'История пуста';

  @override
  String get viewDetails => 'Посмотреть детали';

  @override
  String get profileImage => 'Фото профиля';

  @override
  String get uploadImage => 'Загрузить фото';

  @override
  String get changeImage => 'Изменить фото';

  @override
  String get onboardingWelcomeTitle => 'Добро пожаловать в Такси Диспетчер';

  @override
  String get onboardingWelcomeSubtitle => 'Быстрая доставка для вашего бизнеса';

  @override
  String get onboardingCompanyTitle => 'Для компаний';

  @override
  String get onboardingCompanyDescription =>
      'Заказывайте доставку из любого филиала вашей компании';

  @override
  String get onboardingCompanyFeature1 => 'Управление филиалами';

  @override
  String get onboardingCompanyFeature2 => 'Отслеживание в реальном времени';

  @override
  String get onboardingCompanyFeature3 => 'История доставок';

  @override
  String get onboardingDriverTitle => 'Для водителей';

  @override
  String get onboardingDriverDescription => 'Принимайте заказы и зарабатывайте';

  @override
  String get onboardingDriverFeature1 => 'Гибкий график';

  @override
  String get onboardingDriverFeature2 => 'Мгновенные уведомления';

  @override
  String get onboardingDriverFeature3 => 'Отслеживание заработка';

  @override
  String get onboardingGetStarted => 'Начать';

  @override
  String get notifications => 'Уведомления';

  @override
  String get noNotifications => 'Нет уведомлений';

  @override
  String get error => 'Ошибка';

  @override
  String get success => 'Успешно';

  @override
  String get warning => 'Предупреждение';

  @override
  String get info => 'Информация';

  @override
  String get retry => 'Повторить';

  @override
  String get close => 'Закрыть';

  @override
  String get submit => 'Отправить';

  @override
  String get continueButton => 'Продолжить';

  @override
  String get loading => 'Загрузка...';

  @override
  String get pleaseWait => 'Пожалуйста, подождите';

  @override
  String get loginTitle => 'Вход в систему';

  @override
  String get registerTitle => 'Регистрация';

  @override
  String get forgotPassword => 'Забыли пароль?';

  @override
  String get dontHaveAccount => 'Нет аккаунта?';

  @override
  String get alreadyHaveAccount => 'Уже есть аккаунт?';

  @override
  String get signUp => 'Зарегистрироваться';

  @override
  String get signIn => 'Войти';

  @override
  String get emailVerification => 'Подтверждение email';

  @override
  String get phoneVerification => 'Подтверждение телефона';

  @override
  String get verificationCode => 'Код подтверждения';

  @override
  String get enterVerificationCode => 'Введите код подтверждения';

  @override
  String get resendCode => 'Отправить код повторно';

  @override
  String get verify => 'Подтвердить';

  @override
  String get companyRegistration => 'Регистрация компании';

  @override
  String get driverRegistration => 'Регистрация водителя';

  @override
  String get selectRole => 'Выберите роль';

  @override
  String get whoAreYou => 'Кто вы?';

  @override
  String get minAge => 'Минимальный возраст 18 лет';

  @override
  String get invalidAge => 'Неверный возраст';

  @override
  String get dashboard => 'Панель управления';

  @override
  String get companyDashboard => 'Панель компании';

  @override
  String get driverDashboard => 'Панель водителя';

  @override
  String get headquarters => 'Главный офис';

  @override
  String get isHeadquarters => 'Главный офис';

  @override
  String get branchAddress => 'Адрес филиала';

  @override
  String get branchLocation => 'Местоположение филиала';

  @override
  String get createDelivery => 'Создать доставку';

  @override
  String get requestDelivery => 'Заказать доставку';

  @override
  String get deliveryRequest => 'Запрос доставки';

  @override
  String get deliveryDetails => 'Детали доставки';

  @override
  String get deliveryStatus => 'Статус доставки';

  @override
  String get requestedAt => 'Запрошено';

  @override
  String get acceptedAt => 'Принято';

  @override
  String get completedAt => 'Завершено';

  @override
  String get cancelledAt => 'Отменено';

  @override
  String get cancellationReason => 'Причина отмены';

  @override
  String get pickupTime => 'Время забора';

  @override
  String get deliveryTime => 'Время доставки';

  @override
  String get estimatedTime => 'Ожидаемое время';

  @override
  String get scheduledTime => 'Запланированное время';

  @override
  String get distance => 'Расстояние';

  @override
  String get duration => 'Длительность';

  @override
  String get route => 'Маршрут';

  @override
  String get driverAssigned => 'Водитель назначен';

  @override
  String get waitingForDriver => 'Ожидание водителя';

  @override
  String get driverArriving => 'Водитель прибывает';

  @override
  String get inProgress => 'В процессе';

  @override
  String get completed => 'Завершено';

  @override
  String get failed => 'Не удалось';

  @override
  String get pending => 'Ожидание';

  @override
  String get accepted => 'Принято';

  @override
  String get enroute => 'В пути';

  @override
  String get arrived => 'Прибыл';

  @override
  String get acceptedOrders => 'Принятые заказы';

  @override
  String get activeOrders => 'Активные заказы';

  @override
  String get completedOrders => 'Завершенные заказы';

  @override
  String get cancelledOrders => 'Отмененные заказы';

  @override
  String get newOrder => 'Новый заказ';

  @override
  String get newOrderAvailable => 'Доступен новый заказ';

  @override
  String get orderReceived => 'Заказ получен';

  @override
  String get orderCancelled => 'Заказ отменен';

  @override
  String get orderCompleted => 'Заказ завершен';

  @override
  String get notificationTitle => 'Уведомление';

  @override
  String get notificationSettings => 'Настройки уведомлений';

  @override
  String get enableNotifications => 'Включить уведомления';

  @override
  String get disableNotifications => 'Отключить уведомления';

  @override
  String get notificationPermission => 'Разрешение на уведомления';

  @override
  String get notificationPermissionRequired =>
      'Требуется разрешение на уведомления';

  @override
  String get location => 'Местоположение';

  @override
  String get currentLocation => 'Текущее местоположение';

  @override
  String get locationPermission => 'Разрешение на местоположение';

  @override
  String get locationPermissionRequired =>
      'Требуется разрешение на местоположение';

  @override
  String get enableLocation => 'Включить местоположение';

  @override
  String get locationServices => 'Службы местоположения';

  @override
  String get locationNotAvailable => 'Местоположение недоступно';

  @override
  String get map => 'Карта';

  @override
  String get showOnMap => 'Показать на карте';

  @override
  String get openMap => 'Открыть карту';

  @override
  String get selectOnMap => 'Выбрать на карте';

  @override
  String get payment => 'Оплата';

  @override
  String get paymentMethod => 'Способ оплаты';

  @override
  String get paymentHistory => 'История платежей';

  @override
  String get paymentDetails => 'Детали платежа';

  @override
  String get paymentStatus => 'Статус платежа';

  @override
  String get paymentSuccessful => 'Оплата успешна';

  @override
  String get paymentFailed => 'Оплата не удалась';

  @override
  String get paymentPending => 'Ожидание оплаты';

  @override
  String get amount => 'Сумма';

  @override
  String get totalAmount => 'Общая сумма';

  @override
  String get payNow => 'Оплатить сейчас';

  @override
  String get earnings => 'Заработок';

  @override
  String get totalEarnings => 'Общий заработок';

  @override
  String get todayEarnings => 'Заработок за сегодня';

  @override
  String get weekEarnings => 'Заработок за неделю';

  @override
  String get monthEarnings => 'Заработок за месяц';

  @override
  String get transaction => 'Транзакция';

  @override
  String get transactionId => 'ID транзакции';

  @override
  String get transactionDate => 'Дата транзакции';

  @override
  String get transactionHistory => 'История транзакций';

  @override
  String get noTransactions => 'Нет транзакций';

  @override
  String get chat => 'Чат';

  @override
  String get messages => 'Сообщения';

  @override
  String get sendMessage => 'Отправить сообщение';

  @override
  String get typeMessage => 'Введите сообщение';

  @override
  String get noMessages => 'Нет сообщений';

  @override
  String get chatWith => 'Чат с';

  @override
  String get rateDriver => 'Оценить водителя';

  @override
  String get rateCompany => 'Оценить компанию';

  @override
  String get rateExperience => 'Оцените ваш опыт';

  @override
  String get howWasDriver => 'Как был водитель?';

  @override
  String get howWasService => 'Как был сервис?';

  @override
  String get leaveReview => 'Оставить отзыв';

  @override
  String get review => 'Отзыв';

  @override
  String get reviews => 'Отзывы';

  @override
  String get writeReview => 'Написать отзыв';

  @override
  String get submitRating => 'Отправить оценку';

  @override
  String get skipForNow => 'Пропустить пока';

  @override
  String get pleaseSelectRating => 'Пожалуйста, выберите оценку';

  @override
  String get ratingSubmitted => 'Оценка отправлена';

  @override
  String get ratingSubmittedSuccessfully => 'Оценка успешно отправлена';

  @override
  String get failedToSubmitRating => 'Не удалось отправить оценку';

  @override
  String get driverVerification => 'Проверка водителя';

  @override
  String get pendingVerification => 'Ожидание проверки';

  @override
  String get verified => 'Проверен';

  @override
  String get rejected => 'Отклонен';

  @override
  String get approve => 'Одобрить';

  @override
  String get reject => 'Отклонить';

  @override
  String get approveDriver => 'Одобрить водителя';

  @override
  String get rejectDriver => 'Отклонить водителя';

  @override
  String get verificationStatus => 'Статус проверки';

  @override
  String get noPendingVerifications => 'Нет ожидающих проверок';

  @override
  String get driverApproved => 'Водитель одобрен';

  @override
  String get driverRejected => 'Водитель отклонен';

  @override
  String get driverApprovedSuccessfully => 'Водитель успешно одобрен';

  @override
  String get driverRejectedSuccessfully => 'Водитель успешно отклонен';

  @override
  String get failedToUpdateVerification => 'Не удалось обновить проверку';

  @override
  String get rejectionReason => 'Причина отклонения';

  @override
  String get enterRejectionReason => 'Введите причину отклонения';

  @override
  String get vehicleInformation => 'Информация об автомобиле';

  @override
  String get driverLicense => 'Водительское удостоверение';

  @override
  String get licenseNumber => 'Номер удостоверения';

  @override
  String get licensePhoto => 'Фото удостоверения';

  @override
  String get viewLicense => 'Посмотреть удостоверение';

  @override
  String get helpCenter => 'Центр помощи';

  @override
  String get help => 'Помощь';

  @override
  String get support => 'Поддержка';

  @override
  String get contactSupport => 'Связаться с поддержкой';

  @override
  String get faq => 'Часто задаваемые вопросы';

  @override
  String get termsAndConditions => 'Условия использования';

  @override
  String get privacyPolicy => 'Политика конфиденциальности';

  @override
  String get about => 'О приложении';

  @override
  String get version => 'Версия';

  @override
  String get language => 'Язык';

  @override
  String get changeLanguage => 'Изменить язык';

  @override
  String get russian => 'Русский';

  @override
  String get english => 'English';

  @override
  String get theme => 'Тема';

  @override
  String get darkMode => 'Темная тема';

  @override
  String get lightMode => 'Светлая тема';

  @override
  String get accountSettings => 'Настройки аккаунта';

  @override
  String get editProfile => 'Редактировать профиль';

  @override
  String get changePassword => 'Изменить пароль';

  @override
  String get deleteAccount => 'Удалить аккаунт';

  @override
  String get confirmDeleteAccount => 'Вы уверены, что хотите удалить аккаунт?';

  @override
  String get logoutConfirm => 'Вы уверены, что хотите выйти?';

  @override
  String get logoutSuccess => 'Вы успешно вышли';

  @override
  String get updateAvailable => 'Доступно обновление';

  @override
  String get updateNow => 'Обновить сейчас';

  @override
  String get updateLater => 'Обновить позже';

  @override
  String get noInternetConnection => 'Нет подключения к интернету';

  @override
  String get checkInternetConnection => 'Проверьте подключение к интернету';

  @override
  String get connectionLost => 'Соединение потеряно';

  @override
  String get reconnecting => 'Переподключение...';

  @override
  String get somethingWentWrong => 'Что-то пошло не так';

  @override
  String get tryAgain => 'Попробуйте снова';

  @override
  String get errorOccurred => 'Произошла ошибка';

  @override
  String get unexpectedError => 'Неожиданная ошибка';

  @override
  String get requiredField => 'Обязательное поле';

  @override
  String get invalidInput => 'Неверный ввод';

  @override
  String get invalidEmail => 'Неверный email';

  @override
  String get invalidFormat => 'Неверный формат';

  @override
  String get fieldRequired => 'Поле обязательно';

  @override
  String get fieldTooShort => 'Поле слишком короткое';

  @override
  String get fieldTooLong => 'Поле слишком длинное';

  @override
  String get searchRadius => 'Радиус поиска';

  @override
  String searchRadiusKm(Object radius) {
    return 'Радиус поиска: $radius км';
  }

  @override
  String get nearbyDrivers => 'Водители поблизости';

  @override
  String get noDriversNearby => 'Нет водителей поблизости';

  @override
  String driversFound(Object count) {
    return 'Найдено водителей: $count';
  }

  @override
  String get cancelOrder => 'Отменить заказ';

  @override
  String get confirmCancelOrder => 'Вы уверены, что хотите отменить заказ?';

  @override
  String get orderCancelledSuccessfully => 'Заказ успешно отменен';

  @override
  String get cannotCancelOrder => 'Невозможно отменить заказ';

  @override
  String get startRide => 'Начать поездку';

  @override
  String get endRide => 'Завершить поездку';

  @override
  String get arrivedAtPickup => 'Прибыл к месту забора';

  @override
  String get arrivedAtDestination => 'Прибыл к месту назначения';

  @override
  String get pickupLocation => 'Место забора';

  @override
  String get dropoffLocation => 'Место высадки';

  @override
  String get destination => 'Пункт назначения';

  @override
  String get today => 'Сегодня';

  @override
  String get yesterday => 'Вчера';

  @override
  String get thisWeek => 'На этой неделе';

  @override
  String get thisMonth => 'В этом месяце';

  @override
  String get lastMonth => 'В прошлом месяце';

  @override
  String get filter => 'Фильтр';

  @override
  String get filterBy => 'Фильтровать по';

  @override
  String get sortBy => 'Сортировать по';

  @override
  String get all => 'Все';

  @override
  String get dateRange => 'Диапазон дат';

  @override
  String get from => 'От';

  @override
  String get to => 'До';

  @override
  String get apply => 'Применить';

  @override
  String get reset => 'Сбросить';

  @override
  String get noRidesFound => 'Поездки не найдены';

  @override
  String get rideHistoryEmpty => 'История поездок пуста';

  @override
  String get yourRideHistoryWillAppearHere =>
      'Ваша история поездок появится здесь';

  @override
  String get errorLoadingRideHistory => 'Ошибка загрузки истории поездок';

  @override
  String get pleaseLogIn => 'Пожалуйста, войдите';

  @override
  String get pleaseLogInToViewHistory =>
      'Пожалуйста, войдите, чтобы посмотреть историю';

  @override
  String get loginRequired => 'Требуется вход';

  @override
  String get youllSeeNotificationsHere =>
      'Вы увидите уведомления здесь, когда получите их';

  @override
  String get markAllAsRead => 'Отметить все как прочитанные';

  @override
  String get clearAll => 'Очистить все';

  @override
  String get fullName => 'Полное имя';

  @override
  String get phoneNumber => 'Номер телефона';

  @override
  String get emailAddress => 'Адрес электронной почты';

  @override
  String get uploadPhoto => 'Загрузить фото';

  @override
  String get takePhoto => 'Сделать фото';

  @override
  String get chooseFromGallery => 'Выбрать из галереи';

  @override
  String get removePhoto => 'Удалить фото';

  @override
  String get camera => 'Камера';

  @override
  String get gallery => 'Галерея';

  @override
  String get cameraPermission => 'Разрешение на камеру';

  @override
  String get cameraPermissionRequired => 'Требуется разрешение на камеру';

  @override
  String get storagePermission => 'Разрешение на хранилище';

  @override
  String get storagePermissionRequired => 'Требуется разрешение на хранилище';

  @override
  String get updating => 'Обновление...';

  @override
  String get saving => 'Сохранение...';

  @override
  String get deleting => 'Удаление...';

  @override
  String get uploading => 'Загрузка...';

  @override
  String get downloading => 'Скачивание...';

  @override
  String get processing => 'Обработка...';

  @override
  String get updatedSuccessfully => 'Успешно обновлено';

  @override
  String get savedSuccessfully => 'Успешно сохранено';

  @override
  String get deletedSuccessfully => 'Успешно удалено';

  @override
  String get uploadedSuccessfully => 'Успешно загружено';

  @override
  String get failedToUpdate => 'Не удалось обновить';

  @override
  String get failedToSave => 'Не удалось сохранить';

  @override
  String get failedToDelete => 'Не удалось удалить';

  @override
  String get failedToUpload => 'Не удалось загрузить';

  @override
  String get failedToLoad => 'Не удалось загрузить';

  @override
  String get areYouSure => 'Вы уверены?';

  @override
  String get thisActionCannotBeUndone => 'Это действие нельзя отменить';

  @override
  String get proceedWithCaution => 'Действуйте осторожно';

  @override
  String get minute => 'минута';

  @override
  String get minutes => 'минут';

  @override
  String get hour => 'час';

  @override
  String get hours => 'часов';

  @override
  String get day => 'день';

  @override
  String get days => 'дней';

  @override
  String get week => 'неделя';

  @override
  String get weeks => 'недель';

  @override
  String get month => 'месяц';

  @override
  String get months => 'месяцев';

  @override
  String get ago => 'назад';

  @override
  String get justNow => 'только что';

  @override
  String get now => 'сейчас';

  @override
  String get online => 'Онлайн';

  @override
  String get offline => 'Офлайн';

  @override
  String get away => 'Отошел';

  @override
  String get busy => 'Занят';

  @override
  String get available => 'Доступен';

  @override
  String get unavailable => 'Недоступен';

  @override
  String get onDuty => 'На смене';

  @override
  String get offDuty => 'Не на смене';
}
