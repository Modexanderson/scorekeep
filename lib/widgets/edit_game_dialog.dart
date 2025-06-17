// widgets/edit_game_dialog.dart
import 'package:flutter/material.dart';
import '../models/game_session.dart';

class EditGameDialog extends StatefulWidget {
  final GameSession gameSession;

  const EditGameDialog({super.key, required this.gameSession});

  @override
  State<EditGameDialog> createState() => _EditGameDialogState();
}

class _EditGameDialogState extends State<EditGameDialog> {
  late TextEditingController _gameNameController;
  late List<String> _players;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _gameNameController =
        TextEditingController(text: widget.gameSession.gameName);
    _players = List.from(widget.gameSession.players);
  }

  @override
  void dispose() {
    _gameNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Game'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _gameNameController,
                decoration: const InputDecoration(
                  labelText: 'Game Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a game name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Players',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _players.length,
                  itemBuilder: (context, index) {
                    final player = _players[index];
                    final hasScore = widget.gameSession.scores[player] != 0;

                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(player[0].toUpperCase()),
                        ),
                        title: Text(player),
                        subtitle: hasScore
                            ? Text(
                                'Score: ${widget.gameSession.scores[player]}')
                            : null,
                        trailing: _players.length > 2
                            ? IconButton(
                                icon: Icon(
                                  Icons.remove_circle,
                                  color: hasScore ? Colors.grey : Colors.red,
                                ),
                                onPressed: hasScore
                                    ? null
                                    : () {
                                        setState(() {
                                          _players.removeAt(index);
                                        });
                                      },
                                tooltip: hasScore
                                    ? 'Cannot remove player with scores'
                                    : 'Remove player',
                              )
                            : null,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _addNewPlayer,
                icon: const Icon(Icons.person_add),
                label: const Text('Add New Player'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _saveChanges,
          child: const Text('Save Changes'),
        ),
      ],
    );
  }

  void _addNewPlayer() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Add New Player'),
          content: TextFormField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Player Name',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final name = controller.text.trim();
                if (name.isNotEmpty && !_players.contains(name)) {
                  setState(() {
                    _players.add(name);
                  });
                  Navigator.of(context).pop();
                } else if (_players.contains(name)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Player name already exists')),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate() && _players.length >= 2) {
      // Create updated game session
      final updatedSession = widget.gameSession.copyWith(
        gameName: _gameNameController.text.trim(),
        players: _players,
      );

      // Add new players to scores map
      for (final player in _players) {
        if (!updatedSession.scores.containsKey(player)) {
          updatedSession.scores[player] = 0;
        }
      }

      // Remove scores for players no longer in the game
      final playersToRemove = updatedSession.scores.keys
          .where((player) => !_players.contains(player))
          .toList();

      for (final player in playersToRemove) {
        updatedSession.scores.remove(player);
      }

      Navigator.of(context).pop(updatedSession);
    } else if (_players.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Game must have at least 2 players')),
      );
    }
  }
}
