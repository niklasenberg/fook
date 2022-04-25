import 'dart:convert';
import 'package:http/http.dart' as http;

class DaisyHandler{

  static Future<List<String>> getISBN(String code) async {
    var response = await http.get(Uri.https('apitest.dsv.su.se', '/rest/public/course/' + code + '/literature'));

    var data = jsonDecode(response.body);

    List<String> literature = [];

    for(var i in data){
      String isbn = i['isbn'];
      isbn.replaceAll("-", "");
      isbn.replaceAll(" ", "");
      literature.add(isbn.trim());
    }

    return literature;
  }
}