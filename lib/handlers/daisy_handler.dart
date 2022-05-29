import 'dart:convert';
import 'package:http/http.dart' as http;

///Handler class which interacts with the Daisy API
class DaisyHandler {
  ///Given a course shortCode, returns a set of ISBNs for that course. If course
  ///does not exist or does not have any literature registered, returns an empty set.
  static Future<Set<String>> getISBN(String code) async {
    //Fetch data from API
    var response = await http.get(Uri.https(
        'apitest.dsv.su.se', '/rest/public/course/' + code + '/literature'));

    Set<String> result = {};

    //Check results
    if (response.statusCode == 200 && response.body != '{}') {
      Map<String, dynamic> data = jsonDecode(response.body);
      List<dynamic> literature = data[data.keys.first];

      //Format ISBN
      for (var book in literature) {
        var isbn = (book as Map<String, dynamic>)['ISBN'];
        isbn = isbn.replaceAll("-", "");
        isbn = isbn.replaceAll(" ", "");
        result.add(isbn.trim());
      }
    }

    return result;
  }
}
