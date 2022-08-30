import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class FetchData extends ChangeNotifier {
  List<dynamic> dataList = [];
  bool hasMore = true;


  Future<void> fetchData({ required String url , required int limit,required int page }) async {
    final http.Response response = await http.get(Uri.parse(url));
    final List<dynamic> data = await jsonDecode(response.body);


    if(response.statusCode == 200 ) {

      if(response.contentLength! <= 2) {
        hasMore = false;
      } else {
        hasMore = true;
      }

      dataList.addAll(data.map((e) => e).toList());

      notifyListeners();

    }
  }


  Future<void> fetchDataRandom({ required String url , required int limit,required int page }) async {
    final http.Response response = await http.get(Uri.parse(url));
    final Map<String,dynamic> map = await jsonDecode(response.body);
    final List<dynamic> data = map['results'];


    print(response.contentLength);

    if(response.statusCode == 200 ) {

      if(dataList.length < limit) {
        hasMore = false;
      } else {
        hasMore = true;
      }

      dataList.addAll(data.map((e) => e).toList());

      notifyListeners();

    }
  }


  Future<void> refreshData(int page) async {
    hasMore = false;
    page = 1;
    dataList.clear();
    notifyListeners();
  }

}

class FetchModel {
  final String title , body;
  final int id;

  const FetchModel({ required this.title , required this.body , required this.id });

  factory FetchModel.fromJson(Map<String , dynamic>json) {
    return FetchModel(
        title: json['title'] ,
        body: json['body'] ,
        id: json['id']
    );
  }

  static Future<List<FetchModel>> fetchData() async {
    final http.Response response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts'));
    final List<dynamic> body = await jsonDecode(response.body);

    if(response.statusCode == 200) {
      final List<FetchModel> data = body.map((e) => FetchModel.fromJson(e)).toList();
      return data;
    } else {
      throw Exception('Error');
    }
  }
}

class RandomUserModel {
  final String title;
  final int id;

  const RandomUserModel({required this.title,required this.id});

  factory RandomUserModel.fromJson(Map<String , dynamic>json) {
    return RandomUserModel(
        id: json['id'] ,
        title: json['title']
    );
  }
}

