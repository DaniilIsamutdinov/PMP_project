import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QuestionEditorScreen extends StatefulWidget {
  final int themeCount;
  final int maxQuestionsPerTheme;

  const QuestionEditorScreen({
    super.key,
    required this.themeCount,
    required this.maxQuestionsPerTheme,
  });

  @override
  State<QuestionEditorScreen> createState() => _QuestionEditorScreenState();
}

class _QuestionEditorScreenState extends State<QuestionEditorScreen> {
  late List<EditableTheme> themes;
  bool isLandscape = false;
  final ScrollController verticalController = ScrollController();
  final ScrollController verticalTextController = ScrollController();
  String nameFile = 'default';

  @override
  void initState() {
    super.initState();
    themes = List.generate(widget.themeCount, (i) {
      return EditableTheme(
        title: 'Тема ${i + 1}',
        questions: List.generate(widget.maxQuestionsPerTheme, (_) => EditableQuestion()),
      );
    });
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

  @override
  void dispose() {
    verticalController.dispose();
    verticalTextController.dispose();
    super.dispose();
  }

  Future<void> _exportToTxt() async {
    final buffer = StringBuffer();
    int totalQuestions = themes.fold(0, (sum, t) => sum + t.questions.where((q) => q.text.isNotEmpty).length);

    buffer.writeln('#QUIZ_FILE_V1');
    buffer.writeln('themes=${themes.length}');
    buffer.writeln('questions=$totalQuestions');
    buffer.writeln('');

    for (var theme in themes) {
      buffer.writeln('[Тема: ${theme.title}]');
      for (var q in theme.questions) {
        if (q.text.trim().isNotEmpty) {
          buffer.writeln('{Питання: ${q.text}}');
          buffer.writeln('= ${q.answer}');
          buffer.writeln('\$${q.price}');
          buffer.writeln('');
        }
      }
    }

    // Clipboard.setData(ClipboardData(text: buffer.toString()));
    // ScaffoldMessenger.of(context).showSnackBar(
    //   const SnackBar(content: Text('Текст скопійовано в буфер')),
    // );
    String? outputPath = await FilePicker.platform.getDirectoryPath();

    if (outputPath != null) {
      final file = File('$outputPath/$nameFile.txt');
      await file.writeAsString(buffer.toString());
      print('Файл збережено у: ${file.path}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.house, color: Colors.black),
          onPressed: () {
            SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
        title: const Text('Редактор набору питань'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[Color(0xff7ac972), Color(0xff9ad594)]),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Скопіювати як TXT',
            onPressed: (){
              showDialog(context: context, builder: (context) => AlertDialog(
                title: Text('Введіть назву файлу:'),
                content:
                    TextField(
                      decoration: const InputDecoration(labelText: 'Назва:'),
                      onChanged: (val) => nameFile = val,
                    ),
                actions: [
                  TextButton(
                    onPressed: _exportToTxt,
                    child: Text('Куди зберігти'),
                  )
                ],
              ));
            }
          ),
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
      body: Row(
        children: [
          SizedBox(
            width: 150,
            child: ListView.builder(
              controller: verticalTextController,
              itemCount: themes.length,
              itemBuilder: (context, i) => ListTile(
                title: Container(
                  height: 184,
                  //color: Color(0x11000000),
                  child: Column(
                    children: [
                      TextField(
                        decoration: const InputDecoration(labelText: 'Назва теми'),
                        controller: TextEditingController(text: themes[i].title),
                        onChanged: (val) => themes[i].title = val,
                        onSubmitted: (val) => setState(() {}),
                      ),
                      AutoSizeText(

                        themes[i].title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        maxLines: 15,
                        minFontSize: 6,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: widget.maxQuestionsPerTheme * 250,
                child: ListView.builder(
                  controller: verticalController,
                  itemCount: themes.length,
                  itemBuilder: (context, i) {
                    return Row(
                      children: List.generate(widget.maxQuestionsPerTheme, (j) {
                        final question = themes[i].questions[j];
                        return SizedBox(
                          width: 240,
                          height: 200,
                          child: Card(
                            margin: const EdgeInsets.all(6),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                children: [
                                  Text('Питання ${j + 1}'),
                                  TextField(
                                    decoration: const InputDecoration(labelText: 'Текст питання'),
                                    onChanged: (val) => question.text = val,
                                  ),
                                  TextField(
                                    decoration: const InputDecoration(labelText: 'Правильна відповідь'),
                                    onChanged: (val) => question.answer = val,
                                  ),
                                  TextField(
                                    decoration: const InputDecoration(labelText: 'Ціна'),
                                    keyboardType: TextInputType.number,
                                    onChanged: (val) => question.price = int.tryParse(val) ?? 0,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EditableTheme {
  String title;
  List<EditableQuestion> questions;

  EditableTheme({required this.title, required this.questions});
}

class EditableQuestion {
  String text = '';
  String answer = '';
  int price = 0;
}
