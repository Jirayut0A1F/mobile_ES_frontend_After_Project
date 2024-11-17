import 'package:app_sit/resources/app_colors.dart';
import 'package:app_sit/screen/login.dart';
import 'package:app_sit/services/userAPI.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class ipAddress extends StatefulWidget {
  const ipAddress({super.key});

  @override
  State<ipAddress> createState() => _ipAddressState();
}

class _ipAddressState extends State<ipAddress> {
  final TextEditingController _urlController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'กรอก Server URL',
          style: GoogleFonts.mitr(
              color: AppColors.contentColorWhite, fontSize: 30),
        ),
        backgroundColor: AppColors.contentColorBlue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(TextSpan(children: [
              TextSpan(
                  text:
                      'URL ต้องเริ่มด้วย http และจบด้วยเลขพอร์ตโดยไม่ต้องมี / ปิดท้าย\n',
                  style: GoogleFonts.mitr(fontSize: 18)),
              TextSpan(
                  text: 'ตัวอย่าง ',
                  style: GoogleFonts.mitr(
                      color: AppColors.contentColorRed, fontSize: 18)),
              TextSpan(
                  text:
                      'http://mesb.in.th:8000\n\nกรุณากรอก URL ของเครื่องเซิร์ฟเวอร์:',
                  style: GoogleFonts.mitr(fontSize: 18))
            ])),
            // Text(
            //   'URL ต้องเริ่มด้วย http และจบด้วยเลขพอร์ตโดยไม่ต้องมี / ปิดท้าย\n$a http://mesb.in.th:8000\n\nกรุณา กรอก Server URL:',
            //   style: GoogleFonts.mitr(fontSize: 18),
            // ),
            const SizedBox(height: 8.0),
            TextField(
              controller: _urlController,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                hintStyle: GoogleFonts.mitr(),
                hintText:
                    'http://mesb.in.th:8000', // ตัวอย่าง URL ที่แสดงในช่องกรอก
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  final url = _urlController.text;
                  if (await _testIP(url)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                        'URL: $url ถูกต้อง',
                        style: GoogleFonts.mitr(),
                      )),
                    );
                    Provider.of<UserAPI>(context, listen: false).getIP(url);
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()),
                      ModalRoute.withName('/login'),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                        ' URL ไม่ถูกต้อง. กรุณาลองกรอกใหม่อีกครั้ง.',
                        style: GoogleFonts.mitr(),
                      )),
                    );
                  }
                },
                child: Text(
                  'ยืนยัน',
                  style: GoogleFonts.mitr(fontSize: 18, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _testIP(String url) async {
    final res = await http.get(Uri.parse('$url/noti/'));
    if (res.statusCode == 200) {
      return true;
    } else {
      print('Failed to load Info from Admin');
      return false;
    }
  }

  // bool _validateUrl(String url) {
  //   final regex = RegExp(
  //       r'^(https?:\/\/)?([a-zA-Z0-9\-]+\.)+[a-zA-Z]{2,}(:\d+)?(\/.*)?$');
  //   return regex.hasMatch(url);
  // }
}
