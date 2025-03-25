import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String url = "https://localhost/tp_projet_v2/api/api.php";
  String id;

  ApiService(this.id);

  /*static Future<void> sendData(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        print("Succès: ${response.body}");
      } else {
        print("Erreur ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      print("Échec de la requête: $e");
    }
  }*/
  //creation perso

  Future<String> GetCours() async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode('{"commande": 1}'),
      );

      if (response.statusCode == 200) {
        print("Succès: ${response.body}");
        return response.body;
      } else {
        print("Erreur ${response.statusCode}: ${response.body}");
        return "error";
      }
    } catch (e) {
      print("Échec de la requête: $e");
      return "error";
    }
  }

  Future<String> GetInscription() async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode('{"commande": 2, "id": $id}'),
      );

      if (response.statusCode == 200) {
        print("Succès: ${response.body}");
        return response.body;
      } else {
        print("Erreur ${response.statusCode}: ${response.body}");
        return "error";
      }
    } catch (e) {
      print("Échec de la requête: $e");
      return "error";
    }
  }

  Future<String> GetParticipation() async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode('{"commande": 3, "id": ${this.id}}'),
      );

      if (response.statusCode == 200) {
        print("Succès: ${response.body}");
        return response.body;
      } else {
        print("Erreur ${response.statusCode}: ${response.body}");
        return "error";
      }
    } catch (e) {
      print("Échec de la requête: $e");
      return "error";
    }
  }

  Future<String> UpdateParticipation(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode('{"commande": 4, "data": $data , "id":${this.id}}'),
      );

      if (response.statusCode == 200) {
        print("Succès: ${response.body}");
        return response.body;
      } else {
        print("Erreur ${response.statusCode}: ${response.body}");
        return "error";
      }
    } catch (e) {
      print("Échec de la requête: $e");
      return "error";
    }
  }
  Future<String> CreateParticipation(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode('{"commande": 5, "data": $data, "id":${this.id}} }'),
      );

      if (response.statusCode == 200) {
        print("Succès: ${response.body}");
        return response.body;
      } else {
        print("Erreur ${response.statusCode}: ${response.body}");
        return "error";
      }
    } catch (e) {
      print("Échec de la requête: $e");
      return "error";
    }
  }

  Future<String> CreateInscription(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode('{"commande": 6, "data": ${data}, "id":${this.id}} }'),
      );

      if (response.statusCode == 200) {
        print("Succès: ${response.body}");
        return response.body;
      } else {
        print("Erreur ${response.statusCode}: ${response.body}");
        return "error";
      }
    } catch (e) {
      print("Échec de la requête: $e");
      return "error";
    }
  }

  Future<String> DeleteInscription(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode('{"commande": 7, "data": ${data},"id": ${this.id} }'),
      );

      if (response.statusCode == 200) {
        print("Succès: ${response.body}");
        return response.body;
      } else {
        print("Erreur ${response.statusCode}: ${response.body}");
        return "error";
      }
    } catch (e) {
      print("Échec de la requête: $e");
      return "error";
    }
  }
}
