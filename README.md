# 🚗 Trips App - Flutter Application

Приложение для управления поездками с интеграцией Firebase.

## 📱 Структура Приложения

```
lib/
├── main.dart                 # Точка входа
├── theme/
│   └── app_theme.dart       # Фиолетовая цветовая схема
├── providers/
│   ├── auth_provider.dart   # Аутентификация (Firebase Auth)
│   ├── trips_provider.dart  # Управление поездками
│   └── cars_provider.dart   # Управление машинами
├── routes/
│   └── app_router.dart      # Навигация (GoRouter)
├── screens/
│   ├── auth/
│   │   ├── start_page.dart      # Вход по номеру
│   │   └── sms_page.dart        # Верификация SMS
│   ├── home/
│   │   ├── home_page.dart       # Главная страница
│   │   └── fill_profile_page.dart # Заполнение профиля
│   ├── trips/
│   │   ├── my_trips_page.dart   # Мои поездки
│   │   ├── trip_page.dart       # Детали поездки
│   │   ├── create_trip_page.dart # Создание поездки
│   │   └── search_trip_page.dart # Поиск поездок
│   ├── cars/
│   │   ├── add_car_page.dart    # Добавление машины
│   │   ├── select_mark_widget.dart # Выбор марки
│   │   └── select_model_widget.dart # Выбор модели
│   └── city/
│       └── city_search_page.dart # Поиск города
├── models/
│   ├── user_model.dart      # Модель пользователя
│   ├── trip_model.dart      # Модель поездки
│   └── car_model.dart       # Модель машины
└── services/
    ├── firestore_service.dart # Работа с Firestore
    └── storage_service.dart   # Работа с Firebase Storage
```

## 🎨 Цветовая Схема

- **Primary (Фиолетовый):** `#7C3AED`
- **Secondary (Голубой):** `#06B6D4`
- **Background (Белый):** `#FFFFFF`
- **Text (Чёрный):** `#000000`
- **Disabled (Серый):** `#D1D5DB`

## 🔥 Firebase Структура

```
firestore/
├── users/{uid}
│   ├── name: string
│   ├── phone: string
│   ├── profileImage: string
│   └── createdAt: timestamp
├── trips/{tripId}
│   ├── from: string
│   ├── to: string
│   ├── date: timestamp
│   ├── passengers: array
│   ├── car: reference
│   └── createdBy: reference
├── cars/{carId}
│   ├── mark: string
│   ├── model: string
│   ├── regNumber: string
│   ├── image: string
│   └── owner: reference
└── cities/{cityId}
    ├── name: string
    └── description: string
```

## 📋 Страницы Приложения

### 1. **StartPage** - Вход
- Ввод номера телефона
- Кнопка "Войти" (фиолетовая)
- Переход на SMSPage

### 2. **SMSPage** - Верификация
- Ввод SMS кода (6 цифр)
- Кнопка "Подтвердить"
- Переход на HomePage

### 3. **HomePage** - Главная
- Изображение: люди с рюкзаками
- Поле: Откуда (FROM)
- Поле: Куда (TO)
- Кнопка: "Найти поездку"
- Иконки: Мои поездки, Машины

### 4. **FillProfilePage** - Профиль
- Аватар (фото)
- Поле: Имя
- Кнопка: "Сохранить"

### 5. **MyTrips** - Мои поездки
- Список поездок
- Выбранная поездка выделена фиолетовым
- Переход на TripPage

### 6. **TripPage** - Детали поездки
- Информация о маршруте
- Дата, время, пассажиры
- Кнопка: "Пересоединиться в Поездку"

### 7. **CreateTrip** - Создание поездки
- Выбор даты
- Выбор машины
- Кнопка: "Добавить Машину"
- Кнопка: "Создать Поездку"

### 8. **AddCar** - Добавление машины
- Фото машины (камера)
- Поле: Марка
- Поле: Модель
- Поле: Регистрационный номер
- Кнопка: "Сохранить"

### 9. **SelectMarkWidget** - Выбор марки
- Список марок машин
- Выбор и возврат

### 10. **SelectModelWidget** - Выбор модели
- Список моделей
- Выбор и возврат

### 11. **CitySearchPage** - Поиск города
- Поле поиска
- Список городов
- Переход на SearchTrip

### 12. **SearchTrip** - Поиск поездок
- Поля: FROM, TO, Дата
- Список найденных поездок

## 🚀 Установка и Запуск

### Требования
- Flutter 3.13+
- Dart 3.0+
- Firebase Project

### Шаги

1. **Клонирование проекта**
```bash
cd flutter_trips_app
```

2. **Установка зависимостей**
```bash
flutter pub get
```

3. **Генерация Firebase Options**
```bash
flutterfire configure
```

4. **Запуск приложения**
```bash
flutter run
```

## 📦 Зависимости

- `firebase_core` - Firebase инициализация
- `firebase_auth` - Аутентификация
- `cloud_firestore` - База данных
- `firebase_storage` - Хранилище файлов
- `provider` - State management
- `go_router` - Навигация
- `image_picker` - Загрузка фото
- `intl` - Интернационализация

## 🔐 Firebase Setup

1. Создать Firebase Project
2. Включить Phone Authentication
3. Включить Firestore Database
4. Включить Firebase Storage
5. Скачать `google-services.json` (Android) и `GoogleService-Info.plist` (iOS)

## 📝 Примеры Использования

### Вход по номеру телефона
```dart
await authProvider.signInWithPhoneNumber('+1234567890');
```

### Верификация SMS
```dart
await authProvider.verifySMSCode(verificationId, smsCode);
```

### Создание поездки
```dart
await tripsProvider.createTrip(
  from: 'New York',
  to: 'Boston',
  date: DateTime.now(),
  carId: 'car123',
);
```

### Добавление машины
```dart
await carsProvider.addCar(
  mark: 'Toyota',
  model: 'Camry',
  regNumber: 'ABC123',
  imageUrl: 'url',
);
```

## 🎯 Статус Разработки

- ✅ Структура проекта
- ✅ Theme (фиолетовая схема)
- ✅ Auth Provider
- ✅ Trips Provider (в процессе)
- ✅ Cars Provider (в процессе)
- ⏳ Все страницы (в процессе)
- ⏳ Навигация (в процессе)
- ⏳ Тестирование

## 📞 Контакты

Для вопросов и предложений создавайте Issues в репозитории.

---

**Разработано с ❤️ на Flutter**
