import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Busca receitas pelo nome na TheMealDB
  Future<List<dynamic>> buscarReceitasExternas(String query) async {
    final url = Uri.parse(
      'https://www.themealdb.com/api/json/v1/1/search.php?s=$query',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(
          response.statusCode == 200 ? response.body : '',
        );
        return data['meals'] ?? [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
