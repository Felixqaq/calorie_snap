import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart'; 

class FoodService {

  static String _initializeBaseUrl() {
    return 'http://10.0.2.2:8000';
  }

  Future<void> searchFood(String query) async {
    debugPrint('搜尋食物: $query'); 

    final String baseUrl = _initializeBaseUrl();

    if (baseUrl.isEmpty) {
      debugPrint('baseUrl Empty');
      return;
    }

    debugPrint('baseUrl: $baseUrl');
    
    final url = Uri.parse('$baseUrl/search_food/?query=$query');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      debugPrint('回應資料: $responseData'); 
    } else {
      debugPrint('\x1B[31m錯誤: ${response.statusCode}\x1B[0m'); 
    }
  }
}