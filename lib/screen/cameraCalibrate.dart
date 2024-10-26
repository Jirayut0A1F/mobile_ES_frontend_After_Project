// ignore_for_file: avoid_print

import 'dart:convert';
// import 'dart:math';

import 'package:app_sit/screen/adjust.dart';
import 'package:app_sit/services/userAPI.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
// import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'package:wakelock_plus/wakelock_plus.dart';

class CameraCalibrate extends StatefulWidget {
  final List<CameraDescription> cameras;

  const CameraCalibrate({super.key, required this.cameras});
  // const CameraCalibrate({Key? key, required this.cameras}) : super(key: key);

  @override
  State<CameraCalibrate> createState() => _CameraCalibrateState();
}

Future<Map<String, Map>?> uploadCalibrate(
    String id, XFile imageFile, String startCalibrate) async {
  const url = 'http://mesb.in.th:8000/process_calibrate/';
  Uint8List bytes = await imageFile.readAsBytes();
  String imageBase64 = base64Encode(bytes);
  final res = await http.post(Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UtF-8'
      },
      body: jsonEncode(<String, String>{
        'accountID': id,
        'imgStr': imageBase64,
        'startCalibrate': startCalibrate,
      }));
  print('$id,$startCalibrate');
  if (res.statusCode == 200) {
    final data = jsonDecode(res.body);
    print('return $data');
    Map<String, dynamic> dataPoint = {
      'Ear': data['Ear'],
      'Shoulder': data['Shoulder'],
      'Elbow': data['Elbow'],
      'Hip': data['Hip'],
      'Knee': data['Knee'],
      'Ankle': data['Ankle'],
      'imagSize': data['imgSize'],
    };
    Map<String, String> dataAnother = {
      'state_no': data['state_no'].toString(),
      'is_left': data['is_left'].toString(),
      'imgStr': data['imgStr'].toString()
    };
    Map<String, Map> dataModel = {
      'dataPoint': dataPoint,
      'dataAnother': dataAnother
    };
    return dataModel;
  } else {
    print('Error:${res.statusCode}');
    return <String, Map>{};
  }
}

/// Returns a suitable camera icon for [direction].
IconData getCameraLensIcon(CameraLensDirection direction) {
  switch (direction) {
    case CameraLensDirection.back:
      return Icons.camera_rear;
    case CameraLensDirection.front:
      return Icons.camera_front;
    case CameraLensDirection.external:
      return Icons.camera;
  }
  // This enum is from a different package, so a new value could be added at
  // any time. The example should keep working if that happens.
  // ignore: dead_code
  return Icons.camera;
}

class PointsLinePainter extends CustomPainter {
  final bool left;

  const PointsLinePainter({Key? key, required this.left});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 4;

    // Define the points based on the example image
    final pointRight = [
      Offset(size.width * 0.66, size.height * 0.3), // head
      Offset(size.width * 0.66, size.height * 0.4), // shoulder
      // Offset(size.width * 0.48, size.height * 0.4), // arm
      Offset(size.width * 0.66, size.height * 0.55), // waist
      Offset(size.width * 0.35, size.height * 0.55), // knee
      Offset(size.width * 0.35, size.height * 0.74), // foot
    ];
    final pointLeft = [
      Offset(size.width * 0.35, size.height * 0.3),
      Offset(size.width * 0.35, size.height * 0.4),
      Offset(size.width * 0.35, size.height * 0.55),
      Offset(size.width * 0.66, size.height * 0.55),
      Offset(size.width * 0.66, size.height * 0.74),
    ];

    final pointsSquare = [
      Offset(size.width * 0.1, size.height * 0.07),
      Offset(size.width * 0.9, size.height * 0.07),
      Offset(size.width * 0.9, size.height * 0.93),
      Offset(size.width * 0.1, size.height * 0.93),
      Offset(size.width * 0.1, size.height * 0.07),
    ];

    for (int i = 0; i < pointsSquare.length - 1; i++) {
      canvas.drawLine(pointsSquare[i], pointsSquare[i + 1], paint);
    }

    // // Draw lines
    // for (int i = 0; i < 2; i++) {
    //   canvas.drawLine(points[i], points[i + 1], paint);
    // }

    // // Draw a line from point 1 to point 3 directly
    // canvas.drawLine(points[1], points[3], paint);

