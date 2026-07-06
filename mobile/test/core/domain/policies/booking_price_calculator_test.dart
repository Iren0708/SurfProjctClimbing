import 'package:flutter_test/flutter_test.dart';
import 'package:vertical_mobile/core/api/models/booking_models.dart';
import 'package:vertical_mobile/core/domain/policies/booking_price_calculator.dart';

void main() {
  group('BookingPriceCalculator', () {
    const price = 1200;
    const rentalPrice = 400;

    test('own equipment preview equals slot price', () {
      final breakdown = BookingPriceCalculator.preview(
        price: price,
        rentalPrice: rentalPrice,
        equipment: Equipment.own,
      );

      expect(breakdown.isValid, isTrue);
      expect(breakdown.trainingPrice, 1200);
      expect(breakdown.rentalPrice, 0);
      expect(breakdown.total, 1200);
    });

    test('rental equipment preview adds rental price', () {
      final breakdown = BookingPriceCalculator.preview(
        price: price,
        rentalPrice: rentalPrice,
        equipment: Equipment.rental,
      );

      expect(breakdown.isValid, isTrue);
      expect(breakdown.trainingPrice, 1200);
      expect(breakdown.rentalPrice, 400);
      expect(breakdown.total, 1600);
    });

    test('invalid price blocks preview', () {
      final breakdown = BookingPriceCalculator.preview(
        price: -1,
        rentalPrice: rentalPrice,
        equipment: Equipment.own,
      );

      expect(breakdown.isValid, isFalse);
      expect(BookingPriceCalculator.hasValidPrice(null), isFalse);
    });

    test('exposes offline payment hint', () {
      expect(
        BookingPriceCalculator.offlinePaymentHint,
        contains('Оплата на месте'),
      );
    });
  });
}
