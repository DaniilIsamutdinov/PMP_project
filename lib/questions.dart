import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/services.dart';
String ans = '';
class QuestionsScreen extends StatefulWidget {
  final String fileContent;

  const QuestionsScreen({super.key, required this.fileContent});

  @override
  State<QuestionsScreen> createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  bool isLandscape = false;
  List<ThemeBlock> themes = [];
  int maxQuestions = 0;
  int maxScore = 0;
  int currentScore = 0;
  int completeCount = 0;
  int answeredCount = 0;
  int totalQuestions = 0;
  bool isParsed = false;


  final ScrollController verticalController = ScrollController();
  final ScrollController verticalTextController = ScrollController();

  @override
  void initState() {
    super.initState();
    parseAndPrepare();
    verticalController.addListener(() {
      if (verticalTextController.hasClients &&
          verticalController.offset != verticalTextController.offset) {
        verticalTextController.jumpTo(verticalController.offset);
      }
    });
    verticalTextController.addListener(() {
      if (verticalController.hasClients &&
          verticalTextController.offset != verticalController.offset) {
        verticalController.jumpTo(verticalTextController.offset);
      }
    });
  }

  void parseAndPrepare() {
    try {
      themes = parseSimpleQuiz(widget.fileContent);
      maxQuestions = themes.map((t) => t.questions.length).fold(0, (a, b) => a > b ? a : b);
      maxScore = themes
          .expand((t) => t.questions)
          .fold(0, (sum, q) => sum + q.price);
      totalQuestions = themes.fold(0, (sum, t) => sum + t.questions.length);
      setState(() {
        isParsed = true;
      });
    } catch (e) {
      print('Помилка при парсингу: $e');
    }
  }

  @override
  void dispose() {
    verticalController.dispose();
    verticalTextController.dispose();
    super.dispose();
  }

