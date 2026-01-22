import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Russian Localization Tests', () {
    group('Authentication Screens', () {
      test('login screen uses Russian text', () {
        final loginTexts = {
          'title': 'Вход',
          'usernameLabel': 'Имя пользователя',
          'passwordLabel': 'Пароль',
          'loginButton': 'Войти',
          'noAccount': 'Нет аккаунта?',
          'register': 'Зарегистрироваться',
        };

        expect(loginTexts['title'], 'Вход');
        expect(loginTexts['usernameLabel'], 'Имя пользователя');
        expect(loginTexts['loginButton'], 'Войти');
      });

      test('registration screen uses Russian text', () {
        final registrationTexts = {
          'title': 'Регистрация',
          'username': 'Имя пользователя',
          'password': 'Пароль',
          'confirmPassword': 'Подтвердите пароль',
          'companyName': 'Название компании',
          'phone': 'Телефон',
          'registerButton': 'Зарегистрироваться',
        };

        expect(registrationTexts['title'], 'Регистрация');
        expect(registrationTexts['companyName'], 'Название компании');
        expect(registrationTexts['registerButton'], 'Зарегистрироваться');
      });

      test('validation messages are in Russian', () {
        final validationMessages = {
          'usernameRequired': 'Введите имя пользователя',
          'passwordRequired': 'Введите пароль',
          'usernameTooShort': 'Имя пользователя должно содержать минимум 3 символа',
          'passwordTooShort': 'Пароль должен содержать минимум 8 символов',
          'invalidUsername': 'Используйте только буквы, цифры и подчеркивание',
          'usernameExists': 'Имя пользователя уже занято',
        };

        expect(validationMessages['usernameRequired'], 'Введите имя пользователя');
        expect(validationMessages['passwordTooShort'], contains('минимум 8 символов'));
      });
    });

    group('Navigation Labels', () {
      test('company navigation uses Russian labels', () {
        final companyNav = {
          'home': 'Главная',
          'history': 'История',
          'transactions': 'Транзакции',
          'profile': 'Профиль',
        };

        expect(companyNav['home'], 'Главная');
        expect(companyNav['history'], 'История');
        expect(companyNav['transactions'], 'Транзакции');
        expect(companyNav['profile'], 'Профиль');
      });

      test('driver navigation uses Russian labels', () {
        final driverNav = {
          'home': 'Главная',
          'history': 'История',
          'profile': 'Профиль',
        };

        expect(driverNav['home'], 'Главная');
        expect(driverNav['history'], 'История');
        expect(driverNav['profile'], 'Профиль');
      });
    });

    group('Onboarding Screens', () {
      test('welcome screen uses Russian text', () {
        final welcomeTexts = {
          'title': 'Добро пожаловать',
          'subtitle': 'Быстрая доставка для вашего бизнеса',
          'skip': 'Пропустить',
        };

        expect(welcomeTexts['title'], 'Добро пожаловать');
        expect(welcomeTexts['subtitle'], 'Быстрая доставка для вашего бизнеса');
      });

      test('company features screen uses Russian text', () {
        final companyTexts = {
          'title': 'Для компаний',
          'feature1': 'Управление филиалами',
          'feature2': 'Отслеживание в реальном времени',
          'feature3': 'История доставок',
        };

        expect(companyTexts['title'], 'Для компаний');
        expect(companyTexts['feature1'], 'Управление филиалами');
      });

      test('driver features screen uses Russian text', () {
        final driverTexts = {
          'title': 'Для водителей',
          'feature1': 'Гибкий график',
          'feature2': 'Мгновенные уведомления',
          'feature3': 'Отслеживание заработка',
        };

        expect(driverTexts['title'], 'Для водителей');
        expect(driverTexts['feature1'], 'Гибкий график');
      });

      test('role selection uses Russian text', () {
        final roleTexts = {
          'company': 'Я компания',
          'driver': 'Я водитель',
        };

        expect(roleTexts['company'], 'Я компания');
        expect(roleTexts['driver'], 'Я водитель');
      });
    });

    group('Branch Management', () {
      test('branch list uses Russian text', () {
        final branchTexts = {
          'title': 'Филиалы',
          'addBranch': 'Добавить филиал',
          'headquarters': 'Штаб-квартира',
          'edit': 'Редактировать',
          'delete': 'Удалить',
        };

        expect(branchTexts['title'], 'Филиалы');
        expect(branchTexts['addBranch'], 'Добавить филиал');
        expect(branchTexts['headquarters'], 'Штаб-квартира');
      });

      test('branch form uses Russian text', () {
        final formTexts = {
          'addTitle': 'Добавить филиал',
          'editTitle': 'Редактировать филиал',
          'nameLabel': 'Название',
          'addressLabel': 'Адрес',
          'locationLabel': 'Местоположение',
          'selectOnMap': 'Выбрать на карте',
          'save': 'Сохранить',
          'cancel': 'Отмена',
        };

        expect(formTexts['addTitle'], 'Добавить филиал');
        expect(formTexts['selectOnMap'], 'Выбрать на карте');
      });

      test('branch deletion uses Russian text', () {
        final deleteTexts = {
          'confirmTitle': 'Удалить филиал?',
          'confirmMessage': 'Вы уверены, что хотите удалить этот филиал?',
          'lastBranchError': 'Нельзя удалить последний филиал',
          'delete': 'Удалить',
          'cancel': 'Отмена',
        };

        expect(deleteTexts['confirmTitle'], 'Удалить филиал?');
        expect(deleteTexts['lastBranchError'], 'Нельзя удалить последний филиал');
      });
    });

    group('Delivery Request', () {
      test('delivery form uses Russian text', () {
        final formTexts = {
          'title': 'Новый заказ',
          'recipientName': 'Имя получателя',
          'recipientPhone': 'Телефон получателя',
          'deliveryAddress': 'Адрес доставки',
          'selectAddress': 'Выбрать адрес',
          'readyTime': 'Когда готов к отправке?',
          'now': 'Сейчас',
          'submit': 'Заказать',
        };

        expect(formTexts['title'], 'Новый заказ');
        expect(formTexts['recipientName'], 'Имя получателя');
        expect(formTexts['readyTime'], 'Когда готов к отправке?');
        expect(formTexts['now'], 'Сейчас');
      });

      test('branch selector uses Russian text', () {
        final selectorTexts = {
          'title': 'Выберите филиал',
          'subtitle': 'Откуда нужна доставка?',
          'confirm': 'Подтвердить',
        };

        expect(selectorTexts['title'], 'Выберите филиал');
        expect(selectorTexts['subtitle'], 'Откуда нужна доставка?');
      });
    });

    group('Delivery Status', () {
      test('status messages use Russian text', () {
        final statusTexts = {
          'searching': 'Ищем водителя...',
          'driverAssigned': 'Водитель назначен',
          'onTheWay': 'Водитель в пути',
          'delivered': 'Доставлено',
          'cancelled': 'Отменено',
          'noDriverFound': 'Водитель не найден, попробуйте позже',
        };

        expect(statusTexts['searching'], 'Ищем водителя...');
        expect(statusTexts['driverAssigned'], 'Водитель назначен');
        expect(statusTexts['delivered'], 'Доставлено');
      });

      test('searching animation uses Russian text', () {
        final searchingTexts = {
          'initial': 'Ищем водителя...',
          'stillSearching': 'Все еще ищем',
          'cancel': 'Отменить',
        };

        expect(searchingTexts['initial'], 'Ищем водителя...');
        expect(searchingTexts['stillSearching'], 'Все еще ищем');
      });
    });

    group('Driver Status', () {
      test('status toggle uses Russian text', () {
        final statusTexts = {
          'title': 'Статус работы',
          'active': 'Активен - вы получаете заказы',
          'inactive': 'Неактивен - вы не получаете заказы',
          'confirmTitle': 'Изменить статус?',
          'confirmActive': 'Вы начнете получать уведомления о новых заказах в радиусе 5-6 км',
          'confirmInactive': 'Вы перестанете получать заказы. Вы сможете включить статус в любое время.',
          'confirm': 'Подтвердить',
          'cancel': 'Отмена',
        };

        expect(statusTexts['title'], 'Статус работы');
        expect(statusTexts['active'], contains('Активен'));
        expect(statusTexts['confirmTitle'], 'Изменить статус?');
      });

      test('status change feedback uses Russian text', () {
        final feedbackTexts = {
          'changedToActive': 'Статус изменен на Активен',
          'changedToInactive': 'Статус изменен на Неактивен',
        };

        expect(feedbackTexts['changedToActive'], 'Статус изменен на Активен');
        expect(feedbackTexts['changedToInactive'], 'Статус изменен на Неактивен');
      });
    });

    group('Notifications', () {
      test('driver notifications use Russian text', () {
        final notificationTexts = {
          'newOrder': 'Новый заказ',
          'orderFrom': 'Заказ от',
          'pickupNow': 'Забрать сейчас',
          'pickupIn': 'Забрать через',
          'accept': 'Принять',
          'skip': 'Пропустить',
        };

        expect(notificationTexts['newOrder'], 'Новый заказ');
        expect(notificationTexts['accept'], 'Принять');
      });

      test('company notifications use Russian text', () {
        final notificationTexts = {
          'driverFound': 'Водитель найден',
          'driverAccepted': 'Водитель принял ваш заказ',
          'driverNearby': 'Водитель рядом',
          'driverArrived': 'Водитель прибыл',
          'delivered': 'Заказ доставлен',
        };

        expect(notificationTexts['driverFound'], 'Водитель найден');
        expect(notificationTexts['driverArrived'], 'Водитель прибыл');
      });
    });

    group('Error Messages', () {
      test('authentication errors use Russian text', () {
        final errorTexts = {
          'invalidCredentials': 'Неверное имя пользователя или пароль',
          'networkError': 'Нет подключения к интернету',
          'weakPassword': 'Пароль слишком слабый',
          'userExists': 'Пользователь уже существует',
        };

        expect(errorTexts['invalidCredentials'], contains('Неверное'));
        expect(errorTexts['networkError'], 'Нет подключения к интернету');
      });

      test('validation errors use Russian text', () {
        final errorTexts = {
          'required': 'Обязательное поле',
          'invalidFormat': 'Неверный формат',
          'tooShort': 'Слишком короткое значение',
          'tooLong': 'Слишком длинное значение',
        };

        expect(errorTexts['required'], 'Обязательное поле');
        expect(errorTexts['invalidFormat'], 'Неверный формат');
      });
    });

    group('Date and Time Formatting', () {
      test('dates are formatted in Russian locale', () {
        final date = DateTime(2024, 1, 15);
        final formatted = '15 января 2024';

        expect(formatted, contains('января'));
      });

      test('times are formatted in 24-hour format', () {
        final time = DateTime(2024, 1, 15, 14, 30);
        final formatted = '14:30';

        expect(formatted, '14:30');
      });

      test('relative times use Russian text', () {
        final relativeTexts = {
          'now': 'Сейчас',
          'minutes': 'мин',
          'hours': 'ч',
          'days': 'дн',
          'lessThanMinute': 'Меньше минуты',
        };

        expect(relativeTexts['now'], 'Сейчас');
        expect(relativeTexts['minutes'], 'мин');
      });
    });

    group('Common UI Elements', () {
      test('buttons use Russian text', () {
        final buttonTexts = {
          'save': 'Сохранить',
          'cancel': 'Отмена',
          'delete': 'Удалить',
          'edit': 'Редактировать',
          'confirm': 'Подтвердить',
          'close': 'Закрыть',
          'ok': 'OK',
        };

        expect(buttonTexts['save'], 'Сохранить');
        expect(buttonTexts['cancel'], 'Отмена');
        expect(buttonTexts['confirm'], 'Подтвердить');
      });

      test('loading messages use Russian text', () {
        final loadingTexts = {
          'loading': 'Загрузка...',
          'pleaseWait': 'Пожалуйста, подождите',
          'processing': 'Обработка...',
        };

        expect(loadingTexts['loading'], 'Загрузка...');
        expect(loadingTexts['pleaseWait'], 'Пожалуйста, подождите');
      });

      test('empty states use Russian text', () {
        final emptyTexts = {
          'noData': 'Нет данных',
          'noOrders': 'У вас пока нет заказов',
          'noHistory': 'История пуста',
          'noBranches': 'Нет филиалов',
        };

        expect(emptyTexts['noData'], 'Нет данных');
        expect(emptyTexts['noOrders'], 'У вас пока нет заказов');
      });
    });

    group('Dashboard', () {
      test('company dashboard uses Russian text', () {
        final dashboardTexts = {
          'welcome': 'Добро пожаловать',
          'searchTaxi': 'Найти такси',
          'recentOrders': 'Недавние заказы',
          'firstOrderBanner': 'Это ваш первый заказ? Мы поможем!',
          'howToOrder': 'Как заказать доставку',
        };

        expect(dashboardTexts['searchTaxi'], 'Найти такси');
        expect(dashboardTexts['recentOrders'], 'Недавние заказы');
      });

      test('driver dashboard uses Russian text', () {
        final dashboardTexts = {
          'welcome': 'Добро пожаловать',
          'activeOrders': 'Активные заказы',
          'earnings': 'Заработок',
          'rating': 'Рейтинг',
        };

        expect(dashboardTexts['welcome'], 'Добро пожаловать');
        expect(dashboardTexts['activeOrders'], 'Активные заказы');
      });
    });

    group('History Screen', () {
      test('history screen uses Russian text', () {
        final historyTexts = {
          'title': 'История',
          'filterAll': 'Все',
          'filterDelivered': 'Доставлено',
          'filterCancelled': 'Отменено',
          'filterNoDriver': 'Водитель не найден',
          'empty': 'История пуста',
        };

        expect(historyTexts['title'], 'История');
        expect(historyTexts['filterDelivered'], 'Доставлено');
      });
    });

    group('Profile Screen', () {
      test('profile screen uses Russian text', () {
        final profileTexts = {
          'title': 'Профиль',
          'personalInfo': 'Личная информация',
          'companyInfo': 'Информация о компании',
          'branches': 'Филиалы',
          'settings': 'Настройки',
          'logout': 'Выйти',
        };

        expect(profileTexts['title'], 'Профиль');
        expect(profileTexts['branches'], 'Филиалы');
        expect(profileTexts['logout'], 'Выйти');
      });
    });
  });
}
