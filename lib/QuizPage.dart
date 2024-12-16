import 'package:flutter/material.dart';
import 'dart:async'; // Pour le chronomètre
import 'database_helper.dart'; // Importation pour interagir avec la base de données

class QuizPage extends StatefulWidget {
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final DatabaseHelper dbHelper = DatabaseHelper();

  final List<Map<String, Object>> _questions = [
    {
      'question': 'Quelle est la capitale de la France ?',
      'answers': ['Paris', 'Londres', 'Berlin', 'Rome'],
      'correctAnswer': 'Paris',
    },
    {
      'question': 'Quel est le plus grand océan du monde ?',
      'answers': ['Atlantique', 'Pacifique', 'Indien', 'Arctique'],
      'correctAnswer': 'Pacifique',
    },
    {
      'question': 'Combien font 5 + 3 ?',
      'answers': ['6', '7', '8', '9'],
      'correctAnswer': '8',
    },
  ];

  int _currentQuestionIndex = 0;
  int _score = 0;
  int _timeLeft = 30; // Temps par question (en secondes)
  Timer? _timer;
  bool _isQuizCompleted = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

// _startTimer Décompte un chronomètre par question (30 secondes)
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timeLeft == 0) {
        _timer?.cancel();
        _moveToNextQuestion();
      } else {
        setState(() {
          _timeLeft--;
        });
      }
    });
  }

  void _moveToNextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _timeLeft =
            30; // Réinitialiser le chronomètre pour la prochaine question
      });
      _startTimer();
    } else {
      setState(() {
        _isQuizCompleted = true; // Marquer le quiz comme terminé
      });
      _timer?.cancel();
      _saveScore(_score); // Enregistrer le score dans la base de données
    }
  }

//Vérifie si la réponse sélectionnée est correcte.
//Passe automatiquement à la question suivante.
  void _answerQuestion(String selectedAnswer) {
    _timer?.cancel(); // Arrêter le chronomètre pour la question en cours
    if (selectedAnswer == _questions[_currentQuestionIndex]['correctAnswer']) {
      setState(() {
        _score++; // Augmenter le score si la réponse est correcte
      });
    }
    Future.delayed(Duration(seconds: 1),
        _moveToNextQuestion); // Passer à la question suivante
  }

  void _restartQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _score = 0;
      _timeLeft = 30;
      _isQuizCompleted = false;
    });
    _startTimer();
  }

  void _saveScore(int score) async {
    //Enregistre le score final dans la base de données.
    try {
      await dbHelper.insertScore(score);
      print('Score $score enregistré avec succès.');
    } catch (e) {
      print('Erreur lors de l\'enregistrement du score : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Quiz Game',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade300, Colors.teal.shade900],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: !_isQuizCompleted
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Afficher la question
                    Text(
                      _questions[_currentQuestionIndex]['question'] as String,
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 30),
                    // Afficher le chronomètre
                    Text(
                      'Temps restant: $_timeLeft s',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 30),
                    // Afficher les réponses
                    ...(_questions[_currentQuestionIndex]['answers']
                            as List<String>)
                        .map(
                      (answer) {
                        return Container(
                          margin:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                          child: ElevatedButton(
                            //Boutons pour sélectionner une réponse ou redémarrer le quiz.
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal.shade700,
                              padding: EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: () => _answerQuestion(answer),
                            child: Text(
                              answer,
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                        );
                      },
                    ).toList(),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Quiz terminé!',
                      style: TextStyle(
                        fontSize: 28,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Votre score : $_score/${_questions.length}',
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 30),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade700,
                        padding:
                            EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: _restartQuiz,
                      child: Text(
                        'Recommencer',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
