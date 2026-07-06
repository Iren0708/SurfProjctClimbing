enum AuthSessionStatus {
  unknown,
  unauthenticated,
  /// Токены выданы, но имя нового клиента ещё не сохранено (SCR-001 шаг 3).
  pendingProfile,
  authenticated,
}
