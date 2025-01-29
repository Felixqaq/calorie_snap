
import 'package:http/http.dart' as http;
import 'dart:convert';

class FoodService {
  Future<void> searchFood(String query) async {
    final url = Uri.parse('http://localhost:8000/search_food/?query=$query');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      print(jsonDecode(response.body));
    } else {
      print('錯誤: ${response.statusCode}');
    }
  }
}