import 'package:flutter/material.dart';
import 'QuizPage.dart';
import 'database_helper.dart';

class HomePage extends StatelessWidget {
  //Structure principale de la page (AppBar, Body)
  final DatabaseHelper dbHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          // Utilisé pour ajouter un arrière-plan en dégradé.
          gradient: LinearGradient(
            colors: [Colors.teal.shade300, Colors.teal.shade900],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: FutureBuilder(
            //asynchrone
            future: _loadScores(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text(
                  'Erreur de chargement des scores.',
                  style: TextStyle(color: Colors.red, fontSize: 18),
                );
              } else {
                final Map<String, dynamic> scores =
                    snapshot.data as Map<String, dynamic>;
                final bestScore = scores['bestScore'];
                final lastScores = scores['lastScores'];

                return Column(
                  //Organise les éléments verticalement (titre, scores, bouton).
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Quiz Game',
                      style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Meilleur score : ${bestScore != null ? bestScore['score'] : "Aucun"}',
                      style: TextStyle(fontSize: 22, color: Colors.white),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Derniers scores :',
                      style: TextStyle(fontSize: 22, color: Colors.white),
                    ),
                    SizedBox(height: 10),
                    if (lastScores.isNotEmpty)
                      ...lastScores.map<Widget>((score) {
                        return Text(
                          'Score : ${score['score']} | Date : ${score['date']}',
                          style: TextStyle(fontSize: 18, color: Colors.white70),
                        );
                      }).toList()
                    else
                      Text(
                        'Aucun score disponible.',
                        style: TextStyle(fontSize: 18, color: Colors.white70),
                      ),
                    SizedBox(height: 50),
                    ElevatedButton(
                      //démarrer le quiz
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade700,
                        padding:
                            EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => QuizPage()));
                      },
                      child: Text('Start',
                          style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }

//Charge le meilleur score (getBestScore) et les 3 derniers scores (getLastScores) depuis la base de données.
  Future<Map<String, dynamic>> _loadScores() async {
    try {
      // Récupérer le meilleur score et les 3 derniers scores
      final bestScore = await dbHelper.getBestScore();
      final lastScores = await dbHelper.getLastScores();

      print('Meilleur score : $bestScore');
      print('Derniers scores : $lastScores');

      return {
        'bestScore': bestScore,
        'lastScores': lastScores,
      };
    } catch (e) {
      print('Erreur lors du chargement des scores : $e');
      throw Exception('Erreur de chargement des scores');
    }
  }
}
