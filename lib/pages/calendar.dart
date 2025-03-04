import 'package:flutter/cupertino.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'habit_log_page.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  CalendarPageState createState() => CalendarPageState();
}

class CalendarPageState extends State<CalendarPage> {
  Box habitBox = Hive.box('habitTracker');
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // use hive listener to allow auto updating of hive
  @override
  void initState() {
    super.initState();
    _refreshCalendar();
    habitBox.listenable().addListener(_hiveListener);
  }

  void _refreshCalendar() {
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {}); // refresh calendar ui when app restarts
      });
    }
  }

  void _hiveListener() {
    if (mounted) {
      setState(() {});
    }
  }

  // remove hive listener when widget is not mounted to prevent error from state changes due to pageview
  @override
  void dispose() {
    habitBox.listenable().removeListener(_hiveListener);
    super.dispose();
  }

  bool _isDayFullyCompleted(DateTime day) {
    String dateKey = DateFormat('yyyy-MM-dd').format(day);
    var habitsForDay = habitBox.get(dateKey, defaultValue: {}) as Map?;

    if (habitsForDay == null || habitsForDay.isEmpty) {
      return false;
    }

    return habitsForDay.values.every((completed) => completed == true);
  }

  List<String> _getAllHabits() {
    return habitBox.keys
        .where((key) => !key.contains('-')) //filter for habits only
        .cast<String>()
        .toList();
  }

  List<String> _getIncompleteHabits(DateTime day) {
    String dateKey = DateFormat('yyyy-MM-dd').format(day);
    var habitsForDay = habitBox.get(dateKey, defaultValue: {}) as Map?;

    if (habitsForDay == null || habitsForDay.isEmpty) {
      return _getAllHabits(); // if no data exists, assume habits are uncompleted
    }

    return _getAllHabits()
        .where((habit) => !(habitsForDay[habit] ?? false))
        .toList();
  }

  void _openHabitLogPage(DateTime selectedDay) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => HabitLogPage(selectedDay: selectedDay),
      ),
    ).then((_) {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {}); // ensure ui is updated
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Calendar View'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2023, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              calendarStyle: CalendarStyle(
                todayDecoration: const BoxDecoration(
                  color: CupertinoColors.systemBlue,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: const BoxDecoration(
                  color: Color(0xFFFFB347),
                  shape: BoxShape.circle,
                ),
              ),
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  if (_isDayFullyCompleted(day)) {
                    return Container(
                      margin: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        color: CupertinoColors.activeGreen,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${day.day}',
                          style: const TextStyle(color: CupertinoColors.white),
                        ),
                      ),
                    );
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 20),

            if (_selectedDay != null)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 253, 222, 178),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('MMMM dd, yyyy').format(_selectedDay!),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // handle overflow if list of habits is too long
                        Expanded(
                          child: SingleChildScrollView(
                            child:
                                _isDayFullyCompleted(_selectedDay!)
                                    ? const Text(
                                      "✅ You have completed all habits for today. Good job!",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: CupertinoColors.systemGreen,
                                      ),
                                    )
                                    : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "⚠️ You have not completed these habits:",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        ..._getIncompleteHabits(_selectedDay!)
                                            .map(
                                              (habit) => Text(
                                                "- $habit",
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                ),
                                              ),
                                            )
                                            .toList(),
                                      ],
                                    ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // view habit log for users to log their habits
                        Align(
                          alignment: Alignment.bottomRight,
                          child: CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () => _openHabitLogPage(_selectedDay!),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text(
                                  "View Habit Logs",
                                  style: TextStyle(fontSize: 16),
                                ),
                                SizedBox(width: 6),
                                Icon(CupertinoIcons.arrow_right),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
