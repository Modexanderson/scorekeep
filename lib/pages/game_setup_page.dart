// pages/game_setup_page.dart (Analytics Integration)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/game_session.dart';
import '../services/firebase_service.dart';
import '../widgets/animated_background.dart';

class GameSetupPage extends StatefulWidget {
  const GameSetupPage({super.key});

  @override
  State<GameSetupPage> createState() => _GameSetupPageState();
}

class _GameSetupPageState extends State<GameSetupPage>
    with TickerProviderStateMixin {
  final _gameNameController = TextEditingController();
  final List<TextEditingController> _playerControllers = [];
  final _formKey = GlobalKey<FormState>();
  late AnimationController _slideController;
  late AnimationController _fabController;
  late List<Animation<Offset>> _playerAnimations;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Add initial players
    _addPlayer();
    _addPlayer();

    _updatePlayerAnimations();
    _slideController.forward();
    _fabController.forward();

    // Log screen view
    _logPageView();
  }

  @override
  void dispose() {
    _gameNameController.dispose();
    for (final controller in _playerControllers) {
      controller.dispose();
    }
    _slideController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  Future<void> _logPageView() async {
    await FirebaseService.logScreenView('game_setup_page');
    await FirebaseService.logFeatureUsed('new_game_setup_opened');
  }

  void _updatePlayerAnimations() {
    _playerAnimations = List.generate(
      _playerControllers.length,
      (index) => Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _slideController,
          curve: Interval(
            index * 0.1,
            (index * 0.1) + 0.4,
            curve: Curves.easeOutCubic,
          ),
        ),
      ),
    );
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
                Icons.add_circle,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text('NEW GAME SETUP'),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            HapticFeedback.lightImpact();
            FirebaseService.logFeatureUsed('game_setup_cancelled');
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          const AnimatedBackground(),
          SafeArea(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 20),

                          // Game Name Section
                          SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(-1.0, 0.0),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: _slideController,
                                curve: const Interval(0.0, 0.4,
                                    curve: Curves.easeOutCubic),
                              ),
                            ),
                            child: _buildGameNameSection(),
                          ),

                          const SizedBox(height: 40),

                          // Players Section
                          SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(-1.0, 0.0),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: _slideController,
                                curve: const Interval(0.2, 0.6,
                                    curve: Curves.easeOutCubic),
                              ),
                            ),
                            child: _buildPlayersHeader(),
                          ),

                          const SizedBox(height: 20),

                          // Player List
                          ..._buildPlayersList(),

                          const SizedBox(height: 20),

                          // Add Player Button
                          SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.0, 1.0),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: _slideController,
                                curve: const Interval(0.6, 1.0,
                                    curve: Curves.easeOutCubic),
                              ),
                            ),
                            child: _buildAddPlayerButton(),
                          ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Action Buttons
                  SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.0, 1.0),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: _fabController,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                    child: _buildBottomActions(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameNameSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).cardTheme.color!,
            Theme.of(context).cardTheme.color!.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.sports_esports,
                color: Theme.of(context).primaryColor,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'GAME NAME',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _gameNameController,
            decoration: InputDecoration(
              hintText: 'Enter game name (e.g., Monopoly, Scrabble)',
              prefixIcon: Icon(
                Icons.gamepad,
                color: Theme.of(context).primaryColor,
              ),
              filled: true,
              fillColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[800]
                  : Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.all(20),
            ),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a game name';
              }
              return null;
            },
            onChanged: (value) {
              // Log game name input for analytics
              if (value.length > 3) {
                FirebaseService.logFeatureUsed('game_name_entered');
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPlayersHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.1),
            Theme.of(context).colorScheme.secondary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.people,
                color: Theme.of(context).primaryColor,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'PLAYERS',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              '${_playerControllers.length} PLAYERS',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPlayersList() {
    return List.generate(_playerControllers.length, (index) {
      return SlideTransition(
        position: _playerAnimations[index],
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Card(
            elevation: 4,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).cardTheme.color!,
                    Theme.of(context).cardTheme.color!.withOpacity(0.8),
                  ],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).colorScheme.secondary,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _playerControllers[index],
                      decoration: InputDecoration(
                        labelText: 'Player ${index + 1}',
                        hintText: 'Enter player name',
                        filled: true,
                        fillColor:
                            Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey[800]
                                : Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).primaryColor,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter player name';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        // Log player name input
                        if (value.length > 2) {
                          FirebaseService.logFeatureUsed('player_name_entered');
                        }
                      },
                    ),
                  ),
                  if (_playerControllers.length > 2) ...[
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        _removePlayer(index);
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.error,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context)
                                  .colorScheme
                                  .error
                                  .withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.remove,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildAddPlayerButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        _addPlayer();
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).primaryColor,
            width: 2,
            style: BorderStyle.solid,
          ),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.1),
              Theme.of(context).colorScheme.secondary.withOpacity(0.05),
            ],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_add,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              'ADD ANOTHER PLAYER',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(20),
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
            flex: 2,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                ),
              ),
              child: TextButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  FirebaseService.logFeatureUsed('game_setup_cancelled');
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text(
                  'BACK',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
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
                onPressed: _startGame,
                icon: const Icon(Icons.play_arrow, size: 28),
                label: const Text(
                  'START GAME',
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

  void _addPlayer() {
    setState(() {
      _playerControllers.add(TextEditingController());
      _updatePlayerAnimations();
    });

    // Log player addition
    FirebaseService.logFeatureUsed('player_added');
    FirebaseService.log('Player added, total: ${_playerControllers.length}');

    // Animate the new player in
    _slideController.reset();
    _slideController.forward();
  }

  void _removePlayer(int index) {
    setState(() {
      _playerControllers[index].dispose();
      _playerControllers.removeAt(index);
      _updatePlayerAnimations();
    });

    // Log player removal
    FirebaseService.logFeatureUsed('player_removed');
    FirebaseService.log('Player removed, total: ${_playerControllers.length}');

    // Re-animate all players
    _slideController.reset();
    _slideController.forward();
  }

  void _startGame() async {
    if (_formKey.currentState!.validate() && _playerControllers.length >= 2) {
      final playerNames = _playerControllers
          .map((controller) => controller.text.trim())
          .where((name) => name.isNotEmpty)
          .toList();

      if (playerNames.length < 2) {
        _showSnackBar('Please add at least 2 players', isError: true);
        FirebaseService.logFeatureUsed(
            'game_start_failed_insufficient_players');
        return;
      }

      // Check for duplicate names
      final uniqueNames = playerNames.toSet();
      if (uniqueNames.length != playerNames.length) {
        _showSnackBar('Player names must be unique', isError: true);
        FirebaseService.logFeatureUsed('game_start_failed_duplicate_names');
        return;
      }

      final gameSession = GameSession(
        gameName: _gameNameController.text.trim(),
        players: playerNames,
      );

      // Log successful game creation
      await FirebaseService.logGameCreated(
        gameName: gameSession.gameName,
        playerCount: gameSession.players.length,
      );

      await FirebaseService.logFeatureUsed('game_created_successfully');
      await FirebaseService.log(
          'Game created: ${gameSession.gameName} with ${gameSession.players.length} players');

      HapticFeedback.heavyImpact();
      Navigator.pop(context, gameSession);
    } else if (_playerControllers.length < 2) {
      _showSnackBar('Please add at least 2 players', isError: true);
      FirebaseService.logFeatureUsed('game_start_failed_insufficient_players');
    } else {
      FirebaseService.logFeatureUsed('game_start_failed_validation');
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error : Icons.check_circle,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              message,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        backgroundColor: isError
            ? Theme.of(context).colorScheme.error
            : const Color(0xFF00E676),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
