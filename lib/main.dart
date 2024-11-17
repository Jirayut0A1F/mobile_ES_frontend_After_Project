import 'package:app_sit/screen/cameraCalibrate.dart';
import 'package:app_sit/screen/cameraDetect.dart';
import 'package:app_sit/screen/infoAdmin.dart';
import 'package:app_sit/screen/ipAddress.dart';
import 'package:app_sit/screen/login.dart';
import 'package:app_sit/services/userAPI.dart';
import 'package:app_sit/screen/teachCamera.dart';
import 'package:app_sit/screen/teachSit.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';

List<CameraDescription> _cameras = <CameraDescription>[];
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    _cameras = await availableCameras();
  } on CameraException catch (e) {
    _logError(e.code, e.description);
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserAPI()),
      ],
      child: MyApp(cameras: _cameras),
    ),
  );
}

class MyApp extends StatelessWidget {
  final List<CameraDescription>? cameras;

  const MyApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return buildMaterialApp(cameras);
  }

  MaterialApp buildMaterialApp(List<CameraDescription>? cameras) {
    return MaterialApp(
      title: 'App MESB',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/infoAdmin':
            return _createSlideTransitionRoute(const InfoPage());
          case '/teachSit':
            return _createSlideTransitionRoute(const TeachSitPagge());
          case '/teachCamera':
            return _createSlideTransitionRoute(const TeachCameraPage());
          case '/ipAddress':
            return _createSlideTransitionRoute(const ipAddress());
          case '/cameraDetect':
            return _createSlideTransitionRoute(
                CameraDetect(cameras: cameras ?? []));
          case '/cameraCalibrate':
            return _createSlideTransitionRoute(
                CameraCalibrate(cameras: cameras ?? []));
          default:
            return MaterialPageRoute(builder: (context) => const LoginPage());
        }
      },
    );
  }

  // ฟังก์ชันที่สร้างการสไลด์ไปทางซ้าย
  PageRouteBuilder _createSlideTransitionRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0); // เริ่มจากด้านขวา
        const end = Offset.zero; // จบที่ตำแหน่งปกติ
        const curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }
}

void _logError(String code, String? message) {
  // ignore: avoid_print
  print('Error: $code${message == null ? '' : '\nError Message: $message'}');
}
