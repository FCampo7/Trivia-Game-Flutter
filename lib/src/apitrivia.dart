import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:triviagame/src/DataQuestions.dart';

/*
	Obtener datos de la API // Get data from the API

	#### Parametros:
	* @param cantidad: Cantidad de preguntas a traer por la api // Number of questions that the API brings
	* @param categoria: N° de la categoria a elegir 0: todas, [9; 32]: Categorias disponibles // N° of the category chosen 0: any, [9; 32]: available categories

	#### Returns:
  * Promise
	*/

Future<DataQuestions> apiGet(int cantidad, int categoria) async {
  if (categoria != 0 && (9 > categoria || 32 < categoria)) categoria = 0;

  String apiURL = "https://opentdb.com/api.php?amount=" + cantidad.toString() + "&category=" + categoria.toString();

  final response = await http.get(Uri.parse(apiURL));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return DataQuestions.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load DataQuestions');
  }
}
