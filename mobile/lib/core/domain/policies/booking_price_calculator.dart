import 'package:vertical_mobile/core/api/models/booking_models.dart';

class BookingPriceBreakdown {
  const BookingPriceBreakdown({
    required this.trainingPrice,
    required this.rentalPrice,
    required this.total,
    required this.isValid,
  });

  final int trainingPrice;
  final int rentalPrice;
  final int total;
  final bool isValid;
}

/// Превью цены до createBooking (LOGIC-003). Итог брони — только `price_total` с API.
class BookingPriceCalculator {
  const BookingPriceCalculator._();

  static const offlinePaymentHint =
      'Оплата на месте: наличные или перевод на карту.';

  static bool hasValidPrice(int? price) {
    return price != null && price >= 0;
  }

  static BookingPriceBreakdown preview({
    required int price,
    required int rentalPrice,
    required Equipment equipment,
  }) {
    if (!hasValidPrice(price)) {
      return const BookingPriceBreakdown(
        trainingPrice: 0,
        rentalPrice: 0,
        total: 0,
        isValid: false,
      );
    }

    final normalizedRental = rentalPrice < 0 ? 0 : rentalPrice;
    final rentalAddon =
        equipment == Equipment.rental ? normalizedRental : 0;

    return BookingPriceBreakdown(
      trainingPrice: price,
      rentalPrice: rentalAddon,
      total: price + rentalAddon,
      isValid: true,
    );
  }
}
