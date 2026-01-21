// pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../models/game_session.dart';
import '../services/storage_service.dart';
import '../services/firebase_service.dart';
// import '../services/ad_service.dart';
// import '../services/purchase_service.dart';
import 'game_setup_page.dart';
import 'game_score_page.dart';
import '../widgets/game_card.dart';
import '../widgets/animated_background.dart';

class HomePage extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final bool isDarkMode;

  const HomePage({
    super.key,
    required this.onThemeToggle,
    required this.isDarkMode,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  List<GameSession> _gameSessions = [];
  bool _isLoading = true;
  // bool _adsRemoved = false;
  late AnimationController _fabController;
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurveTween(curve: Curves.elasticOut).animate(_fabController),
    );

    _initializePage();
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  Future<void> _initializePage() async {
    // Log screen view
    await FirebaseService.logScreenView('home_page');

    // Check if ads are removed
    // _adsRemoved = await PurchaseService.hasRemovedAds();

    // Load games
    await _loadGames();
  }

  Future<void> _loadGames() async {
    try {
      final games = await StorageService.loadGameSessions();
      setState(() {
        _gameSessions = games;
        _isLoading = false;
      });
      _fabController.forward();

      // Log user engagement
      await FirebaseService.logFeatureUsed('games_loaded');
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to load games');
      await FirebaseService.recordError(e, StackTrace.current);
    }
  }

  Future<void> _saveGames() async {
    final success = await StorageService.saveGameSessions(_gameSessions);
    if (!success) {
      _showErrorSnackBar('Failed to save games');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
            Icon(
              Icons.sports_esports,
              color: Theme.of(context).appBarTheme.titleTextStyle?.color,
              size: 28,
            ),
            const SizedBox(width: 8),
            const Text('ScoreKeep'),
          ],
        ),
        actions: [
          // Remove ads button if ads not removed
          // if (!_adsRemoved)
          //   IconButton(
          //     icon: const Icon(Icons.block),
          //     onPressed: () {
          //       HapticFeedback.lightImpact();
          //       _showRemoveAdsDialog();
          //     },
          //     tooltip: 'Remove ads',
          //   ),
          IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                widget.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                key: ValueKey(widget.isDarkMode),
              ),
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              widget.onThemeToggle();
            },
            tooltip: 'Toggle theme',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              HapticFeedback.lightImpact();
              _loadGames();
              FirebaseService.logFeatureUsed('refresh_games');
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Stack(
        children: [
          const AnimatedBackground(),
          SafeArea(
            child: Column(
              children: [
                // Banner ad (if ads not removed)
                // if (!_adsRemoved) _buildBannerAd(),

                // Main content
                Expanded(
                  child: _isLoading
                      ? const Center(child: GameLoadingIndicator())
                      : _gameSessions.isEmpty
                          ? _buildEmptyState()
                          : _buildGamesList(),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _fabAnimation,
        builder: (context, child) => Transform.scale(
          scale: _fabAnimation.value,
          child: FloatingActionButton.extended(
            onPressed: () {
              HapticFeedback.mediumImpact();
              _startNewGame();
            },
            icon: const Icon(Icons.add_circle),
            label: const Text(
              'NEW GAME',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            elevation: 12,
          ),
        ),
      ),
    );
  }

  // Widget _buildBannerAd() {
  //   if (!AdService.isBannerAdReady) {
  //     return const SizedBox.shrink();
  //   }

  //   return Container(
  //     alignment: Alignment.center,
  //     width: AdService.bannerAd!.size.width.toDouble(),
  //     height: AdService.bannerAd!.size.height.toDouble(),
  //     margin: const EdgeInsets.symmetric(vertical: 8),
  //     child: AdWidget(ad: AdService.bannerAd!),
  //   );
  // }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor.withOpacity(0.1),
                  Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                ],
              ),
            ),
            child: Icon(
              Icons.sports_esports,
              size: 80,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'READY TO PLAY?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Create your first game and start\ntracking those epic scores!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 48),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor.withOpacity(0.1),
                  Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                ],
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.touch_app,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Tap the NEW GAME button to start',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGamesList() {
    final sortedGames = List<GameSession>.from(_gameSessions)
      ..sort((a, b) => b.lastModified.compareTo(a.lastModified));

    return RefreshIndicator(
      onRefresh: _loadGames,
      backgroundColor: Theme.of(context).cardTheme.color,
      color: Theme.of(context).primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sortedGames.length + 1, // +1 for header spacing
        itemBuilder: (context, index) {
          if (index == 0) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  'YOUR GAMES',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            );
          }

          final game = sortedGames[index - 1];
          return AnimatedGameCard(
            game: game,
            index: index - 1,
            onTap: () => _openGameSession(game),
            onDelete: () => _deleteGame(game),
          );
        },
      ),
    );
  }

  void _startNewGame() async {
    await FirebaseService.logFeatureUsed('new_game_button_tapped');

    final gameSession = await Navigator.push<GameSession>(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, _) => const GameSetupPage(),
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

    if (gameSession != null) {
      setState(() {
        _gameSessions.add(gameSession);
      });
      await _saveGames();

      // Log game creation
      await FirebaseService.logGameCreated(
        gameName: gameSession.gameName,
        playerCount: gameSession.players.length,
      );
    }
  }

  void _openGameSession(GameSession game) async {
    await FirebaseService.logFeatureUsed('game_opened');
    await FirebaseService.logScreenView('game_score_page');

    final updatedGame = await Navigator.push<GameSession>(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, _) =>
            GameScorePage(gameSession: game),
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

    if (updatedGame != null) {
      setState(() {
        final index = _gameSessions.indexWhere((g) => g.id == game.id);
        if (index != -1) {
          _gameSessions[index] = updatedGame;
        }
      });
      await _saveGames();
    }
  }

  void _deleteGame(GameSession game) async {
    await FirebaseService.logFeatureUsed('game_delete_attempted');

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Game'),
        content: Text('Are you sure you want to delete "${game.gameName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _gameSessions.removeWhere((g) => g.id == game.id);
      });
      await _saveGames();
      await FirebaseService.logFeatureUsed('game_deleted');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${game.gameName} deleted'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          action: SnackBarAction(
            label: 'UNDO',
            textColor: Colors.white,
            onPressed: () {
              setState(() {
                _gameSessions.add(game);
              });
              _saveGames();
              FirebaseService.logFeatureUsed('game_delete_undone');
            },
          ),
        ),
      );
    }
  }

  // void _showRemoveAdsDialog() async {
  //   await FirebaseService.logFeatureUsed('remove_ads_dialog_opened');

  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  //       title: Row(
  //         children: [
  //           Container(
  //             padding: const EdgeInsets.all(8),
  //             decoration: BoxDecoration(
  //               color: Theme.of(context).primaryColor,
  //               borderRadius: BorderRadius.circular(12),
  //             ),
  //             child: const Icon(
  //               Icons.block,
  //               color: Colors.white,
  //               size: 24,
  //             ),
  //           ),
  //           const SizedBox(width: 12),
  //           const Text('REMOVE ADS'),
  //         ],
  //       ),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           const Text(
  //             'Enjoy ScoreKeep without any ads for a one-time purchase!',
  //             style: TextStyle(fontSize: 16),
  //           ),
  //           const SizedBox(height: 20),
  //           Container(
  //             padding: const EdgeInsets.all(16),
  //             decoration: BoxDecoration(
  //               color: Theme.of(context).primaryColor.withOpacity(0.1),
  //               borderRadius: BorderRadius.circular(12),
  //             ),
  //             child: Row(
  //               children: [
  //                 Icon(
  //                   Icons.check_circle,
  //                   color: Theme.of(context).primaryColor,
  //                 ),
  //                 const SizedBox(width: 8),
  //                 const Expanded(
  //                   child: Text(
  //                     'Clean, ad-free experience forever',
  //                     style: TextStyle(fontWeight: FontWeight.w500),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: Text(
  //             'MAYBE LATER',
  //             style: TextStyle(
  //               color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
  //               fontWeight: FontWeight.bold,
  //             ),
  //           ),
  //         ),
  //         ElevatedButton(
  //           onPressed: () async {
  //             Navigator.pop(context);
  //             final success = await PurchaseService.purchaseRemoveAds();
  //             if (success) {
  //               setState(() {
  //                 _adsRemoved = true;
  //               });
  //               ScaffoldMessenger.of(context).showSnackBar(
  //                 const SnackBar(
  //                   content: Text('Ads removed successfully!'),
  //                   backgroundColor: Colors.green,
  //                 ),
  //               );
  //             }
  //           },
  //           style: ElevatedButton.styleFrom(
  //             backgroundColor: Theme.of(context).primaryColor,
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(12),
  //             ),
  //           ),
  //           child: const Text(
  //             'REMOVE ADS - \$2.99',
  //             style: TextStyle(
  //               fontWeight: FontWeight.bold,
  //               letterSpacing: 1,
  //               color: Colors.white,
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}

class GameLoadingIndicator extends StatefulWidget {
  const GameLoadingIndicator({super.key});

  @override
  State<GameLoadingIndicator> createState() => _GameLoadingIndicatorState();
}

class _GameLoadingIndicatorState extends State<GameLoadingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: SweepGradient(
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).colorScheme.secondary,
                Theme.of(context).primaryColor,
              ],
              transform: GradientRotation(_controller.value * 2 * 3.14159),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
              child: Icon(
                Icons.sports_esports,
                color: Theme.of(context).primaryColor,
                size: 30,
              ),
            ),
          ),
        );
      },
    );
  }
}
