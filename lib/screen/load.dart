import 'dart:convert';

import 'package:app_sit/widget/BTbar.dart';
import 'package:app_sit/services/userAPI.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class LoadPage extends StatefulWidget {
  final GoogleSignInAccount user;
  const LoadPage({super.key, required this.user});

  @override
  State<LoadPage> createState() => _LoadPageState();
}

class _LoadPageState extends State<LoadPage> {
  late Future<void> _loadDataFuture;

  @override
  void initState() {
    super.initState();
    // Initialize the future to load data
    _loadDataFuture = _loadData();
  }

  Future<void> _loadData() async {
    await Provider.of<UserAPI>(context, listen: false).getUserData(widget.user);
    await Provider.of<UserAPI>(context, listen: false).getSettingData();
  }

  Future<void> stopDetect(String id) async {
    const url = 'http://43.229.133.174:8000/end_detect/';
    final res = await http.post(Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UtF-8'
        },
        body: jsonEncode(<String, String>{
          'accountID': id,
        }));
    if (res.statusCode == 200) {
      print(res.body);
    } else {
      print('Failed to end');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _loadDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            stopDetect(Provider.of<UserAPI>(context, listen: false).user!.id);
            // Navigate to BTbar after data is loaded
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const BTbar()),
                ModalRoute.withName('/BTbar'),
              );
            });
            return Container(); // Return an empty container until navigation
          }
        },
      ),
    );
  }
}
