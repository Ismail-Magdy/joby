import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Interactive pixel-art mascot that roams the Job Seeker screens.
///
/// Mount as the top child in a [Stack] overlay inside [UserRootScreen].
/// Only the buddy's bounding box intercepts taps , the rest of the
/// screen remains fully interactive via [IgnorePointer].
class JobyPixelBuddy extends StatefulWidget {
  const JobyPixelBuddy({super.key});

  @override
  State<JobyPixelBuddy> createState() => _JobyPixelBuddyState();
}

// Expression states
enum _BuddyExpression { idle, jumping, annoyed, pleading, resigned, taunting }

//  Movement types
enum _MoveType { cornerPeek, centerHop, crossDash, diagonalLeap }

class _JobyPixelBuddyState extends State<JobyPixelBuddy>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  //  Palette
  static const _darkNavy = Color(0xFF0A2540);
  static const _mediumBlue = Color(0xFF1565C0);
  static const _brightBlue = Color(0xFF1E88E5);
  static const _white = Color(0xFFFFFFFF);
  static const _lightCyan = Color(0xFF4FC3F7);
  static const _gold = Color(0xFFFFD54F);

  // Sizing
  double get _buddySize => 64.w;

  //  Position & direction
  double _posX = 20;
  double _posY = 200;
  bool _facingRight = true;

  //  Expression
  _BuddyExpression _expression = _BuddyExpression.idle;

  //  Tap escalation
  int _tapStage = 0;
  Timer? _tapResetTimer;

  //  Speech bubble
  String? _speechWord;
  Timer? _speechTimer;

  //  Autonomous roaming
  Timer? _roamTimer;
  Timer? _tauntTimer; // 60s untapped

  //  Animation controllers
  late AnimationController _bounceController;
  late Animation<double> _bounceAnim;

  late AnimationController _moveController;
  Animation<double>? _moveAnimX;
  Animation<double>? _moveAnimY;

  late AnimationController _squashController;
  late Animation<double> _squashX;
  late Animation<double> _squashY;

  //  Audio
  late final AudioPlayer _audioPlayer;

  //  Random
  final _rng = Random();

  //  Lifecycle flag
  bool _paused = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _audioPlayer = AudioPlayer();
    _audioPlayer.setReleaseMode(.stop);

    // Bounce (idle bob)
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _bounceAnim = Tween<double>(begin: 0, end: -6.w).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );

    // Move (position interpolation)
    _moveController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 600),
        )..addStatusListener((status) {
          if (status == .completed) {
            _landSquash();
          }
        });

    // Squash & stretch
    _squashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _squashX = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _squashController, curve: Curves.easeOut),
    );
    _squashY = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(parent: _squashController, curve: Curves.easeOut),
    );

    _scheduleRoam();
    _resetTauntTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _bounceController.dispose();
    _moveController.dispose();
    _squashController.dispose();
    _roamTimer?.cancel();
    _tauntTimer?.cancel();
    _tapResetTimer?.cancel();
    _speechTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  //  Lifecycle observer
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == .paused || state == .inactive) {
      _paused = true;
      _roamTimer?.cancel();
      _tauntTimer?.cancel();
      _tapResetTimer?.cancel();
      _speechTimer?.cancel();
      _audioPlayer.stop();
      _bounceController.stop();
    } else if (state == .resumed) {
      _paused = false;
      _bounceController.repeat(reverse: true);
      _scheduleRoam();
      _resetTauntTimer();
    }
  }

  /// ROAMING
  void _scheduleRoam() {
    _roamTimer?.cancel();
    final delay = Duration(seconds: 4 + _rng.nextInt(7)); // 4-10s
    _roamTimer = Timer(delay, _performRoam);
  }

  void _performRoam() {
    if (_paused || !mounted) return;

    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height;
    final maxX = screenW - _buddySize - 8;
    final maxY = screenH - _buddySize - 120.h; // above bottom nav
    final minY = 60.h; // below status bar area

    final moves = _MoveType.values;
    final move = moves[_rng.nextInt(moves.length)];

    double targetX;
    double targetY;
    Duration duration;

    switch (move) {
      case _MoveType.cornerPeek:
        // Pick a corner
        final corners = [
          Offset(8, minY),
          Offset(maxX, minY),
          Offset(8, maxY),
          Offset(maxX, maxY),
        ];
        final corner = corners[_rng.nextInt(corners.length)];
        targetX = corner.dx;
        targetY = corner.dy;
        duration = const Duration(milliseconds: 900);
        break;

      case _MoveType.centerHop:
        targetX =
            (screenW / 2) - (_buddySize / 2) + _rng.nextDouble() * 40 - 20;
        targetY =
            (screenH / 2) - (_buddySize / 2) + _rng.nextDouble() * 60 - 30;
        duration = const Duration(milliseconds: 700);
        break;

      case _MoveType.crossDash:
        // Dash horizontally across
        targetX = _posX < screenW / 2 ? maxX : 8;
        targetY = _posY + _rng.nextDouble() * 80 - 40;
        duration = const Duration(milliseconds: 500);
        break;

      case _MoveType.diagonalLeap:
        targetX = _rng.nextDouble() * maxX;
        targetY = minY + _rng.nextDouble() * (maxY - minY);
        duration = const Duration(milliseconds: 800);
        break;
    }

    targetX = targetX.clamp(8, maxX);
    targetY = targetY.clamp(minY, maxY);

    _animateMoveTo(targetX, targetY, duration);
    _scheduleRoam();
  }

  void _animateMoveTo(double tx, double ty, Duration duration) {
    if (!mounted) return;

    setState(() {
      _facingRight = tx > _posX;
      _expression = _BuddyExpression.jumping;
    });

    final startX = _posX;
    final startY = _posY;

    _moveController.duration = duration;
    _moveAnimX = Tween<double>(begin: startX, end: tx).animate(
      CurvedAnimation(parent: _moveController, curve: Curves.easeInOutCubic),
    );
    _moveAnimY = Tween<double>(begin: startY, end: ty).animate(
      CurvedAnimation(parent: _moveController, curve: Curves.easeInOutCubic),
    );

    _moveController.forward(from: 0).then((_) {
      if (mounted) {
        setState(() {
          _posX = tx;
          _posY = ty;
          _expression = .idle;
        });
      }
    });
  }

  void _landSquash() {
    if (!mounted) return;
    _squashController.forward(from: 0).then((_) {
      if (mounted) _squashController.reverse();
    });
  }

  /// TAUNT (60s untapped)

  void _resetTauntTimer() {
    _tauntTimer?.cancel();
    _tauntTimer = Timer(const Duration(seconds: 60), _performTaunt);
  }

  void _performTaunt() {
    if (_paused || !mounted) return;
    setState(() => _expression = _BuddyExpression.taunting);
    _showSpeech('Haha');
    _playAudio('hahaha.mp3');

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _expression = _BuddyExpression.idle);
      }
    });
    _resetTauntTimer();
  }

  // TAP ESCALATION

  void _onTap() {
    if (_paused) return;
    _resetTauntTimer();

    _tapStage++;
    _tapResetTimer?.cancel();
    _tapResetTimer = Timer(const Duration(seconds: 20), () {
      _tapStage = 0;
    });

    _landSquash();

    switch (_tapStage) {
      case 1:
        setState(() => _expression = _BuddyExpression.annoyed);
        _showSpeech('Hey');
        _playAudio('hamo_beka.mp3');
        break;

      case 2:
        setState(() => _expression = _BuddyExpression.pleading);
        _showSpeech('Stop');
        _playAudio('er7m_omy.mp3');
        break;

      case >= 3:
        setState(() => _expression = _BuddyExpression.resigned);
        _showSpeech('Fine');
        _playAudio('mashy.mp3');
        _tapStage = 0;
        // Dash away
        final screenW = MediaQuery.of(context).size.width;
        final escapeX = _posX < screenW / 2 ? screenW - _buddySize - 16 : 16.0;
        _animateMoveTo(escapeX, _posY, const Duration(milliseconds: 400));
        break;

      default:
        break;
    }

    // Reset expression after 2.5s
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted && _expression != _BuddyExpression.jumping) {
        setState(() => _expression = _BuddyExpression.idle);
      }
    });
  }

  // SPEECH BUBBLE

  void _showSpeech(String word) {
    _speechTimer?.cancel();
    setState(() => _speechWord = word);
    _speechTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _speechWord = null);
    });
  }

  // AUDIO

  Future<void> _playAudio(String filename) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('sounds/$filename'));
    } catch (_) {
      // Silently fail — audio is non-critical
    }
  }

  // BUILD

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _bounceAnim,
        _moveController,
        _squashController,
      ]),
      builder: (context, _) {
        final currentX = _moveController.isAnimating
            ? (_moveAnimX?.value ?? _posX)
            : _posX;
        final currentY = _moveController.isAnimating
            ? (_moveAnimY?.value ?? _posY)
            : _posY;
        final bounceOffset = _moveController.isAnimating
            ? 0.0
            : _bounceAnim.value;

        return Positioned(
          left: currentX,
          top: currentY + bounceOffset,
          child: GestureDetector(
            onTap: _onTap,
            behavior: .opaque,
            child: Transform(
              alignment: .bottomCenter,
              transform: Matrix4.diagonal3Values(
                _squashX.value,
                _squashY.value,
                1.0,
              ),
              child: Transform.flip(
                flipX: !_facingRight,
                child: Column(
                  mainAxisSize: .min,
                  children: [
                    // Speech bubble
                    if (_speechWord != null) _buildSpeechBubble(_speechWord!),
                    // Pixel buddy
                    SizedBox(
                      width: _buddySize,
                      height: _buddySize,
                      child: CustomPaint(
                        painter: _BuddyPainter(
                          expression: _expression,
                          darkNavy: _darkNavy,
                          mediumBlue: _mediumBlue,
                          brightBlue: _brightBlue,
                          white: _white,
                          lightCyan: _lightCyan,
                          gold: _gold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSpeechBubble(String word) {
    return Container(
      margin: .only(bottom: 4.h),
      padding: .symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: .circular(12.r),
        boxShadow: [
          BoxShadow(
            color: _darkNavy.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        word,
        style: TextStyle(
          fontFamily: 'BrunoAceSC',
          fontSize: 11.sp,
          color: _darkNavy,
          fontWeight: .bold,
        ),
      ),
    );
  }
}

// PIXEL ART PAINTER

class _BuddyPainter extends CustomPainter {
  _BuddyPainter({
    required this.expression,
    required this.darkNavy,
    required this.mediumBlue,
    required this.brightBlue,
    required this.white,
    required this.lightCyan,
    required this.gold,
  });

  final _BuddyExpression expression;
  final Color darkNavy;
  final Color mediumBlue;
  final Color brightBlue;
  final Color white;
  final Color lightCyan;
  final Color gold;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final cellW = size.width / 8;
    final cellH = size.height / 10;

    void pixel(int col, int row, Color color) {
      final paint = Paint()..color = color;
      canvas.drawRect(
        Rect.fromLTWH(col * cellW, row * cellH, cellW, cellH),
        paint,
      );
    }

    //  Body (rows 3-9)
    // Core body shape — a chunky humanoid
    for (int r = 4; r <= 8; r++) {
      for (int c = 2; c <= 5; c++) {
        pixel(c, r, mediumBlue);
      }
    }

    // Head (rows 1-3)
    for (int c = 2; c <= 5; c++) {
      pixel(c, 1, brightBlue);
      pixel(c, 2, brightBlue);
      pixel(c, 3, brightBlue);
    }
    // Head top accent
    pixel(3, 0, lightCyan);
    pixel(4, 0, lightCyan);

    //  Eyes
    switch (expression) {
      case _BuddyExpression.idle:
      case _BuddyExpression.jumping:
        pixel(3, 2, white);
        pixel(4, 2, white);
        break;

      case _BuddyExpression.annoyed:
        // Squinting eyes (half-closed)
        pixel(3, 2, darkNavy);
        pixel(4, 2, darkNavy);
        break;

      case _BuddyExpression.pleading:
        // Big puppy eyes
        pixel(3, 2, white);
        pixel(4, 2, white);
        pixel(3, 1, lightCyan);
        pixel(4, 1, lightCyan);
        break;

      case _BuddyExpression.resigned:
        // Closed eyes (line)
        pixel(3, 2, darkNavy);
        pixel(4, 2, darkNavy);
        break;

      case _BuddyExpression.taunting:
        // Mischievous wink
        pixel(3, 2, gold);
        pixel(4, 2, darkNavy); // wink
        break;
    }

    //  Mouth
    switch (expression) {
      case _BuddyExpression.idle:
      case _BuddyExpression.jumping:
        pixel(3, 3, gold); // smile left
        pixel(4, 3, gold); // smile right
        break;

      case _BuddyExpression.annoyed:
        pixel(3, 3, darkNavy); // flat line
        pixel(4, 3, darkNavy);
        break;

      case _BuddyExpression.pleading:
        pixel(3, 3, white); // open sad mouth
        pixel(4, 3, white);
        break;

      case _BuddyExpression.resigned:
        pixel(4, 3, darkNavy); // slight frown
        break;

      case _BuddyExpression.taunting:
        pixel(3, 3, gold);
        pixel(4, 3, gold);
        pixel(5, 3, gold); // big grin
        break;
    }

    //  Arms
    // Left arm
    pixel(1, 5, brightBlue);
    pixel(1, 6, brightBlue);
    // Right arm
    pixel(6, 5, brightBlue);
    pixel(6, 6, brightBlue);

    if (expression == _BuddyExpression.pleading) {
      // Arms raised
      pixel(1, 4, brightBlue);
      pixel(6, 4, brightBlue);
    }

    if (expression == _BuddyExpression.taunting) {
      // One arm up waving
      pixel(6, 4, gold);
      pixel(6, 3, gold);
    }

    //  Legs
    pixel(2, 9, darkNavy);
    pixel(3, 9, darkNavy);
    pixel(4, 9, darkNavy);
    pixel(5, 9, darkNavy);

    //  Briefcase (job seeker identity)
    pixel(0, 7, gold);
    pixel(0, 8, gold);
    pixel(1, 7, gold);
    pixel(1, 8, gold);

    //  Outline accents
    pixel(2, 0, darkNavy);
    pixel(5, 0, darkNavy);
    pixel(1, 1, darkNavy);
    pixel(6, 1, darkNavy);
    pixel(7, 5, darkNavy);
    pixel(0, 5, darkNavy);
  }

  @override
  bool shouldRepaint(covariant _BuddyPainter oldDelegate) {
    return oldDelegate.expression != expression;
  }
}
