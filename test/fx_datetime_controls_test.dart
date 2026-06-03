import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fx_desktop/fx_desktop.dart';

void main() {
  group('FxDateTimePicker', () {
    testWidgets('renders nullable date, time, and dateTime modes', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: const [
                FxDateTimePicker(label: 'Date'),
                FxDateTimePicker(
                  label: 'Time',
                  mode: FxDateTimePickerMode.time,
                ),
                FxDateTimePicker(
                  label: 'Date and time',
                  mode: FxDateTimePickerMode.dateTime,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Date'), findsOneWidget);
      expect(find.text('Time'), findsOneWidget);
      expect(find.text('Date and time'), findsOneWidget);
      expect(find.text('Select date'), findsOneWidget);
      expect(find.text('Select time'), findsOneWidget);
      expect(find.text('Select date and time'), findsOneWidget);
    });

    testWidgets('date mode reports selected date without text entry', (
      tester,
    ) async {
      DateTime? changedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FxDateTimePicker(
              label: 'Due date',
              value: DateTime(2026, 6, 4, 15, 30),
              onChanged: (value) => changedValue = value,
              datePicker: (context, selectedDate, firstDate, lastDate) async {
                expect(selectedDate, DateTime(2026, 6, 4, 15, 30));
                expect(firstDate, DateTime(1900));
                expect(lastDate, DateTime(2100));
                return DateTime(2026, 7, 8, 9, 10);
              },
            ),
          ),
        ),
      );

      expect(find.byType(TextField), findsNothing);

      await tester.tap(find.byType(InkWell).first);
      await tester.pump();

      expect(changedValue, DateTime(2026, 7, 8));
    });

    testWidgets('time mode reports selected time on existing date', (
      tester,
    ) async {
      DateTime? changedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FxDateTimePicker(
              label: 'Start time',
              mode: FxDateTimePickerMode.time,
              value: DateTime(2026, 6, 4, 15, 30),
              onChanged: (value) => changedValue = value,
              timePicker: (context, initialTime) async {
                expect(initialTime, const TimeOfDay(hour: 15, minute: 30));
                return const TimeOfDay(hour: 8, minute: 45);
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('3:30 PM'));
      await tester.pump();

      expect(changedValue, DateTime(2026, 6, 4, 8, 45));
    });

    testWidgets('dateTime mode reports selected date and time', (tester) async {
      DateTime? changedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FxDateTimePicker(
              label: 'Appointment',
              mode: FxDateTimePickerMode.dateTime,
              value: DateTime(2026, 6, 4, 15, 30),
              onChanged: (value) => changedValue = value,
              datePicker: (context, selectedDate, firstDate, lastDate) async {
                return DateTime(2026, 8, 9);
              },
              timePicker: (context, initialTime) async {
                expect(initialTime, const TimeOfDay(hour: 15, minute: 30));
                return const TimeOfDay(hour: 10, minute: 15);
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(InkWell).first);
      await tester.pump();

      expect(changedValue, DateTime(2026, 8, 9, 10, 15));
    });

    testWidgets('clear button reports null for nullable values', (
      tester,
    ) async {
      DateTime? changedValue = DateTime(2026, 6, 4);
      var callbackCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FxDateTimePicker(
              label: 'Optional date',
              value: changedValue,
              onChanged: (value) {
                callbackCount += 1;
                changedValue = value;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byTooltip('Delete'));
      await tester.pump();

      expect(callbackCount, 1);
      expect(changedValue, isNull);
    });

    testWidgets('disabled picker ignores taps and has no clear action', (
      tester,
    ) async {
      DateTime? changedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FxDateTimePicker(
              label: 'Disabled date',
              value: DateTime(2026, 6, 4),
              enabled: false,
              onChanged: (value) => changedValue = value,
              datePicker: (context, selectedDate, firstDate, lastDate) async {
                return DateTime(2026, 7, 8);
              },
            ),
          ),
        ),
      );

      expect(find.byTooltip('Delete'), findsNothing);

      await tester.tap(find.byType(InkWell));
      await tester.pump();

      expect(changedValue, isNull);
    });

    test('exposes DesktopDateTimePicker template metadata', () {
      expect(
        const FxDateTimePicker(
          label: 'When',
          mode: FxDateTimePickerMode.dateTime,
          nullable: false,
          enabled: false,
        ).toTemplateMap(),
        {
          'component': 'FxDateTimePicker',
          'xojo_desktop_class': 'DesktopDateTimePicker',
          'mode': 'dateTime',
          'nullable': false,
          'enabled': false,
        },
      );
    });
  });
}
