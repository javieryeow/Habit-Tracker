import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/hive_flutter.dart';

class CustomHabitPage extends StatefulWidget {
  const CustomHabitPage({super.key});

  @override
  CustomHabitPageState createState() => CustomHabitPageState();
}

class CustomHabitPageState extends State<CustomHabitPage> {
  Box? habitBox;
  Box? settingsBox;

  final TextEditingController _habitController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _selectedCategory = "Health";
  String _selectedFrequency = "Daily";
  List<String> _categories = [];
  List<String> _frequencies = [];

  late Future<bool> _hiveInitialized;

  @override
  void initState() {
    super.initState();
    _hiveInitialized = _openHiveBoxes();
  }

  Future<bool> _openHiveBoxes() async {
    await Hive.openBox('habitTracker');
    await Hive.openBox('habitSettings');

    habitBox = Hive.box('habitTracker');
    settingsBox = Hive.box('habitSettings');

    _categories =
        settingsBox!
            .get(
              'categories',
              defaultValue: [
                "Health",
                "Mindfulness",
                "Productivity",
                "Self-care",
              ],
            )
            .cast<String>();

    _frequencies =
        settingsBox!
            .get(
              'frequencies',
              defaultValue: ["Daily", "3x a Week", "Weekends Only"],
            )
            .cast<String>();

    return true;
  }

  void _showPicker(BuildContext context, String type) {
    List<String> items = type == "Category" ? _categories : _frequencies;
    String selectedItem =
        type == "Category" ? _selectedCategory : _selectedFrequency;

    showCupertinoModalPopup(
      context: context,
      builder:
          (_) => Container(
            height: 250,
            color: CupertinoColors.systemBackground.resolveFrom(context),
            child: Column(
              children: [
                Container(
                  color: CupertinoColors.systemGrey5,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CupertinoButton(
                        child: const Text("Cancel"),
                        onPressed: () => Navigator.pop(context),
                      ),
                      CupertinoButton(
                        child: const Text("Done"),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: CupertinoPicker(
                    itemExtent: 40,
                    scrollController: FixedExtentScrollController(
                      initialItem: items.indexOf(selectedItem),
                    ),
                    onSelectedItemChanged: (index) {
                      setState(() {
                        if (type == "Category") {
                          _selectedCategory = items[index];
                        } else {
                          _selectedFrequency = items[index];
                        }
                      });
                    },
                    children:
                        items
                            .map(
                              (item) => GestureDetector(
                                onLongPress:
                                    () => _confirmDeleteItem(
                                      item,
                                      type,
                                    ), // allow long press to delete
                                child: Text(item),
                              ),
                            )
                            .toList(),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void _confirmDeleteItem(String item, String type) {
    showCupertinoDialog(
      context: context,
      builder:
          (context) => CupertinoAlertDialog(
            title: Text("Delete $type?"),
            content: Text("Are you sure you want to delete '$item'?"),
            actions: [
              CupertinoDialogAction(
                child: const Text("Cancel"),
                onPressed: () => Navigator.pop(context),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                child: const Text("Delete"),
                onPressed: () {
                  _deleteItem(item, type);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
    );
  }

  void _deleteItem(String item, String type) {
    setState(() {
      if (type == "Category") {
        _categories.remove(item);
        settingsBox!.put('categories', _categories);
        if (_selectedCategory == item) {
          _selectedCategory =
              _categories.isNotEmpty ? _categories.first : "None";
        }
      } else {
        _frequencies.remove(item);
        settingsBox!.put('frequencies', _frequencies);
        if (_selectedFrequency == item) {
          _selectedFrequency =
              _frequencies.isNotEmpty ? _frequencies.first : "None";
        }
      }
    });
  }

  void _showCustomPopup(BuildContext context, String type) {
    TextEditingController controller = TextEditingController();

    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text("Add Custom $type"),
          content: Column(
            children: [
              const SizedBox(height: 10),
              CupertinoTextField(
                controller: controller,
                placeholder: "Enter new $type",
              ),
            ],
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text("Add"),
              onPressed: () {
                String newValue = controller.text.trim();
                if (newValue.isNotEmpty) {
                  setState(() {
                    if (type == "Category") {
                      _categories.add(newValue);
                      _selectedCategory = newValue;
                      settingsBox!.put('categories', _categories);
                    } else {
                      _frequencies.add(newValue);
                      _selectedFrequency = newValue;
                      settingsBox!.put('frequencies', _frequencies);
                    }
                  });
                }
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _saveCustomHabit() {
    String habit = _habitController.text.trim();
    String description = _descriptionController.text.trim();

    if (habit.isNotEmpty && habitBox != null) {
      habitBox!.put(habit, {
        "description": description,
        "category": _selectedCategory,
        "frequency": _selectedFrequency,
      });
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text("Add Custom Habit"),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _saveCustomHabit,
          child: const Text(
            "Save",
            style: TextStyle(color: CupertinoColors.activeGreen),
          ),
        ),
      ),
      child: SafeArea(
        child: FutureBuilder<bool>(
          future: _hiveInitialized,
          builder: (context, snapshot) {
            if (!snapshot.hasData ||
                snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CupertinoActivityIndicator());
            }

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Habit Name",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    CupertinoTextField(
                      controller: _habitController,
                      placeholder: "e.g., Learn a new language",
                    ),

                    const SizedBox(height: 20),
                    const Text("Habit Description"),
                    CupertinoTextField(
                      controller: _descriptionController,
                      placeholder: "Enter a brief description...",
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 10,
                      ),
                      maxLines: 3,
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey6,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),

                    const SizedBox(height: 20),
                    const Text("Select Category"),
                    CupertinoButton(
                      color: CupertinoColors.systemGrey5,
                      onPressed: () => _showPicker(context, "Category"),
                      child: Text(_selectedCategory),
                    ),
                    CupertinoButton(
                      child: const Text(
                        "+ Add Custom Category",
                        style: TextStyle(color: CupertinoColors.activeGreen),
                      ),
                      onPressed: () => _showCustomPopup(context, "Category"),
                    ),

                    const SizedBox(height: 20),
                    const Text("Set Frequency"),
                    CupertinoButton(
                      color: CupertinoColors.systemGrey5,
                      onPressed: () => _showPicker(context, "Frequency"),
                      child: Text(_selectedFrequency),
                    ),
                    CupertinoButton(
                      child: const Text(
                        "+ Add Custom Frequency",
                        style: TextStyle(color: CupertinoColors.activeGreen),
                      ),
                      onPressed: () => _showCustomPopup(context, "Frequency"),
                    ),

                    const SizedBox(height: 32),
                    Center(
                      child: CupertinoButton.filled(
                        onPressed: _saveCustomHabit,
                        child: const Text("Save Habit"),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
