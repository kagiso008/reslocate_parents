import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:reslocate/pages/homepage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  final AudioPlayer _audioPlayer = AudioPlayer();

  factory SoundService() {
    return _instance;
  }

  SoundService._internal();

  Future<void> playLocalSound(String soundPath) async {
    try {
      await _audioPlayer.play(AssetSource(soundPath));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> stopSound() async {
    await _audioPlayer.stop();
  }

  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}

class QuizService {
  final SupabaseClient _supabase;
  QuizService(this._supabase);

  Future<List<Question>> getQuestions() async {
    try {
      final response = await _supabase
          .rpc('get_random_records', params: {'limit_num': 5}).select();
      return (response as List)
          //creates question objects for every question in the response
          .map((question) => Question.fromJson(question))
          .toList();
    } catch (e) {
      throw 'Failed to load questions';
    }
  }
}

class Question {
  final String questionText;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;
  final String category;

  Question({
    required this.questionText,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
    required this.category,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    try {
      // Convert correct_answer_index from int4 to zero-based index
      int rawIndex = json['correct_answer_index'] as int;
      int adjustedIndex = rawIndex - 1; // Convert 1-based to 0-based index

      return Question(
        questionText: json['question_text'] ?? '',
        options: [
          json['option_1'].trim() ?? '',
          json['option_2'].trim() ?? '',
          json['option_3'].trim() ?? '',
          json['option_4'].trim() ?? '',
        ],
        correctAnswerIndex: adjustedIndex,
        explanation: json['explanation'] ?? '',
        category: json['category'] ?? '',
      );
    } catch (e) {
      rethrow;
    }
  }
}

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SA Quiz Game',
      theme: ThemeData(
        primaryColor: const Color(0xFF0D47A1),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0D47A1)),
      ),
      home: const QuizScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  QuizScreenState createState() => QuizScreenState();
}

class QuizResultsScreen extends StatefulWidget {
  final int score;
  final int totalQuestions;
  final VoidCallback onRestart;
  final int secondsPlayed;

  const QuizResultsScreen({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.onRestart,
    required this.secondsPlayed,
  });

  @override
  State<QuizResultsScreen> createState() => _QuizResultsScreenState();
}

