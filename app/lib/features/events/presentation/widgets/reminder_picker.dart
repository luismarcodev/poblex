import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

/// Opens the platform date and time pickers, constrained so the result is
/// always before [eventStart] — mirrors the backend's own
/// `acceptsReminderAt` rule, so a client-side pick can never be rejected for
/// landing after the event has already started.
///
/// Returns `null` if the user backs out of either step.
Future<DateTime?> pickEventReminderTime(
  BuildContext context, {
  required DateTime eventStart,
}) async {
  final AppLocalizations l10n = AppLocalizations.of(context);
  final DateTime now = DateTime.now();
  if (!eventStart.isAfter(now)) return null;

  final DateTime? date = await showDatePicker(
    context: context,
    initialDate: now,
    firstDate: now,
    lastDate: eventStart,
    helpText: l10n.eventPickReminderTitle,
  );
  if (date == null || !context.mounted) return null;

  final TimeOfDay? time = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(now),
    helpText: l10n.eventPickReminderTitle,
  );
  if (time == null) return null;

  final DateTime picked = DateTime(
    date.year,
    date.month,
    date.day,
    time.hour,
    time.minute,
  );

  // The two pickers are independent: picking today's date and an earlier
  // time than "now" would otherwise silently produce a reminder in the past.
  // Clamping to the event start covers the other edge, matching the backend.
  if (picked.isBefore(now)) return now.add(const Duration(minutes: 1));
  if (picked.isAfter(eventStart)) return null;
  return picked;
}