    if (left) {
      for (int i = 0; i < pointLeft.length - 1; i++) {
        canvas.drawLine(pointLeft[i], pointLeft[i + 1], paint);
      }
    } else {
      for (int i = 0; i < pointRight.length - 1; i++) {
        canvas.drawLine(pointRight[i], pointRight[i + 1], paint);
      }
    }

    final pointPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    for (final point in pointRight) {
      canvas.drawCircle(point, 0.0, pointPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class _CameraCalibrateState extends State<CameraCalibrate>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  CameraController? controller;
  XFile? imageFile;
  XFile? videoFile;
  VideoPlayerController? videoController;
  VoidCallback? videoPlayerListener;
  bool enableAudio = true;
  bool left = false;
  late AnimationController _flashModeControlRowAnimationController;
  late AnimationController _exposureModeControlRowAnimationController;
  late AnimationController _focusModeControlRowAnimationController;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _currentScale = 1.0;
  double _baseScale = 1.0;

  // Counting pointers (number of user fingers on screen)
  int _pointers = 0;
  late List<CameraDescription> _cameras;

  // Timer to take picture every 5 seconds
  Timer? _timer, _preTimer;
  bool _isTakingPictures = false;

  Map<String, Map>? dataModel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _flashModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _exposureModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _focusModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // เข้าถึง inherited widget ที่นี่
    _cameras = widget.cameras;

    // เลือกกล้องหน้าถ้ามี
    if (_cameras.isNotEmpty) {
      CameraDescription? frontCamera;
      for (var camera in _cameras) {
        if (camera.lensDirection == CameraLensDirection.front) {
          frontCamera = camera;
          break;
        }
      }
      if (frontCamera != null) {
        onNewCameraSelected(frontCamera);
      }
    }

    // แสดงกล่องข้อความแจ้งเตือน
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'คำแนะนำ',
              style: GoogleFonts.mitr(),
            ),
            content: Text(
              'เมื่อกดปุ่ม “เริ่ม” โปรแกรมจะจับภาพคุณไปจนกว่ากล้องจะพบคุณ และบันทึกภาพท่านั่งของคุณ เพื่อใช้ปรับแต่งท่านั่งอ้างอิงต่อไป',
              style: GoogleFonts.mitr(),
            ),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'ตกลง',
                  style: GoogleFonts.mitr(),
                ),
              ),
            ],
          );
        },
      );
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _flashModeControlRowAnimationController.dispose();
    _exposureModeControlRowAnimationController.dispose();
    _focusModeControlRowAnimationController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  // #docregion AppLifecycle
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCameraController(cameraController.description);
    }
  }
  // #enddocregion AppLifecycle

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'กล้องตรวจจับ',
          style: GoogleFonts.mitr(fontSize: 30),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(
                  color:
                      controller != null && controller!.value.isRecordingVideo
                          ? Colors.redAccent
                          : Colors.grey,
                  width: 3.0,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(1.0),
                child: Center(
                  child: _cameraPreviewWidget(),
                ),
              ),
            ),
          ),
          _captureControlRowWidget(),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _cameraToggleSwitch(),
                const SizedBox(
                  width: 20,
                ),
                _lineSwitch(),
                // _thumbnailWidget(),s
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return const Text(
        ' ',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Stack(
            children: [
              FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  child: AspectRatio(
                    aspectRatio: cameraController.value.aspectRatio,
                    child: CameraPreview(controller!),
                  ),
                ),
              ),
              CustomPaint(
                size: const Size(double.infinity, double.infinity),
                painter: PointsLinePainter(left: left),
              ),
            ],
          );
        },
      );
    }
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _baseScale = _currentScale;
  }

  Future<void> _handleScaleUpdate(ScaleUpdateDetails details) async {
    // When there are not exactly two fingers on screen don't scale
    if (controller == null || _pointers != 2) {
      return;
    }

    _currentScale = (_baseScale * details.scale)
        .clamp(_minAvailableZoom, _maxAvailableZoom);

    await controller!.setZoomLevel(_currentScale);
  }

  /// Display the thumbnail of the captured image or video.
  Widget _thumbnailWidget() {
    final VideoPlayerController? localVideoController = videoController;

    return Expanded(
      child: Align(
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (localVideoController == null && imageFile == null)
              Container()
            else
              SizedBox(
                width: 64.0,
                height: 64.0,
                child: (localVideoController == null)
                    ? (
                        // The captured image on the web contains a network-accessible URL
                        // pointing to a location within the browser. It may be displayed
                        // either with Image.network or Image.memory after loading the image
                        // bytes to memory.
                        kIsWeb
                            ? Image.network(imageFile!.path)
                            : Image.file(File(imageFile!.path)))
                    : Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.pink)),
                        child: Center(
                          child: AspectRatio(
                              aspectRatio:
                                  localVideoController.value.aspectRatio,
                              child: VideoPlayer(localVideoController)),
                        ),
                      ),
              ),
          ],
        ),
      ),
    );
  }

  /// Display the control bar with buttons to take pictures and record videos.
  Widget _captureControlRowWidget() {
    final CameraController? cameraController = controller;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        // IconButton(
        //   icon: Icon(
        //     _isTakingPictures ? Icons.stop : Icons.camera_alt,
        //   ),
        //   color: Colors.blue,
        //   onPressed: cameraController != null &&
        //           cameraController.value.isInitialized &&
        //           !cameraController.value.isRecordingVideo
        //       ? onTakePictureButtonPressed
        //       : null,
        // ),
        ElevatedButton(
          onPressed: cameraController != null &&
                  cameraController.value.isInitialized &&
                  !cameraController.value.isRecordingVideo
              ? onTakePictureButtonPressed
              : null,
          child: Text(
            _isTakingPictures ? 'หยุด' : 'เริ่ม',
            style: GoogleFonts.mitr(),
          ),
        ),
      ],
    );
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void showInSnackBar(String message) {
    // ignore: deprecated_member_use
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void onTakePictureButtonPressed() {
    if (_isTakingPictures) {
      stopTakingPictures(false);
    } else {
      startTakingPictures();
    }
  }

  final AudioPlayer _player = AudioPlayer();
  bool _isUploading = false;
  bool _isPlaying = false;

  void startTakingPictures() {
    int amountImage = 0;
    bool startCalibrate = false;
    int stateNo = 0;

    setState(() {
      _isTakingPictures = true;
    });
    WakelockPlus.toggle(enable: _isTakingPictures);

    void takeAndUploadPicture() async {
      if (_isTakingPictures && !_isUploading) {
        _isUploading = true; // กำลังอัปโหลด

        XFile? file = await takePicture();
        if (file != null && mounted) {
          // ตรวจสอบว่า widget ยังอยู่ใน tree
          imageFile = file;
          amountImage++;
          String startCali = startCalibrate ? 'T' : 'F';
          dataModel = await uploadCalibrate(
            Provider.of<UserAPI>(context, listen: false).user!.id,
            imageFile!,
            startCali,
          );
          if (mounted) {
            // ตรวจสอบอีกครั้งหลังจากการทำ async task
            final dataAnother = dataModel?['dataAnother'];
            stateNo = int.parse(dataAnother?['state_no']?.toString() ?? '0');

            print(dataAnother);
            print('Picture $amountImage uploaded with state $stateNo');
          }
        }
        _isUploading = false; // อนุญาตให้อัปโหลดครั้งต่อไปได้
      }
    }

    Future<void> playCountdownSound() async {
      if (_isPlaying) {
        return; // ถ้าเสียงกำลังเล่นอยู่ ให้รอจนกว่าเสียงจะเล่นจบก่อน
      }
      _isPlaying = true; // ตั้งค่าว่ากำลังเล่นเสียง
      await _player.setAsset('assets/sound/game-countdown-62-199828.mp3');
      await _player.play();

      await Future.delayed(const Duration(seconds: 5)); // รอให้เสียงเล่นจบ
      _player.dispose();
      _isPlaying = false; // ตั้งค่าเมื่อเสียงเล่นจบแล้ว
    }

    _preTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (stateNo == 0) {
        takeAndUploadPicture();
      } else if (stateNo == 1) {
        startCalibrate = true;
        _preTimer?.cancel;
        // เริ่มนับถอยหลังและถ่ายภาพ
        playCountdownSound().then((_) {
          // เมื่อเล่นเสียงครบ ให้เริ่มถ่ายภาพ
          _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
            if (stateNo == 3) {
              stopTakingPictures(true);
              _timer?.cancel();
            } else {
              takeAndUploadPicture();
            }
          });
        });
      }
    });
  }

  void stopTakingPictures(bool finish) async {
    if (mounted) {
      setState(() {
        _isTakingPictures = false;
      });
    }
    WakelockPlus.toggle(enable: _isTakingPictures);

    if (finish) {
      _player.dispose();
      Uint8List imageBytes = await loadImageBytes(imageFile!);
      final dataPoint = dataModel?['dataPoint'];
      final dataAnother = dataModel?['dataAnother'];
      String? isLeft = dataAnother?['is_left'] ?? 'true';
      // Uint8List imageBytes =
      //     base64Decode(dataAnother?['imgStr'].toString() ?? '');
      print(dataPoint);
      Map<String, List<double>> nowPoint = {
        'Ear': List<double>.from(dataPoint?['Ear'] ?? []),
        'Shoulder': List<double>.from(dataPoint?['Shoulder'] ?? []),
        'Elbow': List<double>.from(dataPoint?['Elbow'] ?? []),
        'Hip': List<double>.from(dataPoint?['Hip'] ?? []),
        'Knee': List<double>.from(dataPoint?['Knee'] ?? []),
        'Ankle': List<double>.from(dataPoint?['Ankle'] ?? []),
      };
      print(nowPoint);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AdjustPage(
              imageBytes: imageBytes,
              data: nowPoint,
              isLeft: isLeft == 'true' ? false : true,
            ),
          ),
        );
      }
    } else {
      Navigator.pop(context);
    }

    // finish
    //     ? Navigator.pushReplacement(
    //         context,
    //         MaterialPageRoute(
    //             builder: (context) => AdjustPage(
    //                   imageBytes: imageBytes,
    //                   data: nowPoint,
    //                   isLeft: isLeft == 'true' ? false : true,
    //                   // imgSize: [200.00, 400.00],
    //                 )),
    //       )
    //     : Navigator.pop(context);
    // Navigator.pushNamed(context, '/adjust');
    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(
    //       builder: (context) => AdjustPage(
    //             imageBytes: imageBytes,
    //             data: nowPoint,
    //           )),
    // );
  }

  Future<Uint8List> loadImageBytes(XFile imageFile) async {
    Uint8List bytes = await imageFile.readAsBytes();
    return bytes;
    // ตอนนี้คุณสามารถใช้งานข้อมูล byte นี้ได้แล้ว
  }

  Future<void> onNewCameraSelected(CameraDescription cameraDescription) async {
    final CameraController? oldController = controller;

    if (oldController != null) {
      // `controller` needs to be set to null before getting disposed,
      // to avoid a race condition when we use the controller in
      // `didChangeAppLifecycleState`.
      controller = null;
      await oldController.dispose();
    }

    final CameraController cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.medium,
      enableAudio: enableAudio,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    controller = cameraController;

    // If the controller is updated then update the UI.
    cameraController.addListener(() {
      if (mounted) setState(() {});

      if (cameraController.value.hasError) {
        showInSnackBar(
            'Camera error ${cameraController.value.errorDescription}');
      }
    });

    try {
      await cameraController.initialize();
      await Future.wait(<Future<Object?>>[
        // The exposure mode is currently supported on Android and iOS.
        // Android does not support changing the exposure mode while streaming
        // video.
        // cameraController
        //     .getMinExposureOffset()
        //     .then((double value) => _minAvailableExposureOffset = value),
        // cameraController
        //     .getMaxExposureOffset()
        //     .then((double value) => _maxAvailableExposureOffset = value),
        cameraController
            .getMaxZoomLevel()
            .then((double value) => _maxAvailableZoom = value),
        cameraController
            .getMinZoomLevel()
            .then((double value) => _minAvailableZoom = value),
      ]);
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    if (controller == null) {
      return;
    }

    final CameraController cameraController = controller!;

    final Offset offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );

    cameraController.setExposurePoint(offset);
    cameraController.setFocusPoint(offset);
  }

  Future<void> _initializeCameraController(
      CameraDescription description) async {
    final previousCameraController = controller;
    final CameraController cameraController = CameraController(
      description,
      ResolutionPreset.medium,
      enableAudio: enableAudio,
    );

    // Dispose the previous controller
    await previousCameraController?.dispose();

    if (mounted) {
      setState(() {
        controller = cameraController;
      });
    }

    // Initialize the new controller
    try {
      await cameraController.initialize();
    } on CameraException catch (e) {
      _showCameraException(e);
    }
  }

  void _showCameraException(CameraException e) {
    logError(e.code, e.description);
    // showInSnackBar('Error: ${e.code}\n${e.description}');
  }

  Widget _cameraToggleSwitch() {
    if (_cameras.isEmpty) {
      return const Text('No camera found');
    } else {
      return ElevatedButton(
        child: Text(
          'สลับกล้อง',
          style: GoogleFonts.mitr(),
        ),
        onPressed: () {
          if (controller != null) {
            final currentCamera = controller!.description;
            CameraDescription newCamera;

            if (currentCamera.lensDirection == CameraLensDirection.front) {
              newCamera = _cameras.firstWhere(
                  (camera) => camera.lensDirection == CameraLensDirection.back,
                  orElse: () => _cameras.first);
            } else {
              newCamera = _cameras.firstWhere(
                  (camera) => camera.lensDirection == CameraLensDirection.front,
                  orElse: () => _cameras.first);
            }

            onNewCameraSelected(newCamera);
          }
        },
      );
    }
  }

