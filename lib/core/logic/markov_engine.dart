import 'database_helper.dart';

class MarkovEngine {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<void> recordTransition(String stateFrom, String stateTo) async {
    final db = await _dbHelper.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'behavior_transitions',
      where: 'state_from = ? AND state_to = ?',
      whereArgs: [stateFrom, stateTo],
    );

    if (maps.isNotEmpty) {
      final currentCount = maps.first['transition_count'] as int;
      await db.update(
        'behavior_transitions',
        {'transition_count': currentCount + 1},
        where: 'state_from = ? AND state_to = ?',
        whereArgs: [stateFrom, stateTo],
      );
    } else {
      await db.insert(
        'behavior_transitions',
        {
          'state_from': stateFrom,
          'state_to': stateTo,
          'transition_count': 1,
        },
      );
    }
  }

  Future<double> predictNextFailureRisk(String currentState) async {
    final db = await _dbHelper.database;
    
    final List<Map<String, dynamic>> transitions = await db.query(
      'behavior_transitions',
      where: 'state_from = ?',
      whereArgs: [currentState],
    );
    
    double baseRisk = 0.0;
    int totalTransitions = 0;
    
    if (transitions.isNotEmpty) {
      int failureTransitions = 0;
      
      for (var t in transitions) {
        final count = t['transition_count'] as int;
        totalTransitions += count;
        
        final stateTo = t['state_to'] as String;
        if (stateTo.toLowerCase() == 'missed') {
          failureTransitions += count;
        }
      }
      
      if (totalTransitions > 0) {
        baseRisk = failureTransitions / totalTransitions;
      }
    }
    
    final now = DateTime.now();
    final twelveHoursAgo = now.subtract(const Duration(hours: 12));
    
    final List<Map<String, dynamic>> recentLogs = await db.query(
      'ibadah_logs',
      where: 'performed_at >= ?',
      whereArgs: [twelveHoursAgo.toIso8601String()],
    );
    
    int recentFailures = 0;
    int recentTotal = recentLogs.length;
    
    for (var log in recentLogs) {
      final status = log['status'] as String;
      if (status.toLowerCase() == 'missed') {
        recentFailures++;
      }
    }
    
    double recentRiskFactor = 0.0;
    if (recentTotal > 0) {
      recentRiskFactor = recentFailures / recentTotal;
    }
    
    if (totalTransitions == 0 && recentTotal == 0) {
      return 0.0;
    } else if (totalTransitions == 0) {
      return recentRiskFactor;
    } else if (recentTotal == 0) {
      return baseRisk;
    }

    return (baseRisk * 0.6) + (recentRiskFactor * 0.4);
  }
}