  void handleAnswer(Question question) {
    if (!question.answered) {
      setState(() {
        question.answered = true;
        if (ans == question.correctAnswer.toLowerCase().replaceAll(' ', '')){
          showDialog(context: context, barrierDismissible: false, builder: (context) => AlertDialog(
              title: Text('Правильна відповідь!'),
              content: Center(heightFactor: 0.4, child: Text('+${question.price}', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 20))),
          )
          );
          currentScore += question.price;
          answeredCount++;
        }
        else{
          showDialog(context: context, barrierDismissible: false, builder: (context) => AlertDialog(
              title: Text('Правильна відповідь:\n\n${question.correctAnswer}'),
              content: Center(heightFactor: 0.4, child: Text('-${question.price}', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 20)))
          )
          );
          currentScore -= question.price;
          }
        Future.delayed(Duration(seconds: 4), () {

          Navigator.pop(context);
          Navigator.pop(context);
          setState(() {});
        });
        print(ans);
        print(question.correctAnswer.toLowerCase());
        completeCount += 1;

        if (completeCount >= totalQuestions) {
          Future.delayed(Duration(seconds: 5),(){
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Гру завершено'),
                content: Text('Ви заробили $currentScore з $maxScore очок!\nПравильних відповідей: $answeredCount/$totalQuestions'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isParsed) {
      return Scaffold(
        appBar: AppBar(title: const Text('Зачекайте')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Бали: $currentScore / $maxScore',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[Color(0xff7ac972), Color(0xff9ad594)]),
          ),
        ),
        leading: IconButton(
            icon: const Icon(Icons.house, color: Colors.black),
            onPressed: () {
              SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
              Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
        actions: [
          IconButton(
            tooltip: 'Змінити орієнтацію',
            icon: Icon(isLandscape
                ? Icons.screen_lock_landscape
                : Icons.screen_rotation),
            onPressed: () {
              isLandscape
                  ? SystemChrome.setPreferredOrientations(
                  [DeviceOrientation.landscapeLeft])
                  : SystemChrome.setPreferredOrientations(
                  [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight, DeviceOrientation.portraitUp]);
              setState(() {
                isLandscape = !isLandscape;
              });
            },
          )
        ],
      ),
      body: Container(
        margin: const EdgeInsets.all(10),
        child: Row(
          children: [
            SizedBox(
              width: 150,
              child: ListView.builder(
                controller: verticalTextController,
                itemCount: themes.length,
                itemBuilder: (context, i) {
                  return ThemeTile(title: themes[i].title);
                },
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: maxQuestions * 124,
                  child: ListView.builder(
                    controller: verticalController,
                    itemCount: themes.length,
                    itemBuilder: (context, i) {
                      final theme = themes[i];
                      return Row(
                        children: List.generate(maxQuestions, (j) {
                          if (j < theme.questions.length) {
                            final q = theme.questions[j];
                            return QuestionCell(
                              question: q,
                              onAnswered: () => handleAnswer(q),
                            );
                          } else {
                            return const EmptyCell();
                          }
                        }),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//
// МОДЕЛІ
//

class ThemeBlock {
  final String title;
  final List<Question> questions;

  ThemeBlock({required this.title, required this.questions});
}

class Question {
  final String text;
  final String correctAnswer;
  final int price;
  bool answered = false;

  Question({
    required this.text,
    required this.correctAnswer,
    required this.price,
  });
}

//
// ПАРСЕР
//

List<ThemeBlock> parseSimpleQuiz(String content) {
  final lines = content.split('\n').map((e) => e.trim()).toList();

  if (lines.isEmpty || !lines[0].startsWith('#QUIZ_FILE_V1')) {
    throw Exception('Файл не підтримується.');
  }

  final themeCountLine = lines.firstWhere((l) => l.startsWith('themes='));
  final questionCountLine = lines.firstWhere((l) => l.startsWith('questions='));

  int themeCount = int.tryParse(themeCountLine.split('=')[1]) ?? 0;
  int questionCount = int.tryParse(questionCountLine.split('=')[1]) ?? 0;

  List<ThemeBlock> themes = [];
  int i = 0;

  while (i < lines.length) {
    final line = lines[i];

    // Розпізнавання теми
    if (line.startsWith('[Тема:')) {
      if (!line.endsWith(']')) {
        throw Exception('Помилка: тема на рядку ${i + 1} не має закритих дужок.');
      }
      final themeTitle = line.substring(6, line.length - 1).trim(); // без [Тема: ...]
      List<Question> questions = [];
      i++;

      while (i < lines.length && !lines[i].startsWith('[Тема:')) {
        // Питання
        if (lines[i].startsWith('{Питання:')) {
          final questionLine = lines[i];
          if (!questionLine.endsWith('}')) {
            throw Exception('Помилка: питання на рядку ${i + 1} не має закритих дужок.');
          }
          final questionText = questionLine.substring(9, questionLine.length - 1).trim();
          i++;

          // Відповідь
          if (i >= lines.length || !lines[i].startsWith('=')) {
            throw Exception('Відсутня відповідь після питання: $questionText');
          }
          String correctAnswer = lines[i].substring(1).trim();
          i++;

          // Ціна
          int price = 0;
          if (i < lines.length && lines[i].startsWith('\$')) {
            price = int.tryParse(lines[i].substring(1)) ?? 0;
            i++;
          }

          questions.add(Question(
            text: questionText,
            correctAnswer: correctAnswer,
            price: price,
          ));
        } else {
          i++;
        }
      }

      themes.add(ThemeBlock(title: themeTitle, questions: questions));
    } else {
      i++;
    }
  }

  // Перевірка відповідностей
  if (themes.length != themeCount) {
    throw Exception('Кількість тем не відповідає заявленій. Знайдено ${themes.length}, очікувалось $themeCount.');
  }

  int actualQuestions = themes.fold(0, (sum, t) => sum + t.questions.length);
  if (actualQuestions != questionCount) {
    throw Exception('Кількість питань не відповідає заявленій. Знайдено $actualQuestions, очікувалось $questionCount.');
  }

  return themes;
}



//
// ВІДЖЕТИ
//

class ThemeTile extends StatelessWidget {
  final String title;

  const ThemeTile({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 84,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: AutoSizeText(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        maxLines: 9,
        minFontSize: 6,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class QuestionCell extends StatelessWidget {
  final Question question;
  final VoidCallback onAnswered;
  final TextEditingController _controller = TextEditingController();

  QuestionCell({super.key, required this.question, required this.onAnswered});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: question.answered
          ? null
          : () {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Питання'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(question.text),
                const SizedBox(height: 12),
                // Text('Правильна відповідь: ${question.correctAnswer}'),
                // const SizedBox(height: 8),
                // Text('Ціна: ${question.price}'),
                Builder(builder: (context){
                  // var height = MediaQuery.of(context).size.height;
                  var width = MediaQuery.of(context).size.width;

                  return SizedBox(
                    // height: height + 100,
                    width: width,
                    child:
                    TextField(
                      controller: _controller,
                      onChanged: (text){ans = text.toLowerCase().replaceAll(' ', '');},
                      onSubmitted: (text){ans = text.toLowerCase().replaceAll(' ', '');},
                      decoration: InputDecoration(hintText: question.correctAnswer, hintStyle:TextStyle(color: Color(0x55000000)) ),
                    ),
                  );
                }),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  onAnswered();
                },
                child: const Text('Відповісти'),
                style: ButtonStyle(backgroundColor: WidgetStatePropertyAll<Color>(Colors.green), foregroundColor: WidgetStatePropertyAll<Color>(Colors.white)),
              ),

            ],
          ),
        );
      },
      child: Container(
        width: 120,
        height: 80,
        margin: const EdgeInsets.all(2),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: question.answered ? Colors.grey : Colors.lightBlueAccent,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Text(
          '${question.price}',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: question.answered ? Colors.white24 : Colors.black),
        ),
      ),
    );
  }
}

class EmptyCell extends StatelessWidget {
  const EmptyCell({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 80,
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: const Color(0x11000000),
        borderRadius: BorderRadius.circular(5.0),
      ),
    );
  }
}