class _QuizResultsScreenState extends State<QuizResultsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _percentageAnimation;
  late Animation<double> _pointsAnimation;
  late Animation<double> _streakAnimation;
  //late playerRank = getRank();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Calculate final percentage
    final percentage = (widget.score / widget.totalQuestions) * 100;
    final points = _calculateScore(widget.score, widget.secondsPlayed);

    // Create animations
    _percentageAnimation = Tween<double>(
      begin: 0,
      end: percentage,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    ));

    _pointsAnimation = Tween<double>(
      begin: 0,
      end: points.toDouble(),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 0.9, curve: Curves.easeOut),
    ));

    _streakAnimation = Tween<double>(
      begin: 0,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
    ));

    // Start the animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int _calculateScore(int finalScore, int seconds) {
    int totalQuestions = 5;
    // Base points calculation with variation
    int basePoints =
        finalScore * 15; // Each correct answer worth 15 base points

    // Consistency bonus/penalty
    // More points for consecutive correct answers, bigger penalties for mistakes
    int consistencyFactor = finalScore == totalQuestions ? 25 : -10;

    // Dynamic multiplier based on score ratio
    double scoreRatio = finalScore / totalQuestions;
    double multiplier = scoreRatio >= 0.8
        ? 1.5
        : // 80%+ performance
        scoreRatio >= 0.6
            ? 1.2
            : // 60%+ performance
            scoreRatio >= 0.4
                ? 1.0
                : // 40%+ performance
                0.7; // Below 40% performance

    // Calculate penalties for wrong answers
    int wrongAnswers = totalQuestions - finalScore;
    int penalty = wrongAnswers * (wrongAnswers * 8); // Exponential penalty

    // Time-based bonuses (keeping existing logic)
    int timeBonus = 0;
    if (seconds > 30) {
      timeBonus = 2;
    } else if (seconds <= 30 && seconds >= 15) {
      timeBonus = 4;
    } else if (seconds >= 0 && seconds < 15) {
      timeBonus = 6;
    }

    // Perfect score bonus (all answers correct)
    int perfectBonus = finalScore == totalQuestions ? 50 : 0;

    // Quick completion bonus (if all answers correct and done quickly)
    int quickBonus = (finalScore == totalQuestions && seconds < 20) ? 30 : 0;

    // Calculate final score
    int finalPoints = ((basePoints + consistencyFactor) * multiplier).round() -
        penalty +
        timeBonus +
        perfectBonus +
        quickBonus;

    // Ensure minimum score is -50 to prevent extremely negative scores
    return finalPoints < -50 ? -50 : finalPoints;
  }

  Widget _buildAnimatedStatColumn(
    String label,
    Animation<double> animation, {
    Color? color,
    String suffix = '',
  }) {
    return Flexible(
      child: Column(
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 5),
          AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return Text(
                '${animation.value.toStringAsFixed(1)}$suffix',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color ?? const Color(0xFF0D47A1),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final percentage = (widget.score / widget.totalQuestions) * 100;
    String resultMessage = '';
    String resultEmoji = '';

    if (percentage >= 80) {
      resultMessage = 'Outstanding!';
      resultEmoji = '🏆';
    } else if (percentage >= 60) {
      resultMessage = 'Well Done!';
      resultEmoji = '🌟';
    } else if (percentage >= 40) {
      resultMessage = 'Good Try!';
      resultEmoji = '👍';
    } else {
      resultMessage = 'Keep Learning!';
      resultEmoji = '📚';
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HomePage())),
                  color: const Color(0xFF0D47A1),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(height: 30),
                      Expanded(
                        flex: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  resultEmoji,
                                  style: const TextStyle(fontSize: 60),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  resultMessage,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0D47A1),
                                  ),
                                ),
                              ],
                            ),
                            /*SizedBox(
                              width: 50,
                            ),
                            Column(
                              children: [
                                SvgPicture.asset(
                                  "assets/svgs/apprentice_badge.svg",
                                  height: 87,
                                  width: 90,
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  "Master",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0D47A1),
                                  ),
                                ),
                              ],
                            )*/
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${widget.score}',
                                  style: const TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0D47A1),
                                  ),
                                ),
                                Text(
                                  '/${widget.totalQuestions}',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Correct Answers',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildAnimatedStatColumn(
                            'Percentage',
                            _percentageAnimation,
                            suffix: '%',
                          ),
                          _buildAnimatedStatColumn(
                            'Points',
                            _pointsAnimation,
                            color: _calculateScore(
                                        widget.score, widget.secondsPlayed) <
                                    0
                                ? const Color(0xFFFF0000)
                                : const Color(0xFF0D47A1),
                          ),
                          //_buildAnimatedStatColumn('Streak', _streakAnimation),
                        ],
                      ),
                      const SizedBox(height: 48),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0D47A1),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: widget.onRestart,
                          child: const Text(
                            'Try Again',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// quiz_screen.dart
class QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  final QuizService _quizService = QuizService(Supabase.instance.client);
  final SoundService _soundService = SoundService();
  List<Question> questions = [];
  bool isLoading = true;
  String? error;

  int currentQuestionIndex = 0;
  int score = 0;
  bool hasAnswered = false;
  int? selectedAnswerIndex;
  late Stopwatch stopWatch = Stopwatch();

  // Animation controllers
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _colorController;
  late List<AnimationController> _optionControllers;

  // Animations
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Color?> _colorAnimation;
  late List<Animation<Offset>> _optionSlideAnimations;

  @override
  void initState() {
    super.initState();

    // Initialize slide animation for question card
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Initialize fade animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    // Initialize color animation for answer feedback
    _colorController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _colorAnimation = ColorTween(
      begin: const Color(0xFF0D47A1),
      end: const Color(0xFF00C853),
    ).animate(CurvedAnimation(
      parent: _colorController,
      curve: Curves.easeInOut,
    ));

    // Initialize option animations
    _optionControllers = List.generate(
      4,
      (index) => AnimationController(
        duration: Duration(milliseconds: 400 + (index * 100)),
        vsync: this,
      ),
    );

    _optionSlideAnimations = _optionControllers.map((controller) {
      return Tween<Offset>(
        begin: const Offset(-1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutCubic,
      ));
    }).toList();

    _loadQuestions();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _colorController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    try {
      setState(() => isLoading = true);
      final loadedQuestions = await _quizService.getQuestions();
      setState(() {
        questions = loadedQuestions;
        isLoading = false;
      });
      // Start animations when questions are loaded
      _startQuestionAnimations();
    } catch (e) {
      setState(() {
        error = 'Failed to load questions. Please try again.';
        isLoading = false;
      });
    }
  }

  void _startQuestionAnimations() {
    _slideController.forward();
    _fadeController.forward();
    for (var controller in _optionControllers) {
      controller.forward();
    }
  }

  void _resetAnimations() {
    _slideController.reset();
    _fadeController.reset();
    _colorController.reset();
    for (var controller in _optionControllers) {
      controller.reset();
    }
  }

  void checkAnswer(int selectedIndex) async {
    if (hasAnswered) return;

    setState(() {
      selectedAnswerIndex = selectedIndex;
      hasAnswered = true;
    });

    // Play sound and animate color
    if (selectedIndex == questions[currentQuestionIndex].correctAnswerIndex) {
      _soundService.playLocalSound("sounds/correct_answer.mp3");
      _colorAnimation = ColorTween(
        begin: const Color(0xFF0D47A1),
        end: const Color(0xFF00C853),
      ).animate(_colorController);
      score++;
    } else {
      _soundService.playLocalSound("sounds/eish_wrong_answer.mp3");
      _colorAnimation = ColorTween(
        begin: const Color(0xFF0D47A1),
        end: const Color(0xFFFF0000),
      ).animate(_colorController);
    }

    await _colorController.forward();
    showExplanationDialog();
  }

  void nextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        hasAnswered = false;
        selectedAnswerIndex = null;
      });

      _resetAnimations();
      _startQuestionAnimations();
    } else {
      stopWatch.stop();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => QuizResultsScreen(
            score: score,
            totalQuestions: questions.length,
            secondsPlayed: stopWatch.elapsed.inSeconds,
            onRestart: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const QuizScreen(),
                ),
              );
            },
          ),
        ),
      );
    }
  }

  int getStopWatch() => stopWatch.elapsed.inSeconds;

  void showExplanationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Column(
            children: [
              Icon(
                selectedAnswerIndex ==
                        questions[currentQuestionIndex].correctAnswerIndex
                    ? Icons.check_circle
                    : Icons.info_outline,
                size: 40,
                color: selectedAnswerIndex ==
                        questions[currentQuestionIndex].correctAnswerIndex
                    ? const Color(0xFF00C853)
                    : const Color(0xFFFF0000),
              ),
              const SizedBox(height: 16),
              Text(
                selectedAnswerIndex ==
                        questions[currentQuestionIndex].correctAnswerIndex
                    ? 'Correct!'
                    : 'Incorrect',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            questions[currentQuestionIndex].explanation,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                nextQuestion();
              },
              child: Center(
                child: Text(
                  currentQuestionIndex < questions.length - 1
                      ? 'Next Question'
                      : 'Finish Quiz',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF0D47A1),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    // ... [Previous build method setup remains the same until the question card]
    stopWatch.start();

    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF0D47A1),
          ),
        ),
      );
    }

    if (error != null) {
      stopWatch.stop();
      stopWatch.reset();
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                error!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadQuestions,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (questions.isEmpty) {
      stopWatch.stop();
      stopWatch.reset();
      return const Scaffold(
        body: Center(
          child: Text('No questions available'),
        ),
      );
    }

    final question = questions[currentQuestionIndex];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 100,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF0D47A1)),
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomePage(),
                ),
              ),
            ),
            SvgPicture.asset(
              'assets/images/reslocate_logo.svg',
              height: screenHeight * 0.06,
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SA QUIZ',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D47A1),
                  ),
                ),
                Text(
                  'Test Your Knowledge',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.5),
          child: Container(
            height: 1.5,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0D47A1), Color(0xFF00E4BA)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
        ),
      ),
      // ... [AppBar configuration remains the same]

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 0; i < questions.length; i++)
                    Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          child: Text(
                            '${i + 1}',
                            style: TextStyle(
                              color: i == currentQuestionIndex
                                  ? const Color(0xFF0D47A1)
                                  : Colors.grey,
                              fontWeight: i == currentQuestionIndex
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(
                            height: 4), // Space between number and bar
                        Container(
                          width: 24,
                          height: 4,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: selectedAnswerIndex ==
                                    questions[currentQuestionIndex]
                                        .correctAnswerIndex
                                ? const Color(0xFF00C853)
                                : i == currentQuestionIndex
                                    ? const Color(0xFF0D47A1)
                                    : Colors.grey.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D47A1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Score: $score',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Progress indicators and score
              // ... [Previous progress and score widgets remain the same]
              // Animated question card
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Card(
                    elevation: 0.5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0D47A1).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              questions[currentQuestionIndex].category,
                              style: const TextStyle(
                                color: Color(0xFF0D47A1),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            questions[currentQuestionIndex].questionText,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Animated answer options
              for (int i = 0;
                  i < questions[currentQuestionIndex].options.length;
                  i++)
                SlideTransition(
                  position: _optionSlideAnimations[i],
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Container(
                      height: 80,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: AnimatedBuilder(
                        animation: _colorController,
                        builder: (context, child) {
                          return ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  hasAnswered && selectedAnswerIndex == i
                                      ? _colorAnimation.value
                                      : const Color(0xFF0D47A1),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: selectedAnswerIndex == i ? 8 : 2,
                            ),
                            onPressed:
                                hasAnswered ? null : () => checkAnswer(i),
                            child: Text(
                              questions[currentQuestionIndex].options[i],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
