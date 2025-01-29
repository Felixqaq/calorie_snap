import 'package:flutter/material.dart';
import '../food_db.dart';
import '../utils/app_bar.dart';
import '../services/food_service.dart';

class ShowFoodPage extends StatefulWidget {
  const ShowFoodPage({super.key, required this.title});

  final String title;

  @override
  State<ShowFoodPage> createState() => _ShowFoodPageState();
}

class _ShowFoodPageState extends State<ShowFoodPage> {
  final FoodDatabase _foodDb = FoodDatabase.instance;
  final FoodService _foodService = FoodService();
  List<Food> _foods = [];

  @override
  void initState() {
    super.initState();
    _loadFoods();
  }

  Future<void> _loadFoods() async {
    final foods = await _foodDb.getAllFoods();
    setState(() {
      _foods = foods;
    });
  }

  Future<void> _showAddFoodDialog() async {
    final _nameController = TextEditingController();
    final _caloriesController = TextEditingController();
    DateTime _selectedDate = DateTime.now();

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
                  _buildDateTimePicker(setState, _selectedDate),
                  _buildSelectedDateText(_selectedDate),
                ],
              ),
              actions: [
                _buildDialogButton('取消', () => Navigator.of(context).pop()),
                _buildDialogButton('新增', () async {
                  await _addFood(_nameController, _caloriesController, _selectedDate);
                }),
              ],
            );
          },
        );
      },
    );
  }

  TextField _buildTextField(TextEditingController controller, String labelText, {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: labelText),
      keyboardType: keyboardType,
    );
  }

  ElevatedButton _buildDateTimePicker(StateSetter setState, DateTime selectedDate) {
    return ElevatedButton(
      onPressed: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );
        if (pickedDate != null) {
          final pickedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(selectedDate),
          );
          if (pickedTime != null) {
            setState(() {
              selectedDate = DateTime(
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

  Text _buildSelectedDateText(DateTime selectedDate) {
    return Text('選擇的日期: ${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')} ${selectedDate.hour.toString().padLeft(2, '0')}:${selectedDate.minute.toString().padLeft(2, '0')}');
  }

  TextButton _buildDialogButton(String text, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      child: Text(text),
    );
  }

  Future<void> _addFood(TextEditingController nameController, TextEditingController caloriesController, DateTime selectedDate) async {
    final name = nameController.text;
    final calories = int.tryParse(caloriesController.text) ?? 0;
    if (name.isNotEmpty && calories > 0) {
      await _foodDb.insertFood(
        Food(
          name: name,
          calories: calories,
          dateTime: selectedDate,
        ),
      );
      _loadFoods();
      Navigator.of(context).pop();
    }
  }

  Future<void> _showSearchFoodDialog() async {
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
                await _foodService.searchFood(query);
                Navigator.of(context).pop();
              }
            }),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context, widget.title),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: _foods.length,
          itemBuilder: (context, index) {
            final food = _foods[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                leading: CircleAvatar(
                  child: Text(food.name[0]),
                ),
                title: Text(
                  food.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text('${food.calories} 卡路里'),
                    const SizedBox(height: 8),
                    Text(
                      '${food.dateTime.year}-${food.dateTime.month.toString().padLeft(2, '0')}-${food.dateTime.day.toString().padLeft(2, '0')} ${food.dateTime.hour.toString().padLeft(2, '0')}:${food.dateTime.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {
                    // 可以在這裡添加更多操作
                  },
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _showAddFoodDialog,
            tooltip: '新增食物',
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _showSearchFoodDialog,
            tooltip: '搜尋食物',
            child: const Icon(Icons.search),
          ),
        ],
      ),
    );
  }
}