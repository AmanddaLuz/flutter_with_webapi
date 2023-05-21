import 'dart:convert';
import 'dart:io';

import 'package:flutter_webapi_first_course/models/journal.dart';
import 'package:flutter_webapi_first_course/services/webclient.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class JournalService {
  static const String resource = "journals/";
  String url = WebClient.url;
  http.Client client = WebClient().client;

  String getUrl() {
    return "$url$resource";
  }

  Uri getUri() {
    return Uri.parse(getUrl());
  }

  Future<bool> register(Journal journal) async {
    String journalJSON = json.encode(journal.toMap());

    String token = await getToken();
    http.Response response = await client.post(
      getUri(),
      headers: {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: journalJSON,
    );

    if (response.statusCode != 201) {
      verifyException(json.decode(response.body));
    }

    return true;
  }

  Future<String> get() async {
    http.Response response = await client.get(Uri.parse(getUrl()));
    print(response.body);
    return response.body;
  }

  Future<List<Journal>> getAll(
      {required String id, required String token}) async {
    http.Response response = await client.get(
        Uri.parse("${url}users/$id/journals"),
        headers: {"Authorization": "Bearer $token"});

    if (response.statusCode != 200) {
      if (json.decode(response.body) == "jwt expired") {
        throw TokenNotValidException();
      }
      throw HttpException(response.body);
    }
    List<Journal> list = [];

    List<dynamic> listDynamic = json.decode(response.body);

    for (var jsonMap in listDynamic) {
      list.add(Journal.fromMap(jsonMap));
    }
    print(list.length);

    return list;
  }

  Future<bool> edit(String id, Journal journal) async {
    String journalJSON = json.encode(journal.toMap());

    String token = await getToken();
    http.Response response = await client.put(
      Uri.parse("${getUrl()}$id"),
      headers: {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: journalJSON,
    );

    if (response.statusCode != 200) {
      verifyException(json.decode(response.body));
    }

    return true;
  }

  Future<bool> delete(String id, String token) async {
    http.Response response = await http.delete(
      Uri.parse("${getUrl()}$id"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode != 200) {
      if (json.decode(response.body) == "jwt expired") {
        throw TokenNotValidException();
      }
      throw HttpException(response.body);
    }
    return true;
  }
}

Future<String> getToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('accessToken');
  if (token != null) {
    return token;
  }
  return '';
}

verifyException(String error) {
  switch (error) {
    case 'jwt expired':
      throw TokenExpiredException();
  }

  throw HttpException(error);
}

class TokenExpiredException implements Exception {}

class TokenNotValidException implements Exception {}
