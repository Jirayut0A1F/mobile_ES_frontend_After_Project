import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class InfoPage extends StatefulWidget {
  const InfoPage({super.key});

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  List infoAdmin = [];
  @override
  void initState() {
    super.initState();
    getInfoAdmin();
  }

  Future<void> getInfoAdmin() async {
    final res = await http.get(Uri.parse('http://mesb.in.th:8000/noti/'));
    if (res.statusCode == 200) {
      setState(() {
        infoAdmin = json.decode(res.body);
      });
    } else {
      print('Failed to load Info from Admin');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ข่าวสารจากผู้ดูแลระบบ',
          style: GoogleFonts.mitr(color: Colors.white, fontSize: 30),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        child: ListView.builder(
          itemCount: infoAdmin.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(
                infoAdmin[index][0],
                style: GoogleFonts.mitr(fontSize: 16),
              ),
              subtitle: Text(
                infoAdmin[index][1],
                style: GoogleFonts.mitr(fontSize: 16),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(
                        infoAdmin[index][0],
                        style: GoogleFonts.mitr(fontSize: 25),
                      ),
                      content: Text(
                        infoAdmin[index][1],
                        style: GoogleFonts.mitr(fontSize: 16),
                      ),
                      actions: <Widget>[
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'ตกลง',
                            style: GoogleFonts.mitr(fontSize: 20),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
