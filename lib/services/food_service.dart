import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

class FoodInfoItem {
  final String foodName;
  final String weight;
  final String calories;
  final String fat;
  final String carbs;
  final String protein;

  FoodInfoItem({
    required this.foodName,
    required this.weight,
    required this.calories,
    required this.fat,
    required this.carbs,
    required this.protein,
  });

  factory FoodInfoItem.fromJson(Map<String, dynamic> json) {
    return FoodInfoItem(
      foodName: json['food_name'],
      weight: json['weight'],
      calories: json['calories'],
      fat: json['fat'],
      carbs: json['carbs'],
      protein: json['protein'],
    );
  }
}

class FoodService {
  static String _initializeBaseUrl() {
    return 'http://192.168.1.111:8000';
    // return 'http://10.0.2.2:8000';
  }

  Future<List<FoodInfoItem>> searchFood(String query) async {
    debugPrint('搜尋食物: $query');

    final String baseUrl = _initializeBaseUrl();

    if (baseUrl.isEmpty) {
      debugPrint('baseUrl Empty');
      return [];
    }

    debugPrint('baseUrl: $baseUrl');

    final url = Uri.parse('$baseUrl/search_food/?query=$query');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body) as List;
      debugPrint('回應資料: $responseData');
      return responseData.map((data) => FoodInfoItem.fromJson(data)).toList();
    } else {
      debugPrint('\x1B[31m錯誤: ${response.statusCode}\x1B[0m');
      return [];
    }
  }

  Future<List<FoodInfoItem>> searchFoodByImage(String imagePath) async {
    debugPrint('搜尋食物圖片: $imagePath');

    final String baseUrl = _initializeBaseUrl();

    if (baseUrl.isEmpty) {
      debugPrint('baseUrl Empty');
      return [];
    }

    debugPrint('baseUrl: $baseUrl');

    final url = Uri.parse('$baseUrl/search_food_by_image/');
    final request = http.MultipartRequest('POST', url);
    request.files.add(await http.MultipartFile.fromPath('image', imagePath));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData =
          jsonDecode(await response.stream.bytesToString()) as List;
      debugPrint('回應資料: $responseData');
      return responseData.map((data) => FoodInfoItem.fromJson(data)).toList();
    } else {
      debugPrint('\x1B[31m錯誤: ${response.statusCode}\x1B[0m');
      return [];
    }
  }
}
