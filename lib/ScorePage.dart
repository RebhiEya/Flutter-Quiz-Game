import 'package:flutter/material.dart';

class ScorePage extends StatelessWidget {
  final List<Map<String, dynamic>> scores;

  ScorePage({required this.scores});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Derniers Scores'),
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
          child: scores.isEmpty
              ? Center(
                  child: Text(
                    'Aucun score enregistré.',
                    style: TextStyle(fontSize: 18, color: Colors.teal),
                  ),
                )
              : ListView.builder(
                  itemCount: scores.length,
                  itemBuilder: (context, index) {
                    final score = scores[index];
                    return ListTile(
                      title: Text(
                        'Score : ${score['score']}',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      subtitle: Text(
                        'Date : ${score['date']}',
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
