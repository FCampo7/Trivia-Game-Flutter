import 'package:flutter/material.dart';
import 'package:triviagame/src/DataQuestions.dart';
import 'package:triviagame/src/Question_Page.dart';
import 'package:triviagame/src/apitrivia.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Application name
      title: 'Trivia Game',
      theme: ThemeData(
        // Application theme data, you can set the colors for the application as
        // you want
        primarySwatch: Colors.green,
        brightness: Brightness.dark,
      ),
      home: MyHomePage(title: 'Trivia Game'),
    );
  }
}

//* Beginin of HomePage
class MyHomePage extends StatefulWidget {
  final String title;

  MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late int cantidad, categoria; //? cantidad: Amount of Questions; categoria: Category of the questions.
  late Future<DataQuestions> futureQuestions; //? futureQuestions: Promise with the data.
  late String sButtonConfirmar; //? sButtonConfirmar: String of the text widget inside button confirmar ('Confirmar' or 'Nuevas Preguntas').
  late bool isVisible = false;

  //* Initialize the state
  @override
  void initState() {
    super.initState();
    cantidad = 1;
    categoria = 1;
    sButtonConfirmar = 'Confirmar';
    isVisible = false;
  }

  /* /*
  * override didChangeDependencies because let me made new API Calls
  * Sobrecargo didChangeDependencies para que me deje hacer nuevos llamados a API
  */
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    futureQuestions = apiGet(cantidad, categoria);
  } */

  //! Widget function: Contain the amount of questions
  Widget _wAmountQuestions() => Row(mainAxisSize: MainAxisSize.min, children: [
        Padding(
          padding: EdgeInsets.all(5),
          child: Text('Cantidad de preguntas:'),
        ),
        Expanded(
          child: MyDropdownWidget(
            lDropdown: getDropDownMenuItems(),
            onChanged: (int value) {
              cantidad = value;
            },
            isDisable: false,
          ),
        )
      ]);

  //! Widget function: Contain the categories
  Widget _wCategories() => Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, mainAxisSize: MainAxisSize.min, children: [
        Padding(
          padding: EdgeInsets.all(5),
          child: Text('Categoria:'),
        ),
        Expanded(
          child: MyDropdownWidget(
            lDropdown: getDropDownMenuItemsCategories(),
            onChanged: (int nValue) {
              categoria = nValue;
            },
            isDisable: false,
          ),
        ),
        Container(
          padding: EdgeInsets.all(5),
          width: 125,
          child: ElevatedButton(
              child: Text(sButtonConfirmar),
              onPressed: () async {
                setState(() {
                  isVisible = true;
                });

                futureQuestions = apiGet(cantidad, categoria);
                await new Future.delayed(const Duration(milliseconds: 3000));

                setState(() {
                  isVisible = false;
                });

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => QuestionsPage(title: 'Pregunta N° 1/$cantidad', fdq: futureQuestions)),
                );
              }),
        )
      ]);

  /*
  * Build builder of the HomePage
  */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Padding(
            padding: EdgeInsets.all(20),
            child: Center(
                child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
              Visibility(
                child: CircularProgressIndicator(),
                visible: isVisible,
                replacement: Column(
                  children: [
                    _wAmountQuestions(),
                    _wCategories(),
                  ],
                ),
              )
            ]))));
  }
}
//! End of the HomePage

/*
 * My custom DropdownButton
 */
//ignore: must_be_immutable
class MyDropdownWidget extends StatefulWidget {
  List<DropdownMenuItem<int>> lDropdown;
  void Function(int newValue)? onChanged;
  bool? isDisable;

  MyDropdownWidget({Key? key, required this.lDropdown, this.onChanged, this.isDisable}) : super(key: key);

  @override
  State<MyDropdownWidget> createState() => _MyDropdownWidget();
}

class _MyDropdownWidget extends State<MyDropdownWidget> {
  late int dropdownValue;

  @override
  void initState() {
    super.initState();
    dropdownValue = 1;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<int>(
      value: dropdownValue,
      icon: const Icon(Icons.arrow_downward),
      iconSize: 16,
      elevation: 4,
      isExpanded: true,
      underline: Container(
        height: 0.5,
        color: Colors.black38,
      ),
      onChanged: (widget.isDisable!) ? null : (newValue) => _vMDDWonChange(newValue),
      items: widget.lDropdown,
    );
  }

  void _vMDDWonChange(int? newValue) {
    setState(() {
      dropdownValue = newValue!;
    });
    widget.onChanged!(newValue!);
  }
}
//! End of the DropdownButton

/*
 * Map with all Categories
 */
Map<String, int> dictCategorias = {
  'Todas': 1,
  'Conocimiento General': 9,
  'Entr.: Libros': 10,
  'Entr.: Pelis': 11,
  'Entr.: Musica': 12,
  'Entr.: Musicales': 13,
  'Entr.: Tele': 14,
  'Entr.: Video Juegos': 15,
  'Entr.: Juegos de mesa': 16,
  'Ciencia y nat.': 17,
  'Ciencia: Computadoras': 18,
  'Ciencia: Matemática': 19,
  'Mitología': 20,
  'Deportes': 21,
  'Geografía': 22,
  'Historia': 23,
  'Política': 24,
  'Arte': 25,
  'Celebridades': 26,
  'Animales': 27,
  'Vehículos': 28,
  'Ciencia: Gadgets': 30,
  'Entr.: Dibujos y animaciones': 32
};

/*
* Create a List of DropdownMenuItems with the amount of questions to retrive
*/
List<DropdownMenuItem<int>> getDropDownMenuItems() {
  List<DropdownMenuItem<int>> items = [];
  for (int i = 1; i < 51; i++) {
    items.add(new DropdownMenuItem(value: i, child: new Text(i.toString())));
  }
  return items;
}

/*
 * Create a List of DropdownMenuItems with the categories
 */
List<DropdownMenuItem<int>> getDropDownMenuItemsCategories() {
  List<DropdownMenuItem<int>> items = [];
  for (String s in dictCategorias.keys) {
    items.add(new DropdownMenuItem(value: dictCategorias[s], child: new Text(s)));
  }
  return items;
}
