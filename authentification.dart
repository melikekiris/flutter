import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api.dart';

const String url = "https://localhost/equihorizon/nouveau/api.php";

Future<Object> Auth(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode('{"commande": 8, $data }'),
      );

      if (response.statusCode == 200) {
        print("Succès: ${response.body}");
        Object app = ApiService(response.body);
        return app;
      } else {
        print("Erreur ${response.statusCode}: ${response.body}");
        return "error";
      }
    } catch (e) {
      print("Échec de la requête: $e");
      return "error";
    }
}
