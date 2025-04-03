import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CourseSessionsPage extends StatefulWidget {
  final String userId;
  final String courseId;
  final String courseName;

  const CourseSessionsPage({
    super.key,
    required this.userId,
    required this.courseId,
    required this.courseName,
  });

  @override
  State<CourseSessionsPage> createState() => _CourseSessionsPageState();
}

class _CourseSessionsPageState extends State<CourseSessionsPage> {
  List<dynamic> _sessions = [];
  List<dynamic> _filteredSessions = [];
  bool _isLoading = true;
  String _errorMessage = '';

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _heureDebutController = TextEditingController();
  final TextEditingController _heureFinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://192.168.248.45/equihorizon/nouveau/get_seances.php?idcours=${widget.courseId}&idcava=${widget.userId}',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            _sessions = data['sessions'];
            _filteredSessions = List.from(_sessions);
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = data['message'];
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Erreur HTTP ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterSessions() {
    String date = _dateController.text.toLowerCase();
    String heureDebut = _heureDebutController.text.toLowerCase();
    String heureFin = _heureFinController.text.toLowerCase();

    setState(() {
      _filteredSessions = _sessions.where((session) {
        final dateMatch = date.isEmpty || session['datecours'].toLowerCase().contains(date);
        final heureDebutMatch = heureDebut.isEmpty || session['heure_debut'].toLowerCase().contains(heureDebut);
        final heureFinMatch = heureFin.isEmpty || session['heure_fin'].toLowerCase().contains(heureFin);

        return dateMatch && heureDebutMatch && heureFinMatch;
      }).toList();
    });
  }

  Future<void> _confirmerDesinscription(String idcoursseance) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmation de désinscription'),
        content: Text("Voulez-vous vraiment vous désinscrire de cette séance ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Se désinscrire"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _desinscrire(idcoursseance);
    }
  }

  Future<void> _desinscrire(String idcoursseance) async {
  try {
    print('Envoi de la requête de désinscription...');
    print('idcava: ${widget.userId}');
    print('idcoursbase: ${widget.courseId}');
    print('idcoursseance: $idcoursseance');

    final response = await http.post(
      Uri.parse('http://192.168.248.45/equihorizon/nouveau/desinscription_seance.php'),
      body: {
        'idcava': widget.userId.toString(),
        'idcoursseance': idcoursseance.toString(),
        'idcoursbase': widget.courseId.toString(), // 🆕 obligatoire
      },
    );

    try {
      final data = json.decode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'])),
      );

      if (data['success']) {
        _loadSessions(); // Refresh la liste
      }
    } catch (e) {
      print('Erreur de parsing JSON : $e');
      print('Réponse brute : ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur de réponse du serveur : ${response.body}")),
      );
    }
  } catch (e) {
    print('Erreur réseau : $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erreur réseau : $e')),
    );
  }
}

  String _formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Séances - ${widget.courseName}'),
        backgroundColor: Colors.brown,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text('Erreur : $_errorMessage'))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          TextField(
                            controller: _dateController,
                            decoration: InputDecoration(
                              labelText: 'Filtrer par date',
                              prefixIcon: Icon(Icons.calendar_month),
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (_) => _filterSessions(),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: _heureDebutController,
                            decoration: InputDecoration(
                              labelText: 'Heure de début',
                              prefixIcon: Icon(Icons.access_time),
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (_) => _filterSessions(),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: _heureFinController,
                            decoration: InputDecoration(
                              labelText: 'Heure de fin',
                              prefixIcon: Icon(Icons.access_time_filled),
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (_) => _filterSessions(),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredSessions.length,
                        itemBuilder: (context, index) {
                          final session = _filteredSessions[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: const Icon(Icons.calendar_today),
                              title: Text(_formatDate(session['datecours'])),
                              subtitle: Text('${session['heure_debut']} à ${session['heure_fin']}'),
                              trailing: IconButton(
                                icon: Icon(Icons.cancel, color: Colors.red),
                                tooltip: 'Se désinscrire',
                                onPressed: () => _confirmerDesinscription(
                                  session['idcoursseance'].toString(),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }

  @override
  void dispose() {
    _dateController.dispose();
    _heureDebutController.dispose();
    _heureFinController.dispose();
    super.dispose();
  }
}
