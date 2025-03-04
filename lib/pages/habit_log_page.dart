import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class HabitLogPage extends StatefulWidget {
  final DateTime selectedDay;
  const HabitLogPage({super.key, required this.selectedDay});

  @override
  HabitLogPageState createState() => HabitLogPageState();
}

class HabitLogPageState extends State<HabitLogPage> {
  late Box habitBox;

  @override
  void initState() {
    super.initState();
    habitBox = Hive.box('habitTracker');
  }

  // retrieve list of user defined habits from hive
  List<String> _getUserHabits() {
    return habitBox.keys
        .cast<String>()
        .where((key) => !key.contains('-'))
        .toList();
  }

  // retrieve completed habits for given day
  Map<String, bool> _getHabitsForDay() {
    String dateKey = DateFormat('yyyy-MM-dd').format(widget.selectedDay);
    var habitsForDay = habitBox.get(dateKey, defaultValue: {});

    if (habitsForDay is Map<dynamic, dynamic>) {
      return Map<String, bool>.from(
        habitsForDay.map(
          (key, value) => MapEntry(key.toString(), value as bool),
        ),
      );
    }
    return {};
  }

  // toggle habit completion and store in hive
  void _toggleHabitCompletion(String habit) {
    String dateKey = DateFormat('yyyy-MM-dd').format(widget.selectedDay);
    Map<String, bool> habitsForDay = _getHabitsForDay();

    setState(() {
      habitsForDay[habit] = !(habitsForDay[habit] ?? false);
      habitBox.put(dateKey, Map<String, bool>.from(habitsForDay));
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> allHabits = _getUserHabits();
    Map<String, bool> loggedHabits = _getHabitsForDay();

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          DateFormat('MMMM dd, yyyy').format(widget.selectedDay),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Text(
              'Mark your habits for today',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            Expanded(
              child:
                  allHabits.isEmpty
                      ? const Center(
                        child: Text(
                          'No habits to track. Add habits in the "Habits" tab.',
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                      : ListView.builder(
                        itemCount: allHabits.length,
                        itemBuilder: (context, index) {
                          String habit = allHabits[index];
                          bool isCompleted = loggedHabits[habit] ?? false;

                          return GestureDetector(
                            onTap: () => _toggleHabitCompletion(habit),
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 5,
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 20,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isCompleted
                                        ? CupertinoColors.activeGreen
                                            .withOpacity(0.8)
                                        : CupertinoColors.systemGrey5,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    habit,
                                    style: TextStyle(
                                      fontSize: 18,
                                      color:
                                          isCompleted
                                              ? CupertinoColors.white
                                              : CupertinoColors.black,
                                    ),
                                  ),
                                  Icon(
                                    isCompleted
                                        ? CupertinoIcons
                                            .check_mark_circled_solid
                                        : CupertinoIcons.circle,
                                    color:
                                        isCompleted
                                            ? CupertinoColors.white
                                            : CupertinoColors.systemGrey,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: CupertinoButton.filled(
                onPressed: () => Navigator.pop(context),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
