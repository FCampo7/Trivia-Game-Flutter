import 'package:flutter/material.dart';
import 'package:triviagame/src/DataQuestions.dart';
import 'dart:math';

class QuestionsPage extends StatefulWidget {
  late String title;
  final Future<DataQuestions> fdq;

  QuestionsPage({Key? key, required this.title, required this.fdq}) : super(key: key);

  @override
  _QuestionsPageState createState() => _QuestionsPageState();
}

class _QuestionsPageState extends State<QuestionsPage> {
  late int pos; //? pos: Current question.
  late DataQuestions dq; //? dq: Data of the API Call, have the response code and the json with the results.
  late bool bvToogle; //? bvToogle: Set the DropdownWidget enable or disable.
  late List<String> multiple = []; //? multiple: List with the current answers.
  late String sQuestion = ''; //? sQuestion: String to display the current question.
  late String sCategory = ''; //? sQuestion: String to display the current category.
  late int rightOption = 0; //? rightOption: Contain the position of the ListView button with the right answer.
  late bool bListViewPressed = false; //? bListViewPressed: indicate if a button of the list view was pressed.
  late int iListViewIndxPressed = -1; //? iListViewIndxPressed: index of the button pressed
  late bool bEnterFirstTime = true;
  late bool bLanguage = true;

  @override
  void initState() {
    super.initState();
    pos = 0;
    dq = DataQuestions.empty();
    bvToogle = true;
    bEnterFirstTime = true;
    bLanguage = true;
  }

  //! Func: Will load the List of Answers
  void _loadMultiple() {
    if (dq.responseList[pos]['type'] == 'multiple') {
      multiple = [
        dq.responseList[pos]['correct_answer'] + '\n' + dq.responseListTr[pos]['correct_answer'],
        dq.responseList[pos]['incorrect_answers'][0] + '\n' + dq.responseListTr[pos]['incorrect_answers'][0],
        dq.responseList[pos]['incorrect_answers'][1] + '\n' + dq.responseListTr[pos]['incorrect_answers'][1],
        dq.responseList[pos]['incorrect_answers'][2] + '\n' + dq.responseListTr[pos]['incorrect_answers'][2]
      ];
      multiple.shuffle(Random());
      rightOption = multiple.indexWhere((element) => element.contains(dq.responseList[pos]['correct_answer']));
    } else {
      multiple = ['Verdadero', 'Falso'];
      (dq.responseList[pos]['correct_answer'] == 'True') ? rightOption = 0 : rightOption = 1;
    }
    bListViewPressed = false;
    iListViewIndxPressed = -1;
  }

  //! Func: Provide the ButtonStyle that will have the ListView buttons
  //* In example: if the answer chosen is correct will paint the background of the button in green
  ButtonStyle _fLoadButtonStyle(int idx) {
    ButtonStyle ret = new ButtonStyle();
    if (iListViewIndxPressed == idx) {
      if (iListViewIndxPressed == rightOption) {
        ret = new ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.green), foregroundColor: MaterialStateProperty.all(Colors.white));
      } else
        ret = new ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.red), foregroundColor: MaterialStateProperty.all(Colors.white));
    } else if (bListViewPressed && idx == rightOption) {
      ret = new ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.green), foregroundColor: MaterialStateProperty.all(Colors.white));
    }
    return ret;
  }

  //! Widget function: Provide the ListView with the Answers Buttons
  Widget _wListViewRow() => ListView.builder(
      shrinkWrap: true,
      itemCount: multiple.length,
      itemBuilder: (BuildContext context, int index) {
        return Container(
            height: 75,
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
            child: ElevatedButton(
              style: _fLoadButtonStyle(index),
              child: Text('${multiple[index]}'),
              onPressed: (!bListViewPressed)
                  ? () {
                      setState(() {
                        iListViewIndxPressed = index;
                        bListViewPressed = true;
                      });
                    }
                  : null,
            ));
      });

  //! Widget function: Contains the Answers choices
  Widget _wAnswersMultiple() => Row(
        children: [
          Expanded(
              flex: 1,
              child: Column(
                children: [],
              )),
          Expanded(flex: 3, child: _wListViewRow()),
          Expanded(
              flex: 1,
              child: Column(
                children: [],
              )),
        ],
      );

  //! Widget function: Contains the button "Next"
  Widget _wButtonNext() => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
              child: ElevatedButton(
                  onPressed: (pos < dq.responseList.length - 1)
                      ? () {
                          setState(() {
                            pos++;
                            bLanguage = true;
                            sQuestion = dq.responseListTr[pos]['question'];
                            sCategory = dq.responseListTr[pos]['category'];
                            widget.title = 'Question N° ${pos + 1}/${dq.responseList.length}';
                            _loadMultiple();
                          });
                        }
                      : null,
                  child: Text('Siguiente')))
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Card(
            child: new FutureBuilder<DataQuestions>(
              future: widget.fdq,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  dq = snapshot.data!;

                  if (bEnterFirstTime) {
                    sQuestion = dq.responseListTr[pos]['question'];
                    sCategory = dq.responseListTr[pos]['category'];
                    _loadMultiple();
                    bEnterFirstTime = false;
                  }

                  return ListView(children: [
                    ListTile(
                      leading: Icon(Icons.album),
                      title: Text(sQuestion),
                      subtitle: Text(sCategory),
                    ),
                    Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
                      TextButton(
                        style: ButtonStyle(foregroundColor: MaterialStateProperty.all(Colors.greenAccent)),
                        child: Text((bLanguage) ? 'Language' : 'Idioma'),
                        onPressed: () {
                          setState(() {
                            sQuestion = (bLanguage) ? dq.responseList[pos]['question'] : dq.responseListTr[pos]['question'];
                            sCategory = (bLanguage) ? dq.responseList[pos]['category'] : dq.responseListTr[pos]['category'];
                            bLanguage = !bLanguage;
                          });
                        },
                      ),
                      const SizedBox(width: 16),
                    ]),
                    _wAnswersMultiple(),
                    _wButtonNext(),
                  ]);
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }
                return Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ));
  }
}
