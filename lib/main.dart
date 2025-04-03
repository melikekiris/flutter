import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import 'course_sessions_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Connexion Equihorizon',
      theme: ThemeData(
        primaryColor: Color(0xFFA67C52),
        scaffoldBackgroundColor: Color(0xFFF5F5DC),
        fontFamily: GoogleFonts.playfairDisplay().fontFamily,
      ),
      home: LoginPage(),
    );
  }
}

class User {
  final String id;
  final String nom;
  final String prenom;
  final String email;

  User({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      nom: json['nom'],
      prenom: json['prenom'],
      email: json['email'],
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<User?> _callYourApi(String username, String password) async {
    final response = await http.post(
      Uri.parse('http://192.168.248.45/equihorizon/nouveau/api.php'),
      body: {
        'username': username,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return User.fromJson(data['user']);
      }
    }
    return null;
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      User? user = await _callYourApi(
        _usernameController.text,
        _passwordController.text,
      );

      setState(() {
        _isLoading = false;
      });

      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage(user: user)),
        );
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Erreur'),
            content: Text('Identifiants incorrects'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  Widget _buildLogo() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFA67C52).withOpacity(0.1),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFA67C52).withOpacity(0.5),
            blurRadius: 18,
            spreadRadius: 6,
          ),
        ],
      ),
      child: Center(
        child: ClipOval(
          child: Image.asset(
            'assets/horse_logo.png',
            width: 90,
            height: 90,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Arrière-plan
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/equihorizon.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Contenu principal
          Center(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(24.0),
                margin: EdgeInsets.symmetric(horizontal: 24.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 20,
                      spreadRadius: 1,
                      offset: Offset(4, 4),
                    ),
                  ],
                  border: Border.all(
                    color: Color(0xFFA67C52).withOpacity(0.3),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLogo(),
                    SizedBox(height: 16),
                    Text(
                      'EQUIHORIZON',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D2D2D),
                        letterSpacing: 1.5,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Bienvenue sur votre espace de gestion cavalier',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        color: Color(0xFF707070),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 32),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildTextField(
                            controller: _usernameController,
                            label: 'Email',
                            icon: Icons.person,
                          ),
                          SizedBox(height: 16),
                          _buildTextField(
                            controller: _passwordController,
                            label: 'Mot de passe',
                            icon: Icons.lock,
                            isPassword: true,
                          ),
                          SizedBox(height: 32),
                          _isLoading
                              ? CircularProgressIndicator()
                              : ElevatedButton(
                                  onPressed: _submitForm,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFFA67C52),
                                    padding: EdgeInsets.symmetric(
                                      vertical: 14.0,
                                      horizontal: 64.0,
                                    ),
                                    elevation: 5,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                  ),
                                  child: Text(
                                    'Connexion',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Color(0xFFA67C52)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.95),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide(color: Color(0xFFA67C52)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide(color: Color(0xFF3A5A40), width: 2.0),
        ),
      ),
      validator: (value) =>
          value == null || value.isEmpty ? 'Ce champ est obligatoire' : null,
    );
  }
}




class HomePage extends StatefulWidget {
  final User user;
  const HomePage({required this.user});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      ProfilePage(user: widget.user),
      CoursesPage(user: widget.user),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Cours',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFFA67C52),
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  final User user;
  const ProfilePage({required this.user});

  void _logout(BuildContext context) {
    // Affiche le toast de confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Déconnexion réussie'),
        backgroundColor: Color(0xFFA67C52),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );

