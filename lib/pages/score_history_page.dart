// pages/score_history_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/game_session.dart';
import '../widgets/animated_background.dart';

class ScoreHistoryPage extends StatefulWidget {
  final List<ScoreHistory> history;
  final String gameName;

  const ScoreHistoryPage({
    super.key,
    required this.history,
    required this.gameName,
  });

  @override
  State<ScoreHistoryPage> createState() => _ScoreHistoryPageState();
}

class _ScoreHistoryPageState extends State<ScoreHistoryPage>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late List<Animation<Offset>> _itemAnimations;

  // ADD THESE FILTER VARIABLES:
  String _currentFilter = 'all'; // 'all', 'positive', 'negative', 'recent'
  List<ScoreHistory> get _filteredHistory {
    final baseHistory = widget.history.reversed.toList();

    switch (_currentFilter) {
      case 'positive':
        return baseHistory.where((entry) => entry.scoreChange > 0).toList();
      case 'negative':
        return baseHistory.where((entry) => entry.scoreChange < 0).toList();
      case 'recent':
        final fiveMinutesAgo =
            DateTime.now().subtract(const Duration(minutes: 5));
        return baseHistory
            .where((entry) => entry.timestamp.isAfter(fiveMinutesAgo))
            .toList();
      default:
        return baseHistory;
    }
  }

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _updateItemAnimations();
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  void _updateItemAnimations() {
    final itemCount = widget.history.length;
    _itemAnimations = List.generate(
      itemCount,
      (index) => Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _slideController,
          curve: Interval(
            (index * 0.1).clamp(0.0, 0.8),
            ((index * 0.1) + 0.2).clamp(0.2, 1.0),
            curve: Curves.easeOutCubic,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredHistory = _filteredHistory;

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
                Icons.history,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Flexible(
              child: Text(
                'SCORE HISTORY',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
        ),
        actions: [
          if (widget.history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () {
                HapticFeedback.lightImpact();
                _showFilterOptions();
              },
              tooltip: 'Filter History',
            ),
        ],
      ),
      body: Stack(
        children: [
          const AnimatedBackground(),
          SafeArea(
            child: Column(
              children: [
                // Game Info Header
                SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(-1.0, 0.0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _slideController,
                      curve:
                          const Interval(0.0, 0.3, curve: Curves.easeOutCubic),
                    ),
                  ),
                  child: _buildGameInfoHeader(),
                ),

                // History List
                Expanded(
                  child: widget.history.isEmpty
                      ? _buildEmptyState()
                      : filteredHistory.isEmpty
                          ? _buildNoResultsState()
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: filteredHistory.length,
                              itemBuilder: (context, index) {
                                final entry = filteredHistory[index];
                                return SlideTransition(
                                  position: index < _itemAnimations.length
                                      ? _itemAnimations[index]
                                      : _itemAnimations.last,
                                  child: _buildHistoryItem(entry, index),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameInfoHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
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
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.gameName.toUpperCase(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.timeline,
                      size: 16,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.history.length} score changes',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.sports_esports,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

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
              Icons.history,
              size: 64,
              color: Theme.of(context).primaryColor.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'NO HISTORY YET',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start playing and watch your\nscore history come to life!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
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
              Icons.filter_list_off,
              size: 64,
              color: Theme.of(context).primaryColor.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'NO RESULTS FOUND',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No entries match the current filter.\nTry selecting a different filter.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _currentFilter = 'all';
              });
            },
            icon: const Icon(Icons.clear_all),
            label: const Text('CLEAR FILTER'),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(ScoreHistory entry, int index) {
    final isPositive = entry.scoreChange > 0;
    final isRecent = DateTime.now().difference(entry.timestamp).inMinutes < 5;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: isRecent ? 8 : 4,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: isRecent
                ? LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor.withOpacity(0.05),
                      Theme.of(context).colorScheme.secondary.withOpacity(0.02),
                    ],
                  )
                : null,
            border: isRecent
                ? Border.all(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                  )
                : null,
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: isPositive
                            ? [const Color(0xFF00E676), const Color(0xFF4CAF50)]
                            : [
                                const Color(0xFFFF6B6B),
                                const Color(0xFFF44336)
                              ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isPositive
                                  ? const Color(0xFF00E676)
                                  : const Color(0xFFFF6B6B))
                              .withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        isPositive ? Icons.add : Icons.remove,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  if (isRecent)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            entry.playerName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (isRecent)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'NEW',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        children: [
                          TextSpan(
                            text:
                                '${isPositive ? '+' : ''}${entry.scoreChange}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isPositive
                                  ? const Color(0xFF00E676)
                                  : const Color(0xFFFF6B6B),
                            ),
                          ),
                          const TextSpan(text: ' points → '),
                          TextSpan(
                            text: '${entry.newTotal}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (entry.reason != null) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[800]
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          entry.reason!,
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.7),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatTime(entry.timestamp),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(entry.timestamp),
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterOptions() {
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
                  Icons.filter_list,
                  color: Theme.of(context).primaryColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'FILTER OPTIONS',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const Spacer(),
                if (_currentFilter != 'all')
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _currentFilter = 'all';
                      });
                      Navigator.pop(context);
                    },
                    child: const Text('CLEAR'),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            _buildFilterOption(
              icon: Icons.all_inclusive,
              label: 'Show all entries',
              color: Theme.of(context).primaryColor,
              isSelected: _currentFilter == 'all',
              onTap: () {
                setState(() {
                  _currentFilter = 'all';
                });
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 12),
            _buildFilterOption(
              icon: Icons.add_circle,
              label: 'Show only positive scores',
              color: const Color(0xFF00E676),
              isSelected: _currentFilter == 'positive',
              onTap: () {
                setState(() {
                  _currentFilter = 'positive';
                });
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 12),
            _buildFilterOption(
              icon: Icons.remove_circle,
              label: 'Show only negative scores',
              color: const Color(0xFFFF6B6B),
              isSelected: _currentFilter == 'negative',
              onTap: () {
                setState(() {
                  _currentFilter = 'negative';
                });
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 12),
            _buildFilterOption(
              icon: Icons.access_time,
              label: 'Show recent changes only',
              color: Theme.of(context).colorScheme.secondary,
              isSelected: _currentFilter == 'recent',
              onTap: () {
                setState(() {
                  _currentFilter = 'recent';
                });
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool isSelected = false,
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
              color.withOpacity(isSelected ? 0.2 : 0.1),
              color.withOpacity(isSelected ? 0.1 : 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(isSelected ? 0.6 : 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
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
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: color,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: color,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final itemDate = DateTime(time.year, time.month, time.day);

    if (itemDate == today) {
      return 'Today';
    } else if (itemDate == yesterday) {
      return 'Yesterday';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }
}
