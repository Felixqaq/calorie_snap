import 'package:calorie_snap/models/food_info.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../services/food_service.dart';
import '../providers/calorie_provider.dart';
import '../utils/app_bar.dart';
import 'search_food_results_page.dart';


class SearchFoodPage extends StatefulWidget {
  const SearchFoodPage({super.key});

  @override
  State<SearchFoodPage> createState() => _SearchFoodPageState();
}

class _SearchFoodPageState extends State<SearchFoodPage> {
  final TextEditingController _searchController = TextEditingController();
  final FoodService _foodService = FoodService();
  final ImagePicker _picker = ImagePicker();
  List<FoodInfo> _searchResults = [];
  bool _isLoading = false;

  Future<void> _searchFood() async {
    if (_searchController.text.isEmpty) return;
    _setLoading(true);
    final results = await _foodService.searchFood(_searchController.text);
    setState(() {
      _searchResults = results.foodItems;
    });
    _setLoading(false);
  }

  Future<void> _searchFoodByImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      _setLoading(true);
      final results = await _foodService.searchFoodByImage(pickedFile.path);
      _navigateToResultsPage(results.foodItems);
      _setLoading(false);
    }
  }

  Future<void> _searchFoodByGalleryImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _setLoading(true);
      final results = await _foodService.searchFoodByImage(pickedFile.path);
      _navigateToResultsPage(results.foodItems);
      _setLoading(false);
    }
  }

  void _setLoading(bool isLoading) {
    setState(() {
      _isLoading = isLoading;
    });
  }

  void _navigateToResultsPage(List<FoodInfo> results) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SearchFoodResultsPage(results: results),
      ),
    ).then((_) {
      Provider.of<CalorieProvider>(context, listen: false).updateFoodsAndCalories();
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchResults = [];
    });
  }

  void _addFood(FoodInfo item) {
    final food = FoodService.parseFood(item);
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
        Icon(Icons.scale, size: 16),
        Text('Weight',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(fontSize: 12, color: Colors.grey)),
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

  Widget _buildSearchInput() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextField(
          controller: _searchController,
          decoration: const InputDecoration(labelText: 'Food Name'),
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
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: _searchFoodByGalleryImage,
              child: const Icon(Icons.photo_library),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    return Column(
      children: [
        TextField(
          controller: _searchController,
          decoration: const InputDecoration(labelText: 'Food Name'),
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
                          Icon(Icons.scale, size: 16),
                          const SizedBox(width: 4),
                          Text(item.weight),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.local_fire_department, size: 16),
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
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty
                    ? _buildSearchInput()
                    : _buildSearchResults(),
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
