import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../services/food_service.dart';
import '../providers/calorie_provider.dart';
import '../food.dart';
import '../utils/app_bar.dart';

class SearchFoodPage extends StatefulWidget {
  const SearchFoodPage({super.key});

  @override
  State<SearchFoodPage> createState() => _SearchFoodPageState();
}

class _SearchFoodPageState extends State<SearchFoodPage> {
  final TextEditingController _searchController = TextEditingController();
  final FoodService _foodService = FoodService();
  final ImagePicker _picker = ImagePicker();
  List<FoodInfoItem> _searchResults = [];

  Future<void> _searchFood() async {
    final query = _searchController.text;
    if (query.isNotEmpty) {
      final results = await _foodService.searchFood(query);
      setState(() {
        _searchResults = results;
      });
    }
  }

  Future<void> _searchFoodByImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      final results = await _foodService.searchFoodByImage(pickedFile.path);
      setState(() {
        _searchResults = results;
      });
    }
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchResults = [];
    });
  }

  void _addFood(FoodInfoItem item) {
    final food = Food(
      name: item.foodName,
      calories: int.parse(item.calories.replaceAll('kcal', '').trim()),
      dateTime: DateTime.now(),
      fat: double.tryParse(item.fat.replaceAll('g', '').trim()),
      carbs: double.tryParse(item.carbs.replaceAll('g', '').trim()),
      protein: double.tryParse(item.protein.replaceAll('g', '').trim()),
    );
    Provider.of<CalorieProvider>(context, listen: false).addFood(food);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${item.foodName} added')),
    );
    _clearSearch();
  }

  static Row _buildLegend(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Icon(Icons.local_fire_department, size: 16),
        Text('Calories',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(fontSize: 12, color: Colors.grey)),
        Icon(Icons.opacity, size: 16),
        Text('Fat',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(fontSize: 12, color: Colors.grey)),
        Icon(Icons.fastfood, size: 16),
        Text('Carbs',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(fontSize: 12, color: Colors.grey)),
        Icon(Icons.fitness_center, size: 16),
        Text('Protein',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context, 'Search Food'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            _searchResults.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextField(
                          controller: _searchController,
                          decoration:
                              const InputDecoration(labelText: 'Food Name'),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: _searchFood,
                              child: const Icon(Icons.search),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: _searchFoodByImage,
                              child: const Icon(Icons.camera_alt),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      TextField(
                        controller: _searchController,
                        decoration:
                            const InputDecoration(labelText: 'Food Name'),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _searchFood,
                              child: const Icon(Icons.search),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _searchFoodByImage,
                              child: const Icon(Icons.camera_alt),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildLegend(context),
                      const SizedBox(height: 20),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final item = _searchResults[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              child: ListTile(
                                title: Text(item.foodName),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.local_fire_department,
                                            size: 16),
                                        const SizedBox(width: 4),
                                        Text(item.calories),
                                        const SizedBox(width: 20),
                                        Icon(Icons.opacity, size: 16),
                                        const SizedBox(width: 4),
                                        Text(item.fat),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Icon(Icons.fastfood, size: 16),
                                        const SizedBox(width: 4),
                                        Text(item.carbs),
                                        const SizedBox(width: 20),
                                        Icon(Icons.fitness_center, size: 16),
                                        const SizedBox(width: 4),
                                        Text(item.protein),
                                      ],
                                    ),
                                  ],
                                ),
                                onTap: () => _addFood(item),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
            Positioned(
              right: 16,
              bottom: 16,
              child: _searchResults.isNotEmpty
                  ? FloatingActionButton(
                      onPressed: _clearSearch,
                      child: Icon(Icons.clear),
                    )
                  : Container(),
            ),
          ],
        ),
      ),
    );
  }
}
