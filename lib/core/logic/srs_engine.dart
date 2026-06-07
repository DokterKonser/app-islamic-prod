import 'database_helper.dart';

class SrsEngine {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<void> processReview(String cardId, int qualityScore) async {
    final db = await _dbHelper.database;
    
    final int? id = int.tryParse(cardId);
    List<Map<String, dynamic>> results;

    if (id != null) {
      results = await db.query(
        'srs_cards',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (results.isEmpty) {
        results = await db.query(
          'srs_cards',
          where: 'target_id = ?',
          whereArgs: [cardId],
        );
      }
    } else {
      results = await db.query(
        'srs_cards',
        where: 'target_id = ?',
        whereArgs: [cardId],
      );
    }

    if (results.isEmpty) return;

    final card = results.first;
    final int actualId = card['id'] as int;
    
    double easinessFactor = (card['easiness_factor'] as num?)?.toDouble() ?? 2.5;
    int intervalDays = card['interval_days'] as int? ?? 0;
    int repetitions = card['repetitions'] as int? ?? 0;

    // SuperMemo-2 Algorithm
    if (qualityScore >= 3) {
      if (repetitions == 0) {
        intervalDays = 1;
      } else if (repetitions == 1) {
        intervalDays = 6;
      } else {
        intervalDays = (intervalDays * easinessFactor).round();
      }
      repetitions++;
    } else {
      repetitions = 0;
      intervalDays = 1;
    }

    easinessFactor = easinessFactor + (0.1 - (5 - qualityScore) * (0.08 + (5 - qualityScore) * 0.02));
    if (easinessFactor < 1.3) {
      easinessFactor = 1.3;
    }

    final DateTime nextReviewDate = DateTime.now().add(Duration(days: intervalDays));

    await db.update(
      'srs_cards',
      {
        'easiness_factor': easinessFactor,
        'interval_days': intervalDays,
        'repetitions': repetitions,
        'next_review_date': nextReviewDate.toIso8601String(),
        'last_quality_score': qualityScore,
      },
      where: 'id = ?',
      whereArgs: [actualId],
    );
  }
}
