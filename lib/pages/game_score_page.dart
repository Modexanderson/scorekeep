// pages/game_score_page.dart (Analytics Integration)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/game_session.dart';
import '../services/firebase_service.dart';
import '../widgets/custom_score_dialog.dart';
import '../widgets/animated_background.dart';
import '../widgets/player_score_card.dart';
import 'score_history_page.dart';

class GameScorePage extends StatefulWidget {
  final GameSession gameSession;

  const GameScorePage({super.key, required this.gameSession});

  @override
  State<GameScorePage> createState() => _GameScorePageState();
}

class _GameScorePageState extends State<GameScorePage>
    with TickerProviderStateMixin {
  late GameSession _currentSession;
  String? _lastUpdatedPlayer;
  DateTime? _sessionStartTime;

  @override
  void initState() {
    super.initState();
    _currentSession = widget.gameSession;
    _sessionStartTime = DateTime.now();

    // Log screen view and session start
    _logSessionStart();
  }

  @override
  void dispose() {
    // Log session end when leaving the page
    _logSessionEnd();
    super.dispose();
  }

  Future<void> _logSessionStart() async {
    await FirebaseService.logScreenView('game_score_page');
    await FirebaseService.log(
        'Game session started: ${_currentSession.gameName}');
  }

  Future<void> _logSessionEnd() async {
    if (_sessionStartTime != null) {
      final sessionDuration =
          DateTime.now().difference(_sessionStartTime!).inMinutes;
      await FirebaseService.logGameSessionEnd(
        gameId: _currentSession.id,
        sessionDurationMinutes: sessionDuration,
        totalScoreChanges: _currentSession.history.length,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
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
                Icons.sports_esports,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                _currentSession.gameName.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context, _currentSession);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              HapticFeedback.lightImpact();
              _showHistory();
            },
            tooltip: 'Score History',
          ),
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: _currentSession.history.isNotEmpty
                ? () {
                    HapticFeedback.mediumImpact();
                    _undoLastScore();
                  }
                : null,
            tooltip: 'Undo Last Score',
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'reset',
                child: Row(
                  children: [
                    Icon(Icons.refresh, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 8),
                    const Text('Reset Scores'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share,
                        color: Theme.of(context).colorScheme.secondary),
                    const SizedBox(width: 8),
                    const Text('Share Results'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              HapticFeedback.lightImpact();
              switch (value) {
                case 'reset':
                  _resetScores();
                  break;
                case 'share':
                  _shareResults();
                  break;
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          const AnimatedBackground(),
          SafeArea(
            child: Column(
              children: [
                // Leader Banner
                _buildLeaderBanner(),

                // Players List
                Flexible(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _currentSession.players.length,
                    itemBuilder: (context, index) {
                      final sortedPlayers = _currentSession.getSortedPlayers();
                      final playerEntry = sortedPlayers[index];
                      final playerName = playerEntry.key;
                      final score = playerEntry.value;
                      final rank = index + 1;
                      final isLastUpdated = _lastUpdatedPlayer == playerName;

                      return PlayerScoreCard(
                        playerName: playerName,
                        score: score,
                        rank: rank,
                        onIncrement: () => _updateScore(playerName, 1),
                        onDecrement: () => _updateScore(playerName, -1),
                        isAnimating: isLastUpdated,
                      );
                    },
                  ),
                ),

                // Bottom Action Buttons
                _buildBottomActions(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderBanner() {
    final leader = _currentSession.getCurrentLeader();
    final isMultipleLeaders = leader.contains('Tie:');

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFFD700).withOpacity(0.9),
            const Color(0xFFFFA000).withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isMultipleLeaders ? Icons.people : Icons.emoji_events,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isMultipleLeaders ? 'CURRENT TIE' : 'CURRENT LEADER',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  leader,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (!isMultipleLeaders)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.star,
                color: Colors.white,
                size: 24,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).primaryColor.withOpacity(0.2),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).colorScheme.secondary,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  _showCustomScoreDialog();
                },
                icon: const Icon(Icons.add_circle, size: 24),
                label: const Text(
                  'CUSTOM SCORE',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.secondary,
                    Theme.of(context).primaryColor,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  _showQuickActions();
                },
                icon: const Icon(Icons.flash_on, size: 24),
                label: const Text(
                  'QUICK',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _updateScore(String playerName, int change) {
    setState(() {
      _currentSession.addScore(playerName, change);
      _currentSession = _currentSession.copyWith(lastModified: DateTime.now());
      _lastUpdatedPlayer = playerName;
    });

    // Log score change
    FirebaseService.logScoreAdded(
      gameId: _currentSession.id,
      playerName: playerName,
      scoreChange: change,
      method: change > 0 ? 'increment' : 'decrement',
    );

    HapticFeedback.lightImpact();
  }

  void _undoLastScore() {
    setState(() {
      if (_currentSession.undoLastScore()) {
        _currentSession =
            _currentSession.copyWith(lastModified: DateTime.now());
        _showSnackBar('Last score undone', isSuccess: true);

        // Log undo action
        FirebaseService.logFeatureUsed('undo_score');
      }
    });
  }

  void _resetScores() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.refresh, color: Theme.of(context).primaryColor),
              const SizedBox(width: 12),
              const Text('RESET SCORES'),
            ],
          ),
          content: const Text(
            'Are you sure you want to reset all scores to 0? This action cannot be undone.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
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
              onPressed: () {
                setState(() {
                  _currentSession.resetScores();
                  _currentSession =
                      _currentSession.copyWith(lastModified: DateTime.now());
                });
                Navigator.of(context).pop();
                _showSnackBar('All scores reset', isSuccess: true);

                // Log reset action
                FirebaseService.logFeatureUsed('reset_scores');
                HapticFeedback.heavyImpact();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'RESET',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _shareResults() {
    final results = _generateResultsText();

    // Log share action
    FirebaseService.logFeatureUsed('share_results');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.share, color: Theme.of(context).primaryColor),
            const SizedBox(width: 12),
            const Text('GAME RESULTS'),
          ],
        ),
        content: Container(
          constraints: const BoxConstraints(maxHeight: 300),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[800]
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    results,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Copy this text to share your epic game results!',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'CLOSE',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _showSnackBar('Results copied to clipboard!', isSuccess: true);
              Navigator.of(context).pop();
              HapticFeedback.mediumImpact();
            },
            child: const Text(
              'COPY',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _generateResultsText() {
    final sortedPlayers = _currentSession.getSortedPlayers();
    final buffer = StringBuffer();

    buffer.writeln('🎮 ${_currentSession.gameName.toUpperCase()} RESULTS 🎮');
    buffer.writeln('=' * 40);
    buffer.writeln('');

    for (int i = 0; i < sortedPlayers.length; i++) {
      final entry = sortedPlayers[i];
      final rank = i + 1;
      String medal = '';

      switch (rank) {
        case 1:
          medal = '🥇';
          break;
        case 2:
          medal = '🥈';
          break;
        case 3:
          medal = '🥉';
          break;
        default:
          medal = '$rank.';
      }

      buffer.writeln('$medal ${entry.key}: ${entry.value} points');
    }

    buffer.writeln('');
    buffer.writeln('Generated by ScoreKeep 📊');
    buffer.writeln('The ultimate gaming score tracker!');

    return buffer.toString();
  }

  void _showQuickActions() {
    // Log quick actions usage
    FirebaseService.logFeatureUsed('quick_actions_opened');

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(
                  Icons.flash_on,
                  color: Theme.of(context).primaryColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'QUICK ACTIONS',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildQuickActionButton(
              icon: Icons.add,
              label: 'Add 1 point to everyone',
              color: const Color(0xFF00E676),
              onTap: () {
                Navigator.pop(context);
                _addPointsToAll(1);
              },
            ),
            const SizedBox(height: 12),
            _buildQuickActionButton(
              icon: Icons.add_circle,
              label: 'Add 5 points to everyone',
              color: const Color(0xFF4CAF50),
              onTap: () {
                Navigator.pop(context);
                _addPointsToAll(5);
              },
            ),
            const SizedBox(height: 12),
            _buildQuickActionButton(
              icon: Icons.remove,
              label: 'Remove 1 point from everyone',
              color: const Color(0xFFFF6B6B),
              onTap: () {
                Navigator.pop(context);
                _addPointsToAll(-1);
              },
            ),
            const SizedBox(height: 12),
            _buildQuickActionButton(
              icon: Icons.emoji_events,
              label: 'Declare Round Winner',
              color: const Color(0xFFFFD700),
              onTap: () {
                Navigator.pop(context);
                _showRoundWinnerDialog();
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addPointsToAll(int points) {
    setState(() {
      for (final player in _currentSession.players) {
        _currentSession.addScore(
          player,
          points,
          reason: 'Quick action: ${points > 0 ? '+' : ''}$points to all',
        );
      }
      _currentSession = _currentSession.copyWith(lastModified: DateTime.now());
    });

    // Log bulk score addition
    FirebaseService.logFeatureUsed('quick_action_bulk_score');
    FirebaseService.logScoreAdded(
      gameId: _currentSession.id,
      playerName: 'ALL_PLAYERS',
      scoreChange: points,
      method: 'quick_action_bulk',
    );

    _showSnackBar(
      'Added ${points > 0 ? '+' : ''}$points to all players',
      isSuccess: true,
    );

    HapticFeedback.mediumImpact();
  }

  void _showRoundWinnerDialog() {
    String? selectedPlayer;

    // Log round winner dialog usage
    FirebaseService.logFeatureUsed('round_winner_dialog_opened');

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.emoji_events,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text('ROUND WINNER'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Who dominated this round?',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
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
                    labelText: 'Select Winner',
                    prefixIcon: Icon(
                      Icons.person,
                      color: Theme.of(context).primaryColor,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  items: _currentSession.players.map((player) {
                    return DropdownMenuItem<String>(
                      value: player,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: const Color(0xFFFFD700),
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
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
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
              onPressed: selectedPlayer != null
                  ? () {
                      this.setState(() {
                        _currentSession.addScore(
                          selectedPlayer!,
                          10,
                          reason: 'Round winner',
                        );
                        _currentSession = _currentSession.copyWith(
                          lastModified: DateTime.now(),
                        );
                        _lastUpdatedPlayer = selectedPlayer;
                      });

                      // Log round winner selection
                      FirebaseService.logFeatureUsed('round_winner_awarded');
                      FirebaseService.logScoreAdded(
                        gameId: _currentSession.id,
                        playerName: selectedPlayer!,
                        scoreChange: 10,
                        method: 'round_winner',
                      );

                      Navigator.of(context).pop();
                      _showSnackBar(
                        '$selectedPlayer wins the round! +10 points',
                        isSuccess: true,
                      );
                      HapticFeedback.heavyImpact();
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'AWARD 10 POINTS',
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

  void _showHistory() {
    // Log history view
    FirebaseService.logFeatureUsed('score_history_opened');

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, _) => ScoreHistoryPage(
          history: _currentSession.history,
          gameName: _currentSession.gameName,
        ),
        transitionsBuilder: (context, animation, _, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                  .chain(CurveTween(curve: Curves.easeOutCubic)),
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _showCustomScoreDialog() {
    // Log custom score dialog usage
    FirebaseService.logFeatureUsed('custom_score_dialog_opened');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomScoreDialog(
          players: _currentSession.players,
          onScoreAdded: (playerName, score, reason) {
            setState(() {
              _currentSession.addScore(playerName, score, reason: reason);
              _currentSession =
                  _currentSession.copyWith(lastModified: DateTime.now());
              _lastUpdatedPlayer = playerName;
            });

            // Log custom score addition
            FirebaseService.logScoreAdded(
              gameId: _currentSession.id,
              playerName: playerName,
              scoreChange: score,
              method: 'custom',
            );

            HapticFeedback.mediumImpact();
          },
        );
      },
    );
  }

  void _showSnackBar(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.info,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isSuccess
            ? const Color(0xFF00E676)
            : Theme.of(context).primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
