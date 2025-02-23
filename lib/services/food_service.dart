import 'package:calorie_snap/models/food.dart';
import 'package:calorie_snap/models/food_info.dart';
import 'package:calorie_snap/models/null_food_info_item.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:calorie_snap/models/composite_food_info_item.dart';

class FoodService {
  static String _initializeBaseUrl() {
    // return 'http://192.168.1.111:8000';
    // return 'http://192.168.1.111:8080';
    return "http://35.234.57.229:8080";
  }

  Map<String, String> getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  Future<FoodInfo> searchFood(String query) async {
    debugPrint('搜尋食物: $query');

    final String baseUrl = _initializeBaseUrl();

    if (baseUrl.isEmpty) {
      debugPrint('baseUrl Empty');
      return NullFoodInfoItem();
    }

    debugPrint('baseUrl: $baseUrl');

    final url = Uri.parse('$baseUrl/search_food/?query=$query');

    final response = await http.get(url, headers: getHeaders());
    debugPrint('response: ${response.statusCode}');
    debugPrint('response: $response');
    if (response.statusCode == 200) {
      final String responseString = utf8.decode(response.bodyBytes);
      final responseData = jsonDecode(responseString);
      List<dynamic> jsonData = jsonDecode(responseData);
      CompositeFoodInfoItem foodItems = CompositeFoodInfoItem.fromJson(jsonData, '');
      debugPrint('foodItems: $responseString');
      return foodItems;
    }
    return NullFoodInfoItem();
  }


  Future<FoodInfo> searchFoodByImage(String imagePath) async {
    debugPrint('搜尋食物圖片: $imagePath');

    final String baseUrl = _initializeBaseUrl();

    if (baseUrl.isEmpty) {
      debugPrint('baseUrl Empty');
      return NullFoodInfoItem();
    }

    debugPrint('baseUrl: $baseUrl');

    final url = Uri.parse('$baseUrl/search_food_by_image/');
    final request = http.MultipartRequest('POST', url);
    request.headers.addAll(getHeaders());
    request.files.add(await http.MultipartFile.fromPath('image', imagePath));

    final response = await request.send();
    debugPrint('response: ${response.statusCode}');
    debugPrint('response: $response');
    final responseBody = await http.Response.fromStream(response);
    if (responseBody.statusCode == 200) {
      final String responseString = utf8.decode(responseBody.bodyBytes);
      final responseData = jsonDecode(responseString);
      List<dynamic> jsonData = jsonDecode(responseData);
      
      CompositeFoodInfoItem foodItems = CompositeFoodInfoItem.fromJson(jsonData, '');
      return foodItems;
    }
    return NullFoodInfoItem();
  }

  Future<String> translateText(String text, {String dest = 'zh-tw'}) async {
    debugPrint('翻譯文字: $text 到 $dest');

    final String baseUrl = _initializeBaseUrl();

    if (baseUrl.isEmpty) {
      debugPrint('baseUrl Empty');
      return '';
    }

    debugPrint('baseUrl: $baseUrl');

    final url = Uri.parse('$baseUrl/translate/?text=$text&dest=$dest');
    final response = await http.post(
      url,
      headers: getHeaders(),
    );

    if (response.statusCode == 200) {
      final String responseString = utf8.decode(response.bodyBytes);
      debugPrint('responseString: $responseString');
      return responseString.replaceAll('"', '');
    } else {
      debugPrint('Failed to translate text. Status code: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
      return '';
    }
  }

  static Food parseFood(FoodInfo item) {
    return Food(
      name: item.foodName,
      nameZh: item.foodNameZh,
      calories: int.parse(item.calories.replaceAll('kcal', '').trim()),
      dateTime: DateTime.now(),
      fat: double.tryParse(item.fat.replaceAll('g', '').trim()),
      carbs: double.tryParse(item.carbs.replaceAll('g', '').trim()),
      protein: double.tryParse(item.protein.replaceAll('g', '').trim()),
    );
  }
}
