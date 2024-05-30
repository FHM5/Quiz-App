import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(QuizApp());
}

class QuizApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz App',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Colors.black,
        textTheme: TextTheme(
          bodyText2: TextStyle(color: Colors.white),
        ),
      ),
      home: ModeSelectionPage(),
    );
  }
}

class ModeSelectionPage extends StatefulWidget {
  @override
  _ModeSelectionPageState createState() => _ModeSelectionPageState();
}

class _ModeSelectionPageState extends State<ModeSelectionPage> {
  final TextEditingController _nameController = TextEditingController();
  final List<String> _existingNames = [];

  void _startQuiz(String mode) {
    String name = _nameController.text;
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter your name')),
      );
      return;
    }
    if (!_existingNames.contains(name)) {
      setState(() {
        _existingNames.add(name);
      });
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QuizPage(mode: mode, userName: name),
      ),
    );
  }

  void _goToAddQuestionPage() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => AddQuestionPage()),
    );
  }

  void _goToLeaderboard() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => LeaderboardPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Enter your name',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueAccent),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _startQuiz('main'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: Text('Main Quiz'),
            ),
            ElevatedButton(
              onPressed: () => _startQuiz('timed'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: Text('Timed Quiz'),
            ),
            ElevatedButton(
              onPressed: () => _startQuiz('practice'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: Text('Practice Mode'),
            ),
            ElevatedButton(
              onPressed: _goToAddQuestionPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: Text('Add Your Own Questions'),
            ),
            ElevatedButton(
              onPressed: _goToLeaderboard,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: Text('View Leaderboard'),
            ),
          ],
        ),
      ),
    );
  }
}

class AddQuestionPage extends StatefulWidget {
  @override
  _AddQuestionPageState createState() => _AddQuestionPageState();
}

class _AddQuestionPageState extends State<AddQuestionPage> {
  final TextEditingController _questionController = TextEditingController();
  final List<TextEditingController> _optionControllers = List.generate(
    4,
    (index) => TextEditingController(),
  );
  int _correctAnswerIndex = 0;

  void _saveQuestion() {
    String questionText = _questionController.text;
    List<String> options =
        _optionControllers.map((controller) => controller.text).toList();

    if (questionText.isEmpty || options.any((option) => option.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please complete the question and all options')),
      );
      return;
    }

    CustomQuestions.addQuestion(
      Question(
        text: questionText,
        options: options,
        correctAnswerIndex: _correctAnswerIndex,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Question added successfully')),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Your Own Question'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _questionController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Question',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueAccent),
                ),
              ),
            ),
            ..._optionControllers.asMap().entries.map((entry) {
              int index = entry.key;
              TextEditingController controller = entry.value;
              return TextField(
                controller: controller,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Option ${index + 1}',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                ),
              );
            }).toList(),
            DropdownButton<int>(
              value: _correctAnswerIndex,
              dropdownColor: Colors.blueGrey[900],
              onChanged: (int? newValue) {
                setState(() {
                  _correctAnswerIndex = newValue!;
                });
              },
              items: List.generate(4, (index) => index)
                  .map<DropdownMenuItem<int>>((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text(
                    'Correct Answer: Option ${value + 1}',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveQuestion,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: Text('Save Question'),
            ),
          ],
        ),
      ),
    );
  }
}

class QuizPage extends StatefulWidget {
  final String mode;
  final String userName;

  QuizPage({required this.mode, required this.userName});

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  Timer? _timer;
  int _remainingTime = 30; // default 30 seconds for timed quiz
  List<Question> _questions = [];

  @override
  void initState() {
    super.initState();
    _questions = [
      Question(
        text: 'What is the capital of France?',
        options: ['Paris', 'London', 'Rome', 'Berlin'],
        correctAnswerIndex: 0,
      ),
      Question(
        text: 'What is 2 + 2?',
        options: ['3', '4', '5', '6'],
        correctAnswerIndex: 1,
      ),
      Question(
        text: 'Who wrote "To be, or not to be"?',
        options: ['Shakespeare', 'Dickens', 'Hemingway', 'Twain'],
        correctAnswerIndex: 0,
      ),
    ];
    _questions.addAll(CustomQuestions.getQuestions());
    if (widget.mode == 'timed') {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          _timer!.cancel();
          _showScoreDialog();
        }
      });
    });
  }

  void _answerQuestion(int selectedIndex) {
    if (selectedIndex == _questions[_currentQuestionIndex].correctAnswerIndex) {
      setState(() {
        _score++;
      });
    }

    setState(() {
      if (_currentQuestionIndex < _questions.length - 1) {
        _currentQuestionIndex++;
        if (widget.mode == 'timed') {
          _remainingTime = 30;
        }
      } else {
        _timer?.cancel();
        _showScoreDialog();
      }
    });
  }

  void _showScoreDialog() {
    Leaderboard.addScore(widget.userName, _score);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.blueGrey[900],
        title: Text('Quiz Completed!', style: TextStyle(color: Colors.white)),
        content: Text('Your score is $_score out of ${_questions.length}.',
            style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() {
                _currentQuestionIndex = 0;
                _score = 0;
                _remainingTime = 30;
                if (widget.mode == 'timed') {
                  _startTimer();
                }
              });
            },
            child: Text('Restart', style: TextStyle(color: Colors.blue)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: Text('Exit', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz App - ${widget.mode.capitalize()} Mode'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Question ${_currentQuestionIndex + 1}/${_questions.length}',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            SizedBox(height: 20),
            Text(
              currentQuestion.text,
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
            SizedBox(height: 20),
            ...currentQuestion.options.map((option) {
              int index = currentQuestion.options.indexOf(option);
              return ElevatedButton(
                onPressed: () => _answerQuestion(index),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                child: Text(option),
              );
            }).toList(),
            SizedBox(height: 20),
            if (widget.mode == 'timed') ...[
              Text(
                'Time Remaining: $_remainingTime seconds',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              SizedBox(height: 20),
            ],
            Text(
              'Score: $_score',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class LeaderboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scores = Leaderboard.getScores();

    return Scaffold(
      appBar: AppBar(
        title: Text('Leaderboard'),
      ),
      body: ListView.builder(
        itemCount: scores.length,
        itemBuilder: (context, index) {
          final entry = scores[index];
          return Card(
            color: Colors.blueGrey[800],
            child: ListTile(
              title:
                  Text(entry.userName, style: TextStyle(color: Colors.white)),
              trailing: Text(entry.score.toString(),
                  style: TextStyle(color: Colors.white)),
            ),
          );
        },
      ),
    );
  }
}

class Question {
  final String text;
  final List<String> options;
  final int correctAnswerIndex;

  Question({
    required this.text,
    required this.options,
    required this.correctAnswerIndex,
  });
}

class CustomQuestions {
  static List<Question> _customQuestions = [];

  static void addQuestion(Question question) {
    _customQuestions.add(question);
  }

  static List<Question> getQuestions() {
    return _customQuestions;
  }
}

class LeaderboardEntry {
  final String userName;
  final int score;

  LeaderboardEntry({required this.userName, required this.score});
}

class Leaderboard {
  static List<LeaderboardEntry> _scores = [];

  static void addScore(String userName, int score) {
    _scores.add(LeaderboardEntry(userName: userName, score: score));
    _scores.sort((a, b) => b.score.compareTo(a.score));
  }

  static List<LeaderboardEntry> getScores() {
    return _scores;
  }
}

extension StringExtension on String {
  String capitalize() {
    return this[0].toUpperCase() + this.substring(1);
  }
}
