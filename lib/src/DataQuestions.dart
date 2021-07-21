import 'package:http/http.dart' as http;
import 'package:universal_html/html.dart' as html;
import 'dart:convert';

class DataQuestions {
  late int responseCode;
  late List<dynamic> responseList;
  late List<dynamic> responseListTr;

  DataQuestions.empty();

  DataQuestions({required this.responseCode, required this.responseList}) {
    for (var i in this.responseList) {
      i['question'] = (html.Element.span()..appendHtml(i['question'])).innerText;
      if (i['type'] == 'multiple') {
        i['correct_answer'] = (html.Element.span()..appendHtml(i['correct_answer'])).innerText;
        for (int j = 0; j < 3; j++) {
          i['incorrect_answers'][j] = (html.Element.span()..appendHtml(i['incorrect_answers'][j])).innerText;
        }
      }
    }

    this.responseListTr = json.decode(json.encode(this.responseList));

    for (int i = 0; i < this.responseListTr.length; i++) {
      for (var k in this.responseListTr[i].keys) {
        if (k != 'incorrect_answers') {
          translate(this.responseListTr[i][k].toString(), from: 'en', to: 'es').then((value) => this.responseListTr[i][k] = value);
        } else if (this.responseList[i]['type'] != 'boolean') {
          for (int j = 0; j < 3; j++)
            translate(this.responseListTr[i]['incorrect_answers'][j].toString(), from: 'en', to: 'es')
                .then((value) => this.responseListTr[i]['incorrect_answers'][j] = value);
        }
      }
    }
  }

  factory DataQuestions.fromJson(Map<String, dynamic> json) {
    return DataQuestions(responseCode: json['response_code'], responseList: json['results']);
  }
}

//* Codigo de la http request para traducir
Future<String> translate(String s, {String? from = 'en', String? to = 'es'}) async {
  final response = await http.post(Uri.parse('https://translate.astian.org/translate'),
      headers: {"Content-Type": "application/json"}, body: jsonEncode({"q": s, "source": from, "target": to}));

  return jsonDecode(response.body)['translatedText'].toString();
}