    // Attendre un petit délai pour laisser le toast apparaître avant le push
    Future.delayed(Duration(seconds: 1), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil Cavalier'),
        backgroundColor: Color(0xFFA67C52),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.account_circle, size: 100, color: Color(0xFFA67C52)),
                SizedBox(height: 16),
                Text(
                  '${user.prenom} ${user.nom}',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Divider(height: 32, thickness: 1),
                ListTile(
                  leading: Icon(Icons.email, color: Colors.brown),
                  title: Text('Email'),
                  subtitle: Text(user.email),
                ),
                ListTile(
                  leading: Icon(Icons.badge, color: Colors.brown),
                  title: Text('ID utilisateur'),
                  subtitle: Text(user.id),
                ),
                ListTile(
                  leading: Icon(Icons.verified_user, color: Colors.brown),
                  title: Text('Rôle'),
                  subtitle: Text('Cavalier'),
                ),
                SizedBox(height: 20),

                // 🔓 Bouton Déconnexion avec toast
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () => _logout(context),
                    icon: Icon(Icons.logout),
                    label: Text('Déconnexion'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFA67C52),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class Cours {
  final String id;
  final String libelle;
  final String heureDebut;
  final String heureFin;
  final String jour;

  Cours({
    required this.id,
    required this.libelle,
    required this.heureDebut,
    required this.heureFin,
    required this.jour,
  });

  factory Cours.fromJson(Map<String, dynamic> json) {
    return Cours(
      id: json['idcours'].toString(),
      libelle: json['libcours'],
      heureDebut: json['hdebut'],
      heureFin: json['hfin'],
      jour: json['jour'],
    );
  }
}

class CoursesPage extends StatefulWidget {
  final User user;
  const CoursesPage({required this.user});

  @override
  _CoursesPageState createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  late Future<List<Cours>> _coursList;
  List<Cours> _allCourses = [];
  List<Cours> _filteredCourses = [];

  TextEditingController _libelleController = TextEditingController();
  TextEditingController _jourController = TextEditingController();
  TextEditingController _heureDebutController = TextEditingController();
  TextEditingController _heureFinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _coursList = fetchCours();
  }

  Future<List<Cours>> fetchCours() async {
    final response = await http.get(
      Uri.parse('http://192.168.248.45/equihorizon/nouveau/get_cours.php'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      _allCourses = data.map((json) => Cours.fromJson(json)).toList();
      _filteredCourses = List.from(_allCourses);
      return _allCourses;
    } else {
      throw Exception('Erreur lors du chargement des cours');
    }
  }

  void filterCourses() {
    String libelle = _libelleController.text.toLowerCase();
    String jour = _jourController.text.toLowerCase();
    String heureDebut = _heureDebutController.text.toLowerCase();
    String heureFin = _heureFinController.text.toLowerCase();

    setState(() {
      _filteredCourses = _allCourses.where((cours) {
        final matchLibelle = libelle.isEmpty || cours.libelle.toLowerCase().contains(libelle);
        final matchJour = jour.isEmpty || cours.jour.toLowerCase().contains(jour);
        final matchDebut = heureDebut.isEmpty || cours.heureDebut.toLowerCase().contains(heureDebut);
        final matchFin = heureFin.isEmpty || cours.heureFin.toLowerCase().contains(heureFin);

        return matchLibelle && matchJour && matchDebut && matchFin;
      }).toList();
    });
  }

  Future<void> inscrireAuCours(String idcours, Cours cours) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.248.45/equihorizon/nouveau/inscription_cours.php'),
        body: {
          'idcours': idcours,
          'idcava': widget.user.id,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message']),
            backgroundColor: data['success'] ? Colors.green : Colors.orange,
          ),
        );

        if (data['success']) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CourseSessionsPage(
                userId: widget.user.id,
                courseId: idcours,
                courseName: cours.libelle,
              ),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur serveur (${response.statusCode})'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur lors de l'inscription : $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<bool> estInscrit(String idcours) async {
    final res = await http.get(Uri.parse(
      'http://192.168.248.45/equihorizon/nouveau/check_inscription.php?idcava=${widget.user.id}&idcours=$idcours'));

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['success'] == true && data['inscrit'] == true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des cours'),
        backgroundColor: Color(0xFFA67C52),
      ),
      body: FutureBuilder<List<Cours>>(
        future: _coursList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Aucun cours trouvé'));
          } else {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _libelleController,
                        decoration: InputDecoration(
                          labelText: 'Rechercher par libellé',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (_) => filterCourses(),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: _jourController,
                        decoration: InputDecoration(
                          labelText: 'Rechercher par jour',
                          prefixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (_) => filterCourses(),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: _heureDebutController,
                        decoration: InputDecoration(
                          labelText: 'Heure de début',
                          prefixIcon: Icon(Icons.access_time),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (_) => filterCourses(),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: _heureFinController,
                        decoration: InputDecoration(
                          labelText: 'Heure de fin',
                          prefixIcon: Icon(Icons.access_time_filled),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (_) => filterCourses(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _filteredCourses.length,
                    itemBuilder: (context, index) {
                      final cours = _filteredCourses[index];
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          title: Text(cours.libelle),
                          subtitle: Text(
                            'Jour : ${cours.jour}\nDe ${cours.heureDebut} à ${cours.heureFin}',
                          ),
                          trailing: FutureBuilder<bool>(
                            future: estInscrit(cours.id),
                            builder: (context, snap) {
                              if (!snap.hasData) return CircularProgressIndicator();
                              final inscrit = snap.data!;
                              return ElevatedButton(
                                onPressed: () {
                                  if (inscrit) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CourseSessionsPage(
                                          userId: widget.user.id,
                                          courseId: cours.id,
                                          courseName: cours.libelle,
                                        ),
                                      ),
                                    );
                                  } else {
                                    inscrireAuCours(cours.id, cours);
                                  }
                                },
                                child: Text(inscrit ? "Voir séances" : "S'inscrire"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      inscrit ? Colors.grey : Color(0xFFA67C52),
                                  foregroundColor: Colors.white,
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _libelleController.dispose();
    _jourController.dispose();
    _heureDebutController.dispose();
    _heureFinController.dispose();
    super.dispose();
  }
}
