import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:projects/questions.dart';

bool picked = false;

class FilePickerS extends StatefulWidget {
  const FilePickerS({super.key});

  @override
  _FilePickerExampleState createState() => _FilePickerExampleState();
}

class _FilePickerExampleState extends State<FilePickerS> {
  String? fileContent;

  Future<void> pickAndReadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'],
    );

    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      final file = File(path);

      final content = await file.readAsString();

      setState(() {
        picked = true;
        fileContent = content;
      });
    } else {
      setState(() {
        picked = false;
        fileContent = 'Файл не обраний.';
      });
    }
  }

  void validateAndOpen(String content) {
    try {
      final testThemes = parseSimpleQuiz(content); // просто перевірка
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuestionsScreen(fileContent: content),
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Помилка у файлі'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Завантаження файлу', style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold)),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[Color(0xff7ac972), Color(0xff9ad594)]),
            ),
          ),
          leading: IconButton(
              icon: Icon(Icons.house, color: Colors.black),
              onPressed: () => setState(() {Navigator.of(context).pop();},)
          ),
      ),
      body: Center(
        child: Container(
          margin: EdgeInsets.all(10),
          child: Column(
            children: [
              ElevatedButton(
                onPressed: pickAndReadFile,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlueAccent),
                child: Text('Обрати потрібний файл', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
              ),
              SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                    child: Text(fileContent ?? 'Текст файлу буде відображатись тут'),
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (picked) {
            validateAndOpen(fileContent!);
            //print("ПЕРЕДАНИЙ КОНТЕНТ:");
            //print(fileContent);
            picked = false;
          }
          else {showDialog(context: context, builder: (context) => AlertDialog(title: Text('Ви ще не обрали потрібний файл!')));};
          setState(() {});
        },
        tooltip: '''Let's play''',
        backgroundColor: (picked ? (Colors.green) : (Colors.grey)),
        child: const Icon(Icons.play_arrow, color: Color(0xffffffff),),
      ),
    );
  }
}