//   Widget _cameraToggleSwitch() {
//   if (_cameras.isEmpty) {
//     return Text('No camera found', style: GoogleFonts.mitr());
//   } else {
//     // Determine the text for the button based on the current camera
//     final currentCamera = controller?.description;
//     String buttonText = '';

//     if (currentCamera != null) {
//       if (currentCamera.lensDirection == CameraLensDirection.front) {
//         buttonText = 'กล้องหลัง'; // Text for switching to the back camera
//       } else {
//         buttonText = 'กล้องหน้า'; // Text for switching to the front camera
//       }
//     }

//     return ElevatedButton(
//       onPressed: () {
//         if (controller != null) {
//           final CameraDescription newCamera;

//           if (currentCamera?.lensDirection == CameraLensDirection.front) {
//             newCamera = _cameras.firstWhere(
//               (camera) => camera.lensDirection == CameraLensDirection.back,
//               orElse: () => _cameras.first,
//             );
//           } else {
//             newCamera = _cameras.firstWhere(
//               (camera) => camera.lensDirection == CameraLensDirection.front,
//               orElse: () => _cameras.first,
//             );
//           }

//           onNewCameraSelected(newCamera);
//         }
//       },
//       child: Text(
//         buttonText,
//         style: GoogleFonts.mitr(),
//       ),
//     );
//   }
// }

  // Widget _cameraToggleSwitch() {
  //   if (_cameras.isEmpty) {
  //     return Text('No camera found',style: GoogleFonts.mitr(),);
  //   } else {
  //     return IconButton(
  //       icon: Icon(Icons.cameraswitch),
  //       color: Colors.blue,
  //       onPressed: () {
  //         if (controller != null) {
  //           final currentCamera = controller!.description;
  //           CameraDescription newCamera;

  //           if (currentCamera.lensDirection == CameraLensDirection.front) {
  //             newCamera = _cameras.firstWhere(
  //                 (camera) => camera.lensDirection == CameraLensDirection.back,
  //                 orElse: () => _cameras.first);
  //           } else {
  //             newCamera = _cameras.firstWhere(
  //                 (camera) => camera.lensDirection == CameraLensDirection.front,
  //                 orElse: () => _cameras.first);
  //           }

  //           onNewCameraSelected(newCamera);
  //         }
  //       },
  //     );
  //   }
  // }

  Widget _lineSwitch() {
    return ElevatedButton(
        onPressed: () {
          setState(() {
            left = !left;
          });
        },
        child: Text(
          'พลิกแนวนอน',
          style: GoogleFonts.mitr(),
        ));

    // IconButton(
    //   onPressed: () {
    //     setState(() {
    //       right = !right;
    //     });
    //   },
    //   icon: right ? Icon(Icons.switch_left) : Icon(Icons.switch_right),
    //   color: Colors.blue,
    // );
  }

  Future<XFile?> takePicture() async {
    final CameraController? cameraController = controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }

    if (cameraController.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      return await cameraController.takePicture();
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
  }
}

void logError(String code, String? message) {
  print('Error: $code${message == null ? '' : '\nError Message: $message'}');
}
