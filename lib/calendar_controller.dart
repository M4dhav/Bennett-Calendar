import 'package:googleapis/calendar/v3.dart';

class CalendarClient {
  // For storing the CalendarApi object, this can be used
  // for performing all the operations

  static CalendarApi? calendar;

  // For creating a new calendar event
  Future<Map<String, String>?> insert({
    required String title,
    required String description,
    required String location,
    required DateTime startTime,
    required DateTime endTime,
    required String calendarId,
  }) async {
    Map<String, String>? eventData;

    Event event = Event();

    event.summary = title;
    event.description = description;
    event.location = location;
    event.recurrence = ["RRULE:FREQ=WEEKLY;COUNT=22"];
    event.reminders = EventReminders(overrides: [
      EventReminder(method: "popup", minutes: 30),
      EventReminder(method: "popup", minutes: 10),
      EventReminder(method: "popup", minutes: 5),
    ], useDefault: false);

    EventDateTime start = EventDateTime();
    start.dateTime = startTime;
    start.timeZone = "Asia/Kolkata";
    event.start = start;

    EventDateTime end = EventDateTime();
    end.timeZone = "Asia/Kolkata";
    end.dateTime = endTime;
    event.end = end;

    // await calendar?.calendars.insert(Calendar());

    await calendar?.events.insert(
      event,
      calendarId,
    );

    return eventData;
  }

  Future<String> createCalendar() async {
    Calendar newCalendar = Calendar();
    newCalendar.summary = "Bennett Odd Semester 2024-25 Calendar";
    newCalendar.timeZone = "Asia/Kolkata";

    Calendar? createdCalendar = await calendar?.calendars.insert(newCalendar);

    return createdCalendar!.id!;
  }
}
