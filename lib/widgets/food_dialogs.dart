import 'package:flutter/material.dart';
import '../food_db.dart';
import '../services/food_service.dart';

class FoodDialogs {
  static Future<void> showAddFoodDialog(BuildContext context, FoodDatabase foodDb, Function loadFoods) async {
    final _nameController = TextEditingController();
    final _caloriesController = TextEditingController();
    final _selectedDate = ValueNotifier<DateTime>(DateTime.now());

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('新增食物'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTextField(_nameController, '食物名稱'),
                  _buildTextField(_caloriesController, '熱量', keyboardType: TextInputType.number),
                  _buildDateTimePicker(context, setState, _selectedDate),
                  ValueListenableBuilder<DateTime>(
                    valueListenable: _selectedDate,
                    builder: (context, value, child) {
                      return _buildSelectedDateText(value);
                    },
                  ),
                ],
              ),
              actions: [
                _buildDialogButton('取消', () => Navigator.of(context).pop()),
                _buildDialogButton('新增', () async {
                  await _addFood(context, foodDb, _nameController, _caloriesController, _selectedDate.value, loadFoods);
                }),
              ],
            );
          },
        );
      },
    );
  }

  static Future<void> showSearchFoodDialog(BuildContext context, FoodService foodService) async {
    final _searchController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('搜尋食物'),
          content: TextField(
            controller: _searchController,
            decoration: const InputDecoration(labelText: '食物名稱'),
          ),
          actions: [
            _buildDialogButton('取消', () => Navigator.of(context).pop()),
            _buildDialogButton('搜尋', () async {
              final query = _searchController.text;
              if (query.isNotEmpty) {
                await foodService.searchFood(query);
                Navigator.of(context).pop();
              }
            }),
          ],
        );
      },
    );
  }

  static Future<void> showEditFoodDialog(BuildContext context, FoodDatabase foodDb, Food food, Function loadFoods) async {
    final _nameController = TextEditingController(text: food.name);
    final _caloriesController = TextEditingController(text: food.calories.toString());
    final _selectedDate = ValueNotifier<DateTime>(food.dateTime);

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('編輯食物'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTextField(_nameController, '食物名稱'),
                  _buildTextField(_caloriesController, '熱量', keyboardType: TextInputType.number),
                  _buildDateTimePicker(context, setState, _selectedDate),
                  ValueListenableBuilder<DateTime>(
                    valueListenable: _selectedDate,
                    builder: (context, value, child) {
                      return _buildSelectedDateText(value);
                    },
                  ),
                ],
              ),
              actions: [
                _buildDialogButton('取消', () => Navigator.of(context).pop()),
                _buildDialogButton('更新', () async {
                  await _updateFood(context, foodDb, food.id!, _nameController, _caloriesController, _selectedDate.value, loadFoods);
                }),
              ],
            );
          },
        );
      },
    );
  }

  static TextField _buildTextField(TextEditingController controller, String labelText, {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: labelText),
      keyboardType: keyboardType,
    );
  }

  static Widget _buildDateTimePicker(BuildContext context, StateSetter setState, ValueNotifier<DateTime> selectedDate) {
    return ElevatedButton(
      onPressed: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: selectedDate.value,
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );
        if (pickedDate != null) {
          final pickedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(selectedDate.value),
          );
          if (pickedTime != null) {
            setState(() {
              selectedDate.value = DateTime(
                pickedDate.year,
                pickedDate.month,
                pickedDate.day,
                pickedTime.hour,
                pickedTime.minute,
              );
            });
          }
        }
      },
      child: const Text('選擇日期和時間'),
    );
  }

  static Text _buildSelectedDateText(DateTime selectedDate) {
    return Text('選擇的日期: ${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')} ${selectedDate.hour.toString().padLeft(2, '0')}:${selectedDate.minute.toString().padLeft(2, '0')}');
  }

  static TextButton _buildDialogButton(String text, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      child: Text(text),
    );
  }

  static Future<void> _addFood(BuildContext context, FoodDatabase foodDb, TextEditingController nameController, TextEditingController caloriesController, DateTime selectedDate, Function loadFoods) async {
    final name = nameController.text;
    final calories = int.tryParse(caloriesController.text) ?? 0;
    if (name.isNotEmpty && calories > 0) {
      await foodDb.insertFood(
        Food(
          name: name,
          calories: calories,
          dateTime: selectedDate,
        ),
      );
      loadFoods();
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  static Future<void> _updateFood(BuildContext context, FoodDatabase foodDb, int id, TextEditingController nameController, TextEditingController caloriesController, DateTime selectedDate, Function loadFoods) async {
    final name = nameController.text;
    final calories = int.tryParse(caloriesController.text) ?? 0;
    if (name.isNotEmpty && calories > 0) {
      await foodDb.updateFood(
        Food(
          id: id,
          name: name,
          calories: calories,
          dateTime: selectedDate,
        ),
      );
      loadFoods();
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }
}