import 'package:calorie_snap/models/food.dart';
import 'package:calorie_snap/providers/calorie_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FoodDialogs {
  static Future<void> showAddFoodDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final caloriesController = TextEditingController();
    final fatController = TextEditingController();
    final carbsController = TextEditingController();
    final proteinController = TextEditingController();
    final selectedDate = ValueNotifier<DateTime>(DateTime.now());

    await _showFoodDialog(
      context,
      '新增食物',
      nameController,
      caloriesController,
      fatController,
      carbsController,
      proteinController,
      selectedDate,
      () async {
        await _addFood(
            context,
            nameController,
            caloriesController,
            fatController,
            carbsController,
            proteinController,
            selectedDate.value);
      },
    );
  }

  static Future<void> showEditFoodDialog(
      BuildContext context, Food food) async {
    final nameController = TextEditingController(text: food.name);
    final caloriesController =
        TextEditingController(text: food.calories.toString());
    final fatController =
        TextEditingController(text: food.fat?.toString() ?? '');
    final carbsController =
        TextEditingController(text: food.carbs?.toString() ?? '');
    final proteinController =
        TextEditingController(text: food.protein?.toString() ?? '');
    final selectedDate = ValueNotifier<DateTime>(food.dateTime);

    await _showFoodDialog(
      context,
      '編輯食物',
      nameController,
      caloriesController,
      fatController,
      carbsController,
      proteinController,
      selectedDate,
      () async {
        await _updateFood(
            context,
            food.id!,
            nameController,
            caloriesController,
            fatController,
            carbsController,
            proteinController,
            selectedDate.value);
      },
    );
  }

  static Future<void> _showFoodDialog(
    BuildContext context,
    String title,
    TextEditingController nameController,
    TextEditingController caloriesController,
    TextEditingController fatController,
    TextEditingController carbsController,
    TextEditingController proteinController,
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
                  _buildTextField(caloriesController, '熱量',
                      keyboardType: TextInputType.number),
                  _buildTextField(fatController, '脂肪',
                      keyboardType: TextInputType.number),
                  _buildTextField(carbsController, '碳水化合物',
                      keyboardType: TextInputType.number),
                  _buildTextField(proteinController, '蛋白質',
                      keyboardType: TextInputType.number),
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

  static TextField _buildTextField(
      TextEditingController controller, String labelText,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: labelText),
      keyboardType: keyboardType,
    );
  }

  static Widget _buildDateTimePicker(BuildContext context, StateSetter setState,
      ValueNotifier<DateTime> selectedDate) {
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
    return Text(
        '選擇的日期: ${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')} ${selectedDate.hour.toString().padLeft(2, '0')}:${selectedDate.minute.toString().padLeft(2, '0')}');
  }

  static TextButton _buildDialogButton(String text, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      child: Text(text),
    );
  }

  static Future<void> _addFood(
      BuildContext context,
      TextEditingController nameController,
      TextEditingController caloriesController,
      TextEditingController fatController,
      TextEditingController carbsController,
      TextEditingController proteinController,
      DateTime selectedDate) async {
    final name = nameController.text;
    final calories = int.tryParse(caloriesController.text) ?? 0;
    final fat = double.tryParse(fatController.text) ?? 0;
    final carbs = double.tryParse(carbsController.text) ?? 0;
    final protein = double.tryParse(proteinController.text) ?? 0;
    if (name.isNotEmpty && calories > 0) {
      final food = Food(
        name: name,
        calories: calories,
        dateTime: selectedDate,
        fat: fat,
        carbs: carbs,
        protein: protein,
      );
      await Provider.of<CalorieProvider>(context, listen: false).addFood(food);
      Navigator.of(context).pop(); // 移動到這裡
    }
  }

  static Future<void> _updateFood(
      BuildContext context,
      int id,
      TextEditingController nameController,
      TextEditingController caloriesController,
      TextEditingController fatController,
      TextEditingController carbsController,
      TextEditingController proteinController,
      DateTime selectedDate) async {
    final name = nameController.text;
    final calories = int.tryParse(caloriesController.text) ?? 0;
    final fat = double.tryParse(fatController.text);
    final carbs = double.tryParse(carbsController.text);
    final protein = double.tryParse(proteinController.text);
    if (name.isNotEmpty && calories > 0) {
      final food = Food(
        id: id,
        name: name,
        calories: calories,
        dateTime: selectedDate,
        fat: fat,
        carbs: carbs,
        protein: protein,
      );
      await Provider.of<CalorieProvider>(context, listen: false)
          .updateFood(food);
      Navigator.of(context).pop();
    }
  }
}
