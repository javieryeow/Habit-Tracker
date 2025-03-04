import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'custom_habit_page.dart';

class AddHabitPage extends StatefulWidget {
  const AddHabitPage({super.key});

  @override
  AddHabitPageState createState() => AddHabitPageState();
}

class AddHabitPageState extends State<AddHabitPage> {
  final Box habitBox = Hive.box('habitTracker');

  final List<String> _commonHabits = [
    "Exercise",
    "Meditation",
    "Reading",
    "Journaling",
    "Drinking Water",
    "Sleep Early",
    "Study",
    "Painting",
  ];

  // default values as placeholder
  void _addHabit(String habit) {
    habitBox.put(habit, {"category": "Health", "frequency": "Daily"});
    Navigator.pop(context);
  }

  void _goToCustomHabitPage() {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => const CustomHabitPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text("Select a Habit"),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Choose a Common Habit",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              // show list of common habits
              Expanded(
                child: ListView.builder(
                  itemCount: _commonHabits.length + 1,
                  itemBuilder: (context, index) {
                    if (index == _commonHabits.length) {
                      return GestureDetector(
                        onTap: _goToCustomHabitPage,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemGrey5,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text(
                              "➕ Add a Custom Habit!",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: CupertinoColors.activeGreen,
                              ),
                            ),
                          ),
                        ),
                      );
                    }

                    String habit = _commonHabits[index];

                    return GestureDetector(
                      onTap: () => _addHabit(habit),
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemGrey6,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          habit,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
