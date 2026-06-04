import 'package:flutter/material.dart';

import 'fx_input_decoration.dart';

/// Display and selection mode for [FxDateTimePicker].
enum FxDateTimePickerMode {
  /// Selects and displays only the calendar date.
  date,

  /// Selects and displays only the time of day.
  time,

  /// Selects and displays both calendar date and time of day.
  dateTime,
}

/// Shows a date picker and returns the selected date.
typedef FxDatePickerDelegate =
    Future<DateTime?> Function(
      BuildContext context,
      DateTime? selectedDate,
      DateTime firstDate,
      DateTime lastDate,
    );

/// Shows a time picker and returns the selected time.
typedef FxTimePickerDelegate =
    Future<TimeOfDay?> Function(BuildContext context, TimeOfDay initialTime);

/// A desktop date/time picker comparable to Xojo's DesktopDateTimePicker.
///
/// The control renders as a button-like field instead of a plain text input.
/// By default it uses Flutter's Material date and time picker APIs.
class FxDateTimePicker extends StatelessWidget {
  /// Creates an FxDesktop date/time picker.
  const FxDateTimePicker({
    super.key,
    required this.label,
    this.value,
    this.onChanged,
    this.mode = FxDateTimePickerMode.date,
    this.enabled = true,
    this.nullable = true,
    this.firstDate,
    this.lastDate,
    this.currentDate,
    this.helpText,
    this.errorText,
    this.reserveSupportingTextSpace = false,
    this.datePicker,
    this.timePicker,
  });

  /// Visible field label.
  final String label;

  /// Current selected value.
  ///
  /// A null value is displayed as an empty picker prompt when [nullable] is
  /// true. Time-only mode stores the selected time in a [DateTime] whose date
  /// part is preserved from [value], or from [currentDate] when [value] is null.
  final DateTime? value;

  /// Called when the selected value changes.
  final ValueChanged<DateTime?>? onChanged;

  /// Whether the control picks a date, a time, or both.
  final FxDateTimePickerMode mode;

  /// Whether the picker can be opened.
  final bool enabled;

  /// Whether a selected value can be cleared.
  final bool nullable;

  /// Earliest date that can be selected by the default date picker.
  final DateTime? firstDate;

  /// Latest date that can be selected by the default date picker.
  final DateTime? lastDate;

  /// Date used as the default initial value when [value] is null.
  final DateTime? currentDate;

  /// Helper/balloon-help style text.
  final String? helpText;

  /// Validation error text shown below the picker.
  final String? errorText;

  /// Whether to reserve one supporting-text line when no helper or error is
  /// present.
  final bool reserveSupportingTextSpace;

  /// Optional date picker delegate for tests or custom integrations.
  final FxDatePickerDelegate? datePicker;

  /// Optional time picker delegate for tests or custom integrations.
  final FxTimePickerDelegate? timePicker;

  /// Stable map for AI/generator use.
  Map<String, Object?> toTemplateMap() {
    return {
      'component': 'FxDateTimePicker',
      'xojo_desktop_class': 'DesktopDateTimePicker',
      'mode': mode.name,
      'nullable': nullable,
      'enabled': enabled,
      'helpText': helpText,
      'errorText': errorText,
      'reserveSupportingTextSpace': reserveSupportingTextSpace,
    };
  }

