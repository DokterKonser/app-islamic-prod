import 'database_helper.dart';

class DdaEngine {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<void> evaluateAndAdjustDifficulty(String userId) async {
    final db = await _dbHelper.database;
    
    final List<Map<String, dynamic>> results = await db.query(
      'user_dda_stats',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    if (results.isEmpty) {
      return;
    }

    final userStats = results.first;
    final int consecutiveFailures = userStats['consecutive_failures'] as int? ?? 0;
    final int currentDifficultyTier = userStats['difficulty_tier'] as int? ?? 1;

    if (consecutiveFailures > 3) {
      int newDifficultyTier = currentDifficultyTier - 1;
      if (newDifficultyTier < 1) {
        newDifficultyTier = 1;
      }

      await db.update(
        'user_dda_stats',
        {
          'difficulty_tier': newDifficultyTier,
          'consecutive_failures': 0, // Reset to give user a fresh start at new difficulty
        },
        where: 'user_id = ?',
        whereArgs: [userId],
      );
    }
  }
}
