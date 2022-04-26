import 'dart:convert';
import 'package:http/http.dart' as http;

class DaisyHandler {
  static Future<List<String>> getISBN(String code) async {
    var response = await http.get(Uri.https(
        'apitest.dsv.su.se', '/rest/public/course/' + code + '/literature'));

    List<String> result = [];
    if (!response.body.isEmpty) {
      Map<String, dynamic> data = jsonDecode(response.body);
      List<dynamic> literature = data[data.keys.first];

      literature.forEach((book) {
        var isbn = (book as Map<String, dynamic>)['ISBN'];
        isbn = isbn.replaceAll("-", "");
        isbn = isbn.replaceAll(" ", "");
        result.add(isbn.trim());
      });
    }

    return result;
  }
}