  @override
  Widget build(BuildContext context) {
    final interactive = enabled && onChanged != null;
    final hasValue = value != null;
    final colorScheme = Theme.of(context).colorScheme;
    final displayValue = _formatValue(context);
    final emptyHint = _emptyHint();

    return Semantics(
      button: true,
      enabled: interactive,
      label: label,
      value: hasValue ? displayValue : null,
      child: InputDecorator(
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          errorText: errorText,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          helperText: fxEffectiveHelperText(
            helpText: helpText,
            errorText: errorText,
            reserveSupportingTextSpace: reserveSupportingTextSpace,
          ),
          hintText: hasValue ? null : emptyHint,
          isDense: true,
          labelText: label,
          suffixIcon: _buildSuffixIcon(context, interactive),
        ),
        isEmpty: !hasValue,
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: interactive ? () => _selectValue(context) : null,
          child: DefaultTextStyle(
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: enabled
                  ? colorScheme.onSurface
                  : colorScheme.onSurface.withValues(alpha: 0.38),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                hasValue ? displayValue : '',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget? _buildSuffixIcon(BuildContext context, bool interactive) {
    if (nullable && value != null && interactive) {
      return IconButton(
        tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
        onPressed: () => onChanged?.call(null),
        icon: const Icon(Icons.clear, size: 18),
      );
    }

    final icon = switch (mode) {
      FxDateTimePickerMode.date => Icons.calendar_today_outlined,
      FxDateTimePickerMode.time => Icons.schedule,
      FxDateTimePickerMode.dateTime => Icons.event,
    };
    return Icon(icon, size: 18);
  }

  Future<void> _selectValue(BuildContext context) async {
    final selection = switch (mode) {
      FxDateTimePickerMode.date => _selectDate(context),
      FxDateTimePickerMode.time => _selectTime(context),
      FxDateTimePickerMode.dateTime => _selectDateTime(context),
    };
    final nextValue = await selection;

    if (nextValue != null) {
      onChanged?.call(nextValue);
    }
  }

  Future<DateTime?> _selectDate(BuildContext context) async {
    final selectedDate = await _pickDate(context, value);
    if (selectedDate == null) {
      return null;
    }
    return DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
  }

  Future<DateTime?> _selectTime(BuildContext context) async {
    final baseDate = value ?? currentDate ?? DateTime.now();
    final selectedTime = await _pickTime(
      context,
      TimeOfDay.fromDateTime(baseDate),
    );
    if (selectedTime == null) {
      return null;
    }
    return _combineDateAndTime(baseDate, selectedTime);
  }

  Future<DateTime?> _selectDateTime(BuildContext context) async {
    final selectedDate = await _pickDate(context, value);
    if (selectedDate == null) {
      return null;
    }
    if (!context.mounted) {
      return null;
    }

    final selectedTime = await _pickTime(
      context,
      TimeOfDay.fromDateTime(value ?? currentDate ?? DateTime.now()),
    );
    if (selectedTime == null) {
      return null;
    }

    return _combineDateAndTime(selectedDate, selectedTime);
  }

  Future<DateTime?> _pickDate(BuildContext context, DateTime? selectedDate) {
    final effectiveFirstDate = firstDate ?? DateTime(1900);
    final effectiveLastDate = lastDate ?? DateTime(2100);
    final fallbackDate = currentDate ?? DateTime.now();
    final initialDate = _clampDate(
      selectedDate ?? fallbackDate,
      effectiveFirstDate,
      effectiveLastDate,
    );

    final picker = datePicker;
    if (picker != null) {
      return picker(
        context,
        selectedDate,
        effectiveFirstDate,
        effectiveLastDate,
      );
    }

    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: effectiveFirstDate,
      lastDate: effectiveLastDate,
      currentDate: currentDate,
    );
  }

  Future<TimeOfDay?> _pickTime(BuildContext context, TimeOfDay initialTime) {
    final picker = timePicker;
    if (picker != null) {
      return picker(context, initialTime);
    }

    return showTimePicker(
      context: context,
      initialTime: initialTime,
      initialEntryMode: TimePickerEntryMode.inputOnly,
    );
  }

  String _formatValue(BuildContext context) {
    final selectedValue = value;
    if (selectedValue == null) {
      return _emptyHint();
    }

    final localizations = MaterialLocalizations.of(context);
    final time = TimeOfDay.fromDateTime(selectedValue);
    return switch (mode) {
      FxDateTimePickerMode.date => localizations.formatCompactDate(
        selectedValue,
      ),
      FxDateTimePickerMode.time => localizations.formatTimeOfDay(time),
      FxDateTimePickerMode.dateTime =>
        '${localizations.formatCompactDate(selectedValue)} '
            '${localizations.formatTimeOfDay(time)}',
    };
  }

  String _emptyHint() {
    return switch (mode) {
      FxDateTimePickerMode.date => 'Select date',
      FxDateTimePickerMode.time => 'Select time',
      FxDateTimePickerMode.dateTime => 'Select date and time',
    };
  }

  static DateTime _combineDateAndTime(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  static DateTime _clampDate(
    DateTime date,
    DateTime firstDate,
    DateTime lastDate,
  ) {
    if (date.isBefore(firstDate)) {
      return firstDate;
    }
    if (date.isAfter(lastDate)) {
      return lastDate;
    }
    return date;
  }
}
