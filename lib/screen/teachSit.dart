// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class TeachSitPagge extends StatefulWidget {
  const TeachSitPagge({super.key});

  @override
  State<TeachSitPagge> createState() => _TeachSitPaggeState();
}

class _TeachSitPaggeState extends State<TeachSitPagge> {
  var info =
      '1) ศีรษะตั้งตรง ก้มหรือเงยอยู่ในช่วง 10-15 องศา และไม่ยืนคอไปข้างหน้า\n2) หลังชิดพนักพิงของเก้าอี้หรือเอนเล็กน้อย นั่นคือ แกนหลังทำมุม 90-120 องศา จากแกนหน้าขา\n3) แขนกับแกนลำตัวทำมุมไม่เกิน 60 องศา\n4) ต้นขาวางราบกับที่นั่ง ข้อเข่าพับทำมุม 85-95 องศา\n5) เท้าวางราบกับพื้น (ไม่นั่งเท้าลอย) ';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'วิธีนั่งที่ถูกต้อง',
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
                      'assets/images/TeachSit.png',
                      fit: BoxFit.fill,
                    )),
              ),
              Container(
                  padding: const EdgeInsets.all(8),
                  // color: Colors.white,
                  // decoration: BoxDecoration(
                  //   color: Colors.white,
                  //   border: Border.all(
                  //     color: Colors.black, // สีของกรอบ
                  //     width: 5, // ความหนาของกรอบ
                  //   ),
                  //   borderRadius: BorderRadius.circular(10), // มุมโค้งของกรอบ
                  // ),
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
                    Navigator.pushNamed(context, '/teachCamera');
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
