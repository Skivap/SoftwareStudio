import 'package:http/http.dart' as http;
import 'dart:convert'; // For json decoding
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<String> fetchVitonResult(String bgUrl, String grUrl) async {
  String hostApi = dotenv.env['HOST_API']!;

  var url = Uri.http(hostApi, '/viton/', {
    'bgUrl': bgUrl,
    'grUrl': grUrl
  });

  try {
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      return jsonResponse['result'].toString();
    } else {
      return 'Failed with status code: ${response.statusCode}';
    }
  } catch (e) {
    return 'Failed to connect or retrieve data: $e';
  }
}