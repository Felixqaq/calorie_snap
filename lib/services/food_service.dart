import 'package:calorie_snap/models/food.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:calorie_snap/models/food_info_item.dart';

class FoodService {
  static String _initializeBaseUrl() {
    return 'http://192.168.1.111:8000';
    // return 'http://10.0.2.2:8000';
  }

  Future<CompositeFoodInfoItem> searchFood(String query) async {
    debugPrint('搜尋食物: $query');

    final String baseUrl = _initializeBaseUrl();

    if (baseUrl.isEmpty) {
      debugPrint('baseUrl Empty');
      return CompositeFoodInfoItem(foodItems: []);
    }

    debugPrint('baseUrl: $baseUrl');

    final url = Uri.parse('$baseUrl/search_food/?query=$query');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body) as List;
      debugPrint('回應資料: $responseData');
      return CompositeFoodInfoItem.fromJson(responseData);
    } else {
      debugPrint('\x1B[31m錯誤: ${response.statusCode}\x1B[0m');
      return CompositeFoodInfoItem(foodItems: []);
    }
  }

  Future<CompositeFoodInfoItem> searchFoodByImage(String imagePath) async {
    debugPrint('搜尋食物圖片: $imagePath');

    final String baseUrl = _initializeBaseUrl();

    if (baseUrl.isEmpty) {
      debugPrint('baseUrl Empty');
      return CompositeFoodInfoItem(foodItems: []);
    }

    debugPrint('baseUrl: $baseUrl');

    final url = Uri.parse('$baseUrl/search_food_by_image/');
    final request = http.MultipartRequest('POST', url);
    request.files.add(await http.MultipartFile.fromPath('image', imagePath));

    final response = await request.send();
    if (response.statusCode == 200) {
      final String responseString = await response.stream.bytesToString();
      final Map<String, dynamic> responseData = jsonDecode(responseString);

      if (responseData.containsKey('recognized_foods') &&
          responseData['recognized_foods'] is List) {
        final List<dynamic> foodList = responseData['recognized_foods'];
        return CompositeFoodInfoItem.fromJson(foodList);
      } else {
        debugPrint('回應格式錯誤: $responseData');
        return CompositeFoodInfoItem(foodItems: []);
      }
    }
    return CompositeFoodInfoItem(foodItems: []);
  }

  static Food parseFood(FoodInfoItem item) {
    return Food(
      name: item.foodName,
      calories: int.parse(item.calories.replaceAll('kcal', '').trim()),
      dateTime: DateTime.now(),
      fat: double.tryParse(item.fat.replaceAll('g', '').trim()),
      carbs: double.tryParse(item.carbs.replaceAll('g', '').trim()),
      protein: double.tryParse(item.protein.replaceAll('g', '').trim()),
    );
  }
}
