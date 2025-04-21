import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:projects/questions.dart';

void main() => runApp(CGameApp());

class CGameApp extends StatelessWidget {
  const CGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(scaffoldBackgroundColor: const Color(0xffaae5a4)),
        title: "CGame",
        home: Menu());
  }
}

class Menu extends StatelessWidget {
  const Menu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Меню"),
        centerTitle: true,
        // backgroundColor: const Color(0x11000000),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[Color(0xff7ac972), Color(0xff9ad594)]),
          ),
        ),
      ),
      body: Center(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // const SizedBox(
            //   height: 40,
            // ),
            Text(
              'Challenging',
              style: TextStyle(
                fontFamily: "Notable",
                fontSize: 40.0,
                color: Color(0xff551a5b),
              ),
            ), //challenging
            Text(
              'game',
              style: TextStyle(
                fontFamily: "Notable",
                fontSize: 60.0,
                color: Color(0xff551a5b),
              ),
            ), //game
            const SizedBox(height: 100,),
            InkWell(
              onTap: () {
                score = 0;
                SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const QuestionsS()));
              },
              customBorder: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)),
              child: Ink(
                width: 200,
                height: 100,
                // alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.lightBlueAccent,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: const Center(
                  child: Text(
                    "Грати",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ), // Грати
            const SizedBox(height: 20,),
            InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AboutDialog(
                      applicationVersion: "1.0.0",
                      applicationName: '''Challenging Game
by Ісамутдінов Даніїл''',
                    );
                  },
                );
              },
              customBorder: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)),
              child: Ink(
                width: 200,
                height: 100,
                // alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.lightBlueAccent,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: const Center(
                  child: Text(
                    "Автор",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ), //about
            // Container(
            //   width: 200,
            //   height: 100,
            //   alignment: Alignment.center,
            //   decoration: BoxDecoration(
            //     color: Colors.lightBlueAccent,
            //     borderRadius: BorderRadius.circular(12.0),
            //   ),
            //   child: Text(
            //     "Грати",
            //     style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            //   ),
            // ),
            // Container(
            //   width: 200,
            //   height: 100,
            //   alignment: Alignment.center,
            //   decoration: BoxDecoration(
            //     color: Colors.lightBlueAccent,
            //     borderRadius: BorderRadius.circular(12.0),
            //   ),
            //   child: Text("Автор", style: TextStyle(
            //       fontSize: 30, fontWeight: FontWeight.bold),),
            // ),
            // const SizedBox(height: 20,),
            // Container(
            //   width: 200,
            //   height: 100,
            //   alignment: Alignment.center,
            //   decoration: BoxDecoration(
            //     color: Colors.lightBlueAccent,
            //     borderRadius: BorderRadius.circular(12.0),
            //   ),
            //
            //   child: Text("Вийти", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),),
            // ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => SystemNavigator.pop(),
        tooltip: 'Exit',
        backgroundColor: Color(0xeeaa2222),
        child: const Icon(Icons.exit_to_app_sharp, color: Color(0xffffffff),),
      ), // Вихід
    );
  }
}
