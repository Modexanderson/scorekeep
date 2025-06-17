// widgets/custom_score_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomScoreDialog extends StatefulWidget {
  final List<String> players;
  final Function(String, int, String?) onScoreAdded;

  const CustomScoreDialog({
    super.key,
    required this.players,
    required this.onScoreAdded,
  });

  @override
  State<CustomScoreDialog> createState() => _CustomScoreDialogState();
}

class _CustomScoreDialogState extends State<CustomScoreDialog>
    with TickerProviderStateMixin {
  String? selectedPlayer;
  final _scoreController = TextEditingController();
  final _reasonController = TextEditingController();
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
    );
    _animController.forward();

    // ADD THESE LISTENERS:
    _scoreController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _scoreController.removeListener(() => setState(() {}));
    _scoreController.dispose();
    _reasonController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Theme.of(context).cardTheme.color,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.add_circle,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Flexible(
                child: Text(
                  'CUSTOM SCORE',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                  ),
                ),
                child: DropdownButtonFormField<String>(
                  value: selectedPlayer,
                  decoration: InputDecoration(
                    labelText: 'Select Player',
                    prefixIcon: Icon(
                      Icons.person,
                      color: Theme.of(context).primaryColor,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  items: widget.players.map((player) {
                    return DropdownMenuItem<String>(
                      value: player,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: Theme.of(context).primaryColor,
                            child: Text(
                              player[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(player),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedPlayer = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                  ),
                ),
                child: TextFormField(
                  controller: _scoreController,
                  decoration: InputDecoration(
                    labelText: 'Score to Add',
                    hintText: 'Enter positive or negative number',
                    prefixIcon: Icon(
                      Icons.sports_score,
                      color: Theme.of(context).primaryColor,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(signed: true),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                  ),
                ),
                child: TextFormField(
                  controller: _reasonController,
                  decoration: InputDecoration(
                    labelText: 'Reason (optional)',
                    hintText: 'e.g., Bonus round, Penalty',
                    prefixIcon: Icon(
                      Icons.notes,
                      color: Theme.of(context).primaryColor,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).pop();
              },
              child: Text(
                'CANCEL',
                style: TextStyle(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: selectedPlayer != null &&
                      _scoreController.text.isNotEmpty
                  ? () {
                      HapticFeedback.mediumImpact();
                      final score = int.tryParse(_scoreController.text) ?? 0;
                      final reason = _reasonController.text.trim().isEmpty
                          ? null
                          : _reasonController.text.trim();
                      widget.onScoreAdded(selectedPlayer!, score, reason);
                      Navigator.of(context).pop();
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'ADD SCORE',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
