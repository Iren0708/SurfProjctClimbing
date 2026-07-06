/// Именованные маршруты приложения (SCR-* / shell).
abstract final class AppRoutes {
  static const splash = '/splash';
  static const auth = '/auth';
  static const slots = '/slots';
  static const bookings = '/bookings';
  static const profile = '/profile';

  static const slotDetails = '/slots/:slotId';
  static const slotBooking = '/slots/:slotId/book';
  static const bookingDetails = '/bookings/:bookingId';

  static String slotDetailsPath(String slotId) => '/slots/$slotId';

  static String slotBookingPath(String slotId) => '/slots/$slotId/book';

  static String bookingDetailsPath(String bookingId) => '/bookings/$bookingId';
}
