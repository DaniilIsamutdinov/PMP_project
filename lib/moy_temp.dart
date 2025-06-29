import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

int score = 0;
String ans = '';
List<bool> butt = List.filled(30, true);
//String text = '';


class QuestionsS extends StatefulWidget {
  const QuestionsS({super.key});

  @override
  State<QuestionsS> createState() => _QuestionsSState();
}

class _QuestionsSState extends State<QuestionsS> {
  final TextEditingController _controller = TextEditingController();

  void _handleSubmit() {
    // Обработка вашего ответа
    String answer = _controller.text;
    print(answer); // Здесь вы можете сделать что-то с ответом

    // Очистка TextField
    _controller.clear();
  }

  @override

  void initState() {
    butt = List.generate(30, (index) => true);
    super.initState();
    print("initstate");
  }
    @override
    void dispose() {
      _controller.dispose();
      super.dispose();
    }
  @override
  Widget build(BuildContext context) {
    print("build");
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(30.0),
          child: AppBar(
            title: Text(
              "Ваші бали: $score / ${butt.length*300}",
            ),
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
            leading: IconButton(
                icon: Icon(Icons.house, color: Colors.black),
                onPressed: () => setState(
                      () {
                    SystemChrome.setPreferredOrientations(
                        [DeviceOrientation.portraitUp]);
                    Navigator.of(context).pop();
                  },
                )),
          )),
      body: Center(
        child: Container(
          margin: EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                // color: Color(0x33000000),
                width: 120,
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1, mainAxisExtent: 50, mainAxisSpacing: 3),
                  itemBuilder: (context, index) => Container(
                    margin: EdgeInsets.all(2),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.lightBlueAccent,
                      borderRadius: BorderRadius.circular(3.0),
                    ),
                    child: Center(child: Text('Тема: ${index + 1}')),
                  ),
                  itemCount: 6,
                ),
              ),
              const SizedBox(width: 10,),
              Expanded(
                child: Container(
                  color: Color(0x33ff0000),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5, mainAxisExtent: 50, mainAxisSpacing: 3),
                    itemBuilder: (context, index) => MaterialButton(

                      onPressed: () {
                        butt[index] ? showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => AlertDialog(
                              title: Text('Какой это вопрос по порядку?'),
                              content:
                              Builder(builder: (context){
                                var height = MediaQuery.of(context).size.height;
                                var width = MediaQuery.of(context).size.width;

                                return SizedBox(
                                  height: height + 100,
                                  width: width,
                                  child:
                                  TextField(
                                    controller: _controller,
                                    // onChanged: (text){},
                                    onSubmitted: (text){ans = text;},
                                    decoration: InputDecoration(hintText: '${index+1}', hintStyle:TextStyle(color: Color(0x55000000)) ),
                                  ),
                                );
                              }),
                              actions: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: (){
                                    _handleSubmit();
                                    print('Пасанул');
                                    score -= ((index % 5)+1)*100;
                                    showDialog(context: context, barrierDismissible: false, builder: (context) => AlertDialog(title: Text('-${((index % 5)+1)*100}')));
                                    Future.delayed(Duration(seconds: 2), () {
                                      butt[index] = false;
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                      setState(() {});
                                    });
                                  },
                                  child: const Text('Пасс'),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: (){
                                    _handleSubmit();
                                    print('ans:$ans - ${ans.runtimeType}; index:$index - ${index.runtimeType}; ansint:${int.parse(ans)} - ${int.parse(ans).runtimeType}');
                                    if (int.tryParse(ans) != null && int.parse(ans) == (index+1)) {
                                      print('Текст из TextField равен индексу!');
                                      score += ((index % 5)+1)*100;
                                      showDialog(context: context, barrierDismissible: false, builder: (context) => AlertDialog(title: Text('+${((index % 5)+1)*100}')));
                                    }
                                    else {
                                      print('Текст из TextField не равен индексу.');
                                      score -= ((index % 5)+1)*100;
                                      showDialog(context: context, barrierDismissible: false, builder: (context) => AlertDialog(title: Text('-${((index % 5)+1)*100}')));
                                    }
                                    setState(() {});

                                    Future.delayed(Duration(seconds: 2), () {
                                      butt[index] = false;
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                      setState(() {});
                                    });
                                  },
                                  child: const Text('Ответить'),
                                )
                              ],
                            )
                        ): showDialog(context: context, builder: (context) => AlertDialog(title: Text('Ви вже пройшли це питання'))) ;
                      },
                      child: Container(
                        margin: EdgeInsets.all(2),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          // color: Colors.lightBlueAccent,
                          color: (butt[index] ? Colors.lightBlue : Colors.grey),
                          borderRadius: BorderRadius.circular(3.0),
                        ),
                        child: Center(child: Text('${((index % 5)+1)*100}')),
                      ),
                    ),
                    itemCount: 30,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
