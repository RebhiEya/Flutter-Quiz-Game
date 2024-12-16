import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      // Obtenez le chemin de la base de données
      String path = join(await getDatabasesPath(), 'quiz_scores.db');
      print('Initialisation de la base de données à : $path');

      // Créez la base de données
      return await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          print('Création de la table "scores"...');
          await db.execute(
            '''
            CREATE TABLE scores(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              score INTEGER NOT NULL,
              date TEXT NOT NULL
            )
            ''',
          );
          print('Table "scores" créée avec succès.');
        },
      );
    } catch (e) {
      print('Erreur lors de l’initialisation de la base de données : $e');
      rethrow;
    }
  }

  // Fonction pour insérer un score
  Future<void> insertScore(int score) async {
    try {
      final db = await database;
      await db.insert(
        'scores',
        {'score': score, 'date': DateTime.now().toIso8601String()},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('Score $score inséré avec succès.');
    } catch (e) {
      print('Erreur lors de l’insertion d’un score : $e');
    }
  }

  // Fonction pour récupérer le meilleur score
  Future<Map<String, dynamic>?> getBestScore() async {
    try {
      final db = await database;
      var result =
          await db.rawQuery('SELECT * FROM scores ORDER BY score DESC LIMIT 1');
      print('Meilleur score récupéré : $result');
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      print('Erreur lors de la récupération du meilleur score : $e');
      return null;
    }
  }

  // Fonction pour récupérer les 3 derniers scores
  Future<List<Map<String, dynamic>>> getLastScores() async {
    final db = await database;
    var result =
        await db.rawQuery('SELECT * FROM scores ORDER BY date DESC LIMIT 3');
    print('Derniers scores récupérés : $result');
    return result;
  }
}
