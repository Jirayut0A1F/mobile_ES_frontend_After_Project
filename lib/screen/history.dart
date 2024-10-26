import 'package:app_sit/widget/history_day.dart';
import 'package:app_sit/widget/history_delete.dart';
import 'package:app_sit/widget/history_month.dart';
import 'package:app_sit/resources/app_resources.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: AppColors.contentColorBlueSky,
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Text('รายวัน', style: GoogleFonts.mitr(fontSize: 18)),
                Text('รายเดือน', style: GoogleFonts.mitr(fontSize: 18)),
                Text('ลบประวัติ', style: GoogleFonts.mitr(fontSize: 18))
              ],
              unselectedLabelColor: Colors.white,
              labelColor: const Color.fromARGB(255, 251, 225, 33),
            ),
            title: Text(
              'ประวัติ',
              style: GoogleFonts.mitr(
                  color: AppColors.contentColorWhite, fontSize: 30),
            ),
            backgroundColor: AppColors.contentColorBlue,
          ),
          body: const TabBarView(
            children: [
              History_Day(),
              History_Month(),
              History_Delete(),
            ],
          ),
        ),
      ),
    );
  }
}
