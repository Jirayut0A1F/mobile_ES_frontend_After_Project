// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:app_sit/screen/history.dart';
import 'package:app_sit/screen/home.dart';
import 'package:app_sit/screen/setting.dart';
import 'package:google_fonts/google_fonts.dart';

class BTbar extends StatefulWidget {
  const BTbar({super.key});

  @override
  State<BTbar> createState() => _BTbarState();
}

class _BTbarState extends State<BTbar> {
  int currentIndex = 0;
  late List<Widget> widgetOption;

  @override
  void initState() {
    super.initState();
    widgetOption = [
      const HomePage(),
      const HistoryPage(),
      const SettingPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widgetOption[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'หน้าแรก'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'ประวัติ'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'ตั้งค่า')
        ],
        backgroundColor: Colors.white,
        selectedItemColor: Colors.red,
        selectedLabelStyle: GoogleFonts.mitr(fontSize: 16),
        unselectedLabelStyle: GoogleFonts.mitr(fontSize: 16),
        currentIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
      ),
    );
  }
}
