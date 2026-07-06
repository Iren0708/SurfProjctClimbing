/// Тексты SCR-001 / LOGIC-001.
abstract final class AuthMessages {
  static const phoneRequired = 'Введите номер телефона';
  static const phoneInvalid = 'Похоже, номер введён не полностью';
  static const phoneHint = 'Без пароля — входим по номеру телефона';
  static const loginFailed = 'Не удалось войти. Попробуйте ещё раз';
  static const codeInvalid = 'Код неверен или просрочен. Запросите новый код';
  static const tooManyAttempts = 'Слишком много попыток. Запросите новый код';
  static const nameInvalid =
      'Проверьте имя — кажется, тут лишние символы';
  static const networkLoadError =
      'Не удалось загрузить. Проверьте соединение и попробуйте снова.';
  static const serverError = 'Произошла ошибка. Попробуйте позже';
  static const actionError =
      'Не удалось выполнить. Проверьте соединение и повторите.';
}

/// Длина OTP по умолчанию (бэкенд: 4 цифры; допустимо 4–6 по OpenAPI).
abstract final class AuthConfig {
  static const int otpLength = 4;
  static const int nameMinLength = 1;
  static const int nameMaxLength = 100;
}
