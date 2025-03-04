import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'edit_habit_page.dart';
import 'add_habit_form.dart';

class HabitsPage extends StatefulWidget {
  const HabitsPage({super.key});

  @override
  HabitsPageState createState() => HabitsPageState();
}

class HabitsPageState extends State<HabitsPage> {
  final Box habitBox = Hive.box('habitTracker');

  void _openAddHabitPage() {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => const AddHabitPage()),
    ).then((_) {
      if (mounted) {
        setState(() {}); // refresh after adding habit
      }
    });
  }

  void _openEditHabitPage(String habit) {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => EditHabitPage(habitName: habit)),
    ).then((_) {
      if (mounted) {
        setState(() {}); // refresh after editing habit
      }
    });
  }

  List<String> _getUserHabits() {
    return habitBox.keys
        .where(
          (key) => !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(key),
        ) // ensure only habits are retrieved, and not dates
        .cast<String>()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    List<String> habits = _getUserHabits();

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Your Habits'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _openAddHabitPage,
          child: const Icon(
            CupertinoIcons.add,
            color: CupertinoColors.activeGreen,
          ),
        ),
      ),
      child: SafeArea(
        child:
            habits.isEmpty
                ? const Center(
                  child: Text('No habits yet. Tap + to add a habit!'),
                )
                : Padding(
                  padding: const EdgeInsets.all(16),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1, // square layout
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: habits.length,
                    itemBuilder: (context, index) {
                      String habit = habits[index];

                      return GestureDetector(
                        onTap: () => _openEditHabitPage(habit),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 255, 187, 91),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: CupertinoColors.systemGrey.withOpacity(
                                  0.5,
                                ),
                                blurRadius: 5,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text(
                                habit,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: CupertinoColors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
      ),
    );
  }
}
