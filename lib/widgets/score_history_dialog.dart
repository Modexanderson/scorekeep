// widgets/score_history_dialog.dart
import 'package:flutter/material.dart';
import '../models/game_session.dart';

class ScoreHistoryDialog extends StatelessWidget {
  final List<ScoreHistory> history;

  const ScoreHistoryDialog({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Score History'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: history.isEmpty
            ? const Center(
                child: Text('No score changes yet'),
              )
            : ListView.builder(
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final entry = history.reversed.toList()[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            entry.scoreChange > 0 ? Colors.green : Colors.red,
                        child: Text(
                          entry.scoreChange > 0 ? '+' : '',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(entry.playerName),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              '${entry.scoreChange > 0 ? '+' : ''}${entry.scoreChange} points → ${entry.newTotal}'),
                          if (entry.reason != null)
                            Text(
                              entry.reason!,
                              style:
                                  const TextStyle(fontStyle: FontStyle.italic),
                            ),
                        ],
                      ),
                      trailing: Text(
                        _formatTime(entry.timestamp),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
