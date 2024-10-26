import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TeachCameraPage extends StatefulWidget {
  const TeachCameraPage({super.key});

  @override
  State<TeachCameraPage> createState() => _TeachCameraPageState();
}

class _TeachCameraPageState extends State<TeachCameraPage> {
  var info =
      'ตั้งกล้องแนวตั้งระนาบกับพื้นโดยตัวกล้องให้อยู่ด้านข้างของผู้ใช้งานให้ห่างพอประมาน โดยสามารถเห็นได้ตั้งแต่ศีรษะจนถึงปลายเท้าและตัวของผู้ใช้งานควรอยู่ตรงกลางของกล้อง';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'วิธีตั้งกล้องที่ถูกต้อง',
          style: GoogleFonts.mitr(fontSize: 30),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            children: [
              Card(
                color: Colors.grey,
                child: Container(
                    padding: const EdgeInsets.all(15),
                    width: 330,
                    height: 420,
                    child: Image.asset(
                      'assets/images/TeachCamera.png',
                      fit: BoxFit.fill,
                    )),
              ),
              Container(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    info,
                    style: GoogleFonts.mitr(fontSize: 16),
                  )),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/cameraCalibrate');
                  },
                  icon: const Icon(
                    Icons.arrow_circle_right,
                    size: 60,
                    color: Colors.blue,
                  )),
            ],
          )
        ],
      ),
    );
  }
}
