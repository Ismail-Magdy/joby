class GameCooldownStatus {
  final String gameId;
  final DateTime? lastPlayedAt;
  final Duration cooldownDuration;

  const GameCooldownStatus({
    required this.gameId,
    this.lastPlayedAt,
    required this.cooldownDuration,
  });

  /// Whether the game is currently playable
  bool get isAvailable {
    if (lastPlayedAt == null) return true;
    final now = DateTime.now();
    return now.isAfter(availableAt);
  }

  /// Timestamp when the game will become playable again
  DateTime get availableAt {
    if (lastPlayedAt == null) return DateTime.now();
    return lastPlayedAt!.add(cooldownDuration);
  }

  /// Duration left until the game can be played again
  Duration get remainingCooldown {
    if (isAvailable) return Duration.zero;
    final remaining = availableAt.difference(DateTime.now());
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
