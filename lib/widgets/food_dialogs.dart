import 'package:calorie_snap/models/food.dart';
import 'package:calorie_snap/providers/calorie_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:calorie_snap/services/food_service.dart';

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
      caloriesController: caloriesController,
      fatController: fatController,
      carbsController: carbsController,
      proteinController: proteinController,
    );
  }

  static Future<void> showEditFoodDialog(
      BuildContext context, Food food) async {
    final nameController = TextEditingController(text: food.name);
    final portionController = TextEditingController(text: '1');

    await _showFoodDialog(
      context,
      '編輯食物',
      nameController,
      ValueNotifier<DateTime>(food.dateTime),
      () async {
        final portion = double.tryParse(portionController.text) ?? 1;
        final updatedCalories = (food.calories * portion).toInt();
        final updatedFat = (food.fat ?? 0) * portion;
        final updatedCarbs = (food.carbs ?? 0) * portion;
        final updatedProtein = (food.protein ?? 0) * portion;
        await _updateFood(
            context,
            food.id!,
            nameController,
            updatedCalories,
            updatedFat,
            updatedCarbs,
            updatedProtein,
            food.dateTime);
      },
      portionController: portionController,
    );
  }

  static Future<void> _showFoodDialog(
    BuildContext context,
    String title,
    TextEditingController nameController,
    ValueNotifier<DateTime> selectedDate,
    Future<void> Function() onConfirm, {
    TextEditingController? caloriesController,
    TextEditingController? fatController,
    TextEditingController? carbsController,
    TextEditingController? proteinController,
    TextEditingController? portionController,
  }) async {
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(title),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTextField(nameController, '食物名稱'),
                    if (caloriesController != null)
                      _buildTextField(caloriesController, '熱量',
                          keyboardType: TextInputType.number),
                    if (fatController != null)
                      _buildTextField(fatController, '脂肪',
                          keyboardType: TextInputType.number),
                    if (carbsController != null)
                      _buildTextField(carbsController, '碳水化合物',
                          keyboardType: TextInputType.number),
                    if (proteinController != null)
                      _buildTextField(proteinController, '蛋白質',
                          keyboardType: TextInputType.number),
                    if (portionController != null)
                      _buildTextField(portionController, '份數',
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
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('取消'),
                ),
                TextButton(
                  onPressed: onConfirm,
                  child: const Text('確定'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static TextField _buildTextField(
    TextEditingController controller,
    String labelText, {
    TextInputType keyboardType = TextInputType.text,
  }) {
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
      '選擇的日期: ${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')} ${selectedDate.hour.toString().padLeft(2, '0')}:${selectedDate.minute.toString().padLeft(2, '0')}',
    );
  }

  static Future<void> _addFood(
    BuildContext context,
    TextEditingController nameController,
    TextEditingController caloriesController,
    TextEditingController fatController,
    TextEditingController carbsController,
    TextEditingController proteinController,
    DateTime selectedDate,
  ) async {
    final name = nameController.text;
    final translatedNameEn = await FoodService().translateText(name, dest: 'en');
    final translatedNameZh = await FoodService().translateText(name, dest: 'zh-tw');
    final nameZh = _isChinese(name) ? name : translatedNameZh;
    final nameEn = _isChinese(name) ? translatedNameEn : name;
    final calories = int.tryParse(caloriesController.text) ?? 0;
    final fat = double.tryParse(fatController.text) ?? 0;
    final carbs = double.tryParse(carbsController.text) ?? 0;
    final protein = double.tryParse(proteinController.text) ?? 0;
    if (name.isNotEmpty && calories > 0) {
      final food = Food(
        name: nameEn,
        nameZh: nameZh,
        calories: calories,
        dateTime: selectedDate,
        fat: fat,
        carbs: carbs,
        protein: protein,
      );
      await Provider.of<CalorieProvider>(context, listen: false).addFood(food);
      Navigator.of(context).pop();
    }
  }

  static Future<void> _updateFood(
    BuildContext context,
    int id,
    TextEditingController nameController,
    int updatedCalories,
    double updatedFat,
    double updatedCarbs,
    double updatedProtein,
    DateTime selectedDate,
  ) async {
    final name = nameController.text;
    final translatedNameEn = await FoodService().translateText(name, dest: 'en');
    final translatedNameZh = await FoodService().translateText(name, dest: 'zh-tw');
    final nameZh = _isChinese(name) ? name : translatedNameZh;
    final nameEn = _isChinese(name) ? translatedNameEn : name;

    if (name.isNotEmpty && updatedCalories > 0) {
      final food = Food(
        id: id,
        name: nameEn,
        nameZh: nameZh,
        calories: updatedCalories,
        dateTime: selectedDate,
        fat: updatedFat,
        carbs: updatedCarbs,
        protein: updatedProtein,
      );
      await Provider.of<CalorieProvider>(context, listen: false).updateFood(food);
      Navigator.of(context).pop();
    }
  }

  static bool _isChinese(String text) {
    final chineseRegex = RegExp(r'[\u4e00-\u9fa5]');
    return chineseRegex.hasMatch(text);
  }
}
