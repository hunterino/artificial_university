import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/class_detail.dart';
import '../models/grading_result.dart';
import '../services/grading_service.dart';
import '../utils/grade_utils.dart';
import '../widgets/ai_grading_widget.dart';

class QuizScreen extends StatefulWidget {
  final Quiz quiz;

  const QuizScreen({super.key, required this.quiz});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final PageController _pageController = PageController();
  final List<TextEditingController> _answerControllers = [];
  final List<GradingResult?> _gradingResults = [];
  int _currentQuestionIndex = 0;
  bool _quizCompleted = false;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.quiz.questions.length; i++) {
      _answerControllers.add(TextEditingController());
      _gradingResults.add(null);
    }
  }

  @override
  void dispose() {
    for (final controller in _answerControllers) {
      controller.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz ${widget.quiz.quiz}: ${widget.quiz.topic}'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_currentQuestionIndex + 1}/${widget.quiz.questions.length}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / widget.quiz.questions.length,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentQuestionIndex = index;
                });
              },
              itemCount: widget.quiz.questions.length + (_quizCompleted ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == widget.quiz.questions.length) {
                  return _buildResultsPage();
                }
                return _buildQuestionPage(index);
              },
            ),
          ),
          _buildNavigationBar(),
        ],
      ),
    );
  }

  Widget _buildQuestionPage(int index) {
    final question = widget.quiz.questions[index];
    final controller = _answerControllers[index];
    final gradingResult = _gradingResults[index];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Question ${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${question.points} points',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    question.question,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Type: ${question.type}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Answer:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    maxLines: question.type == 'essay' ? 8 : 4,
                    decoration: InputDecoration(
                      hintText: _getHintText(question.type),
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: gradingResult == null ? () => _submitAnswer(index) : null,
                        icon: gradingResult == null
                            ? const Icon(Icons.send)
                            : const Icon(Icons.check),
                        label: Text(gradingResult == null ? 'Submit Answer' : 'Submitted'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: gradingResult == null ? Colors.blue : Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (gradingResult != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: getGradeColor(gradingResult.percentage).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: getGradeColor(gradingResult.percentage),
                            ),
                          ),
                          child: Text(
                            '${gradingResult.score}/${gradingResult.maxScore} (${gradingResult.letterGrade})',
                            style: TextStyle(
                              color: getGradeColor(gradingResult.percentage),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (gradingResult != null) ...[
            const SizedBox(height: 16),
            AIGradingWidget(gradingResult: gradingResult),
          ],
        ],
      ),
    );
  }

  Widget _buildResultsPage() {
    final totalScore = _gradingResults
        .where((result) => result != null)
        .fold<int>(0, (sum, result) => sum + result!.score);
    final maxScore = widget.quiz.totalPoints;
    final percentage = (totalScore / maxScore) * 100;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.celebration,
                    size: 80,
                    color: getGradeColor(percentage),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Quiz Completed!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: getGradeColor(percentage).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: getGradeColor(percentage)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '$totalScore / $maxScore',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: getGradeColor(percentage),
                          ),
                        ),
                        Text(
                          '${percentage.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: getGradeColor(percentage),
                          ),
                        ),
                        Text(
                          getLetterGrade(percentage),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: getGradeColor(percentage),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Question Summary',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(widget.quiz.questions.length, (index) {
                    final result = _gradingResults[index];
                    if (result == null) return const SizedBox.shrink();

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: getGradeColor(result.percentage),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              widget.quiz.questions[index].question,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${result.score}/${result.maxScore}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: getGradeColor(result.percentage),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentQuestionIndex > 0)
            ElevatedButton.icon(
              onPressed: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Previous'),
            ),
          const Spacer(),
          if (_currentQuestionIndex < widget.quiz.questions.length - 1)
            ElevatedButton.icon(
              onPressed: () {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Next'),
            )
          else if (!_quizCompleted && _allQuestionsAnswered())
            ElevatedButton.icon(
              onPressed: _completeQuiz,
              icon: const Icon(Icons.check),
              label: const Text('Finish Quiz'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  String _getHintText(String type) {
    switch (type) {
      case 'calculation':
        return 'Show your work and provide the final answer...';
      case 'short_answer':
        return 'Provide a concise explanation...';
      case 'essay':
        return 'Write a detailed response...';
      case 'code':
        return 'Write your code here...';
      default:
        return 'Enter your answer...';
    }
  }

  void _submitAnswer(int index) async {
    final controller = _answerControllers[index];
    final question = widget.quiz.questions[index];

    if (controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an answer before submitting')),
      );
      return;
    }

    final gradingService = Provider.of<GradingService>(context, listen: false);

    try {
      final result = await gradingService.gradeQuizAnswer(question, controller.text);
      setState(() {
        _gradingResults[index] = result;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error grading answer: $e')),
      );
    }
  }

  bool _allQuestionsAnswered() {
    return _gradingResults.every((result) => result != null);
  }

  void _completeQuiz() {
    setState(() {
      _quizCompleted = true;
    });
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}
