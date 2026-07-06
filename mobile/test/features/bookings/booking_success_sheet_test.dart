import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vertical_mobile/core/api/models/booking_models.dart';
import 'package:vertical_mobile/features/bookings/domain/booking_flow_messages.dart';
import 'package:vertical_mobile/features/bookings/domain/booking_success_messages.dart';
import 'package:vertical_mobile/features/bookings/presentation/success/booking_success_sheet.dart';

import '../../support/slot_test_data.dart';

void main() {
  group('BookingSuccessSheet', () {
    late CreateBookingResponse booking;

    setUp(() {
      final slot = testSlot();
      booking = CreateBookingResponse(
        id: 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
        slotId: slot.id,
        clientId: 'cccccccc-cccc-cccc-cccc-cccccccccccc',
        equipment: Equipment.own,
        status: BookingStatus.active,
        priceTotal: 1200,
        createdAt: DateTime.utc(2026, 7, 10, 10),
        isFirstBooking: false,
        reminderHours: const [24, 2],
        slot: slot,
      );
    });

    testWidgets('shows booking summary and payment hint', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return TextButton(
                  onPressed: () => showBookingSuccessSheet(
                    context: context,
                    booking: booking,
                  ),
                  child: const Text('open'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text(BookingSuccessMessages.title), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
      expect(find.textContaining('Инструктор:'), findsOneWidget);
      expect(find.text(BookingFlowMessages.ownEquipment), findsOneWidget);
      expect(find.textContaining('Итого:'), findsOneWidget);
      expect(find.textContaining('Оплата на месте'), findsOneWidget);
      expect(find.text(BookingSuccessMessages.myBookings), findsOneWidget);
      expect(find.text(BookingSuccessMessages.done), findsOneWidget);
    });

    testWidgets('my bookings button returns myBookings action', (tester) async {
      BookingSuccessAction? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return TextButton(
                  onPressed: () async {
                    result = await showBookingSuccessSheet(
                      context: context,
                      booking: booking,
                    );
                  },
                  child: const Text('open'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(BookingSuccessMessages.myBookings));
      await tester.pumpAndSettle();

      expect(result, BookingSuccessAction.myBookings);
    });

    testWidgets('done button returns done action', (tester) async {
      BookingSuccessAction? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return TextButton(
                  onPressed: () async {
                    result = await showBookingSuccessSheet(
                      context: context,
                      booking: booking,
                    );
                  },
                  child: const Text('open'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(BookingSuccessMessages.done));
      await tester.pumpAndSettle();

      expect(result, BookingSuccessAction.done);
    });

    testWidgets('dismiss returns done action', (tester) async {
      BookingSuccessAction? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return TextButton(
                  onPressed: () async {
                    result = await showBookingSuccessSheet(
                      context: context,
                      booking: booking,
                    );
                  },
                  child: const Text('open'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(20, 20));
      await tester.pumpAndSettle();

      expect(result, BookingSuccessAction.done);
    });
  });
}
