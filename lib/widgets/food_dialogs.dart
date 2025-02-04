import 'package:flutter/material.dart';
import '../food_db.dart';
import '../services/food_service.dart';
import './search_dialogs.dart';

class FoodDialogs {
  static Future<void> showAddFoodDialog(BuildContext context, FoodDatabase foodDb, Function loadFoods) async {
    final nameController = TextEditingController();
    final caloriesController = TextEditingController();
    final selectedDate = ValueNotifier<DateTime>(DateTime.now());

    await _showFoodDialog(
      context,
      '新增食物',
      nameController,
      caloriesController,
      selectedDate,
      () async {
        await _addFood(context, foodDb, nameController, caloriesController, selectedDate.value, loadFoods);
      },
    );
  }

  static Future<void> showEditFoodDialog(BuildContext context, FoodDatabase foodDb, Food food, Function loadFoods) async {
    final nameController = TextEditingController(text: food.name);
    final caloriesController = TextEditingController(text: food.calories.toString());
    final selectedDate = ValueNotifier<DateTime>(food.dateTime);

    await _showFoodDialog(
      context,
      '編輯食物',
      nameController,
      caloriesController,
      selectedDate,
      () async {
        await _updateFood(context, foodDb, food.id!, nameController, caloriesController, selectedDate.value, loadFoods);
      },
    );
  }

  static Future<void> _showFoodDialog(
    BuildContext context,
    String title,
    TextEditingController nameController,
    TextEditingController caloriesController,
    ValueNotifier<DateTime> selectedDate,
    Future<void> Function() onConfirm,
  ) async {
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(title),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTextField(nameController, '食物名稱'),
                  _buildTextField(caloriesController, '熱量', keyboardType: TextInputType.number),
                  _buildDateTimePicker(context, setState, selectedDate),
                  ValueListenableBuilder<DateTime>(
                    valueListenable: selectedDate,
                    builder: (context, value, child) {
                      return _buildSelectedDateText(value);
                    },
                  ),
                ],
              ),
              actions: [
                _buildDialogButton('取消', () => Navigator.of(context).pop()),
                _buildDialogButton('確認', onConfirm),
              ],
            );
          },
        );
      },
    );
  }

  static Future<void> showSearchFoodDialog(BuildContext context, FoodService foodService) async {
    await SearchDialogs.showSearchFoodDialog(context, foodService);
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
          lastDate: DateTime.now(), 
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
      Navigator.of(context).pop(); // 移動到這裡
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
      Navigator.of(context).pop(); // 移動到這裡
    }
  }
}