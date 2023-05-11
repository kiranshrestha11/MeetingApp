import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:webrtcvideocallapp/utils/user.utils.dart';

String meetingApiUrl = "http://10.1.18.71:4000/api/meeting";
var client = http.Client();

Future<http.Response?> startMeeting() async {
  Map<String, String> requestHeaders = {
    'Content-Type': 'application/json',
  };

  var userId = await loadUserId();
  try {
    var response = await client.post(
      Uri.parse("$meetingApiUrl/start"),
      headers: requestHeaders,
      body: jsonEncode(
        {
          'hostId': userId,
          'hostName': '',
        },
      ),
    );

    if (response.statusCode == 200) {
      return response;
    } else {
      return null;
    }
  } catch (e) {
    log(e.toString());
  }
  return null;
}

Future<http.Response> joinMeeting(String meetingId) async {
  var response =
      await http.get(Uri.parse("$meetingApiUrl/join?meetingId=$meetingId"));
  if (response.statusCode >= 200 && response.statusCode < 400) {
    return response;
  }
  throw UnsupportedError('Not a valid meeting');
}
