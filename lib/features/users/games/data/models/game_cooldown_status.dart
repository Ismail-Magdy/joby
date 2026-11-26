class GameCooldownStatus {
  final String gameId;
  final DateTime? lastPlayedAt;
  final Duration cooldownDuration;

  const GameCooldownStatus({
    required this.gameId,
    this.lastPlayedAt,
    required this.cooldownDuration,
  });

  /// Whether the game was already played during the current local calendar day
  bool get isPlayedToday {
    if (lastPlayedAt == null) return false;
    final localLastPlayed = lastPlayedAt!.toLocal();
    final now = DateTime.now();
    return localLastPlayed.year == now.year &&
        localLastPlayed.month == now.month &&
        localLastPlayed.day == now.day;
  }

  /// Whether the game is currently playable (resets strictly at 12:00 AM midnight)
  bool get isAvailable => !isPlayedToday;

  /// Timestamp of the next 12:00 AM midnight when the game unlocks
  DateTime get availableAt {
    final now = DateTime.now();
    if (isAvailable) return now;
    return DateTime(now.year, now.month, now.day + 1);
  }

  /// Duration left until next 12:00 AM midnight
  Duration get remainingCooldown {
    if (isAvailable) return Duration.zero;
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    final remaining = nextMidnight.difference(now);
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Human readable remaining time format (e.g. "12h 45m" or "Ready")
  String get remainingTimeString {
    if (isAvailable) return "Ready";
    final remaining = remainingCooldown;
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;
    final seconds = remaining.inSeconds % 60;

    if (hours > 0) {
      return "${hours}h ${minutes}m";
    } else if (minutes > 0) {
      return "${minutes}m ${seconds}s";
    } else {
      return "${seconds}s";
    }
  }
}
