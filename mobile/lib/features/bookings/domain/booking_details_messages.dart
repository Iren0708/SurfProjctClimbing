/// Тексты SCR-006 и BS-003.
abstract final class BookingDetailsMessages {
  static const title = 'Детали записи';
  static const cancelAction = 'Отменить запись';
  static const cancelRule =
      'Отмена не позднее чем за 2 часа до старта — место освобождается. '
      'Позже — место остаётся за вами, но штрафов нет.';
  static const reasonPrefix = 'Причина:';
  static const slotStarted = 'Тренировка уже началась — отмена недоступна';
  static const alreadyCancelled = 'Запись уже отменена';

  static const cancelSheetTitle = 'Отменить запись?';
  static const confirmCancel = 'Да, отменить';
  static const keepBooking = 'Не отменять';
  static const earlyCancelHint =
      'Место освободится — другие смогут записаться.';
  static const lateCancelHint =
      'Место останется за вами (правило 2 часов). Штраф не взимается.';

  static const earlyCancelSuccess = 'Бронь отменена';
  static const lateCancelSuccess =
      'Поздняя отмена: место не освобождено (правило 2 часов). '
      'Штраф не взимается.';
  static const alreadyCancelledSnack = 'Запись уже отменена';
  static const cancelGenericError =
      'Не удалось отменить запись. Попробуйте ещё раз.';
  static const cancelNetworkError =
      'Не удалось выполнить. Проверьте соединение и повторите.';
}
