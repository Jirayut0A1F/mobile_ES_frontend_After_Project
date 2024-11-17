import 'dart:convert';
import 'package:app_sit/models/setting_data.dart';
import 'package:app_sit/models/user_data.dart';
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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:http/http.dart' as http;

class CameraDetect extends StatefulWidget {
  final List<CameraDescription> cameras;

  const CameraDetect({super.key, required this.cameras});

  @override
  State<CameraDetect> createState() => _CameraDetectState();
}

Future<List?> uploadImage(XFile? imageFile, String id, String urlIP) async {
  final url = '$urlIP/process_detect/';
  if (imageFile != null) {
    Uint8List bytes = await imageFile.readAsBytes();
    String imageBase64 = base64Encode(bytes);
    final res = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UtF-8',
      },
      body: jsonEncode(<String, String>{
        'accountID': id,
        'imgStr': imageBase64,
      }),
    );
    print('id:$id');
    if (res.statusCode == 200) {
      print(res.body);
      final data = jsonDecode(res.body);
      print('${data['data'].runtimeType}');
      List detect = data['data'];
      return detect;
    } else {
      print('Failed to upload Image');
      return null;
    }
  }
  return null;
}

Future<void> stopDetect(String id, String urlIP) async {
  final url = '$urlIP/end_detect/';
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

class _CameraDetectState extends State<CameraDetect>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  CameraController? controller;
  XFile? imageFile;
  XFile? videoFile;
  VideoPlayerController? videoController;
  VoidCallback? videoPlayerListener;
  bool enableAudio = true;
  bool _enableSound = true;
  // double _minAvailableExposureOffset = 0.0;
  // double _maxAvailableExposureOffset = 0.0;
  // double _currentExposureOffset = 0.0;
  late AnimationController _flashModeControlRowAnimationController;
  // late Animation<double> _flashModeControlRowAnimation;
  late AnimationController _exposureModeControlRowAnimationController;
  // late Animation<double> _exposureModeControlRowAnimation;
  late AnimationController _focusModeControlRowAnimationController;
  // late Animation<double> _focusModeControlRowAnimation;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _currentScale = 1.0;
  double _baseScale = 1.0;

  // Counting pointers (number of user fingers on screen)
  int _pointers = 0;
  late List<CameraDescription> _cameras;

  // Timer to take picture every 5 seconds
  Timer? _timer;
  bool _isTakingPictures = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _cameras = widget.cameras;

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

    // Select the first front camera
    if (_cameras.isNotEmpty) {
      onNewCameraSelected(_cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras.first,
      ));
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _flashModeControlRowAnimationController.dispose();
    _exposureModeControlRowAnimationController.dispose();
    _focusModeControlRowAnimationController.dispose();
    _timer?.cancel();
    // WakelockPlus.disable();
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
      ),
      body: Consumer<UserAPI>(builder: (context, userAPI, child) {
        UserData user = userAPI.user!;
        SettingData setting = userAPI.setting!;
        String id = user.id;
        int detectFreq = setting.selectedDetectFreq ??= 5;
        return Column(
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
            _captureControlRowWidget(detectFreq, id),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _cameraToggleSwitch(),
                  // _thumbnailWidget(),
                ],
              ),
            ),
          ],
        );
      }),
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
  Widget _captureControlRowWidget(int detectFreq, String id) {
    final CameraController? cameraController = controller;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        ElevatedButton(
          onPressed: () {
            cameraController != null &&
                    cameraController.value.isInitialized &&
                    !cameraController.value.isRecordingVideo
                ? onTakePictureButtonPressed(detectFreq, id)
                : null;
          },
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

  void onTakePictureButtonPressed(int detectFreq, String id) {
    if (_isTakingPictures) {
      stopTakingPictures(id);
    } else {
      startTakingPictures(detectFreq, id);
    }
  }

  Future<void> _captureAndProcessImage(String id) async {
    try {
      XFile? file = await takePicture();
      if (file != null) {
        imageFile = file;
        List? stateName = await uploadImage(
            imageFile, id, Provider.of<UserAPI>(context, listen: false).urlIP!);
        imageFile = null;
        await _loadSoundSetting();
        if (_enableSound) {
          checkAndNotify(stateName, id);
        }
        print('Subsequent state detected: $stateName');
      }
    } catch (e) {
      print('Error capturing or processing image: $e');
      // Optionally handle the error, e.g., retry logic or user notification
    }
  }

  void startTakingPictures(int detectFreq, String id) {
    setState(() {
      _isTakingPictures = true;
    });
    _captureAndProcessImage(id);

    _timer = Timer.periodic(Duration(seconds: detectFreq), (timer) {
      if (_isTakingPictures) {
        WakelockPlus.toggle(enable: _isTakingPictures);
        _captureAndProcessImage(id);
      }
    });
  }

  Future<void> _loadSoundSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _enableSound = prefs.getBool('enableSound') ?? true;
  }

  void checkAndNotify(List<dynamic>? stateName, String id) async {
    while (_isPlaying) {
      await Future.delayed(
          const Duration(milliseconds: 100)); // รอ 100 ms ก่อนตรวจสอบอีกครั้ง
    }

    _isPlaying = true;
    bool alarm = false;

    if (stateName != null) {
      // จัดลำดับให้ 'outSitLimit' อยู่ข้างหน้า
      if (stateName.contains('outSitLimit')) {
        stateName.sort((a, b) {
          if (a == 'outSitLimit') return -1;
          if (b == 'outSitLimit') return 1;
          return 0;
        });
      }

      for (String item in stateName) {
        if (!_isTakingPictures) break; // หยุดลูปทันทีหากการถ่ายภาพถูกหยุด

        alarm = false;
        print('Found target: $item');

        // สร้าง AudioPlayer ใหม่ในแต่ละรอบ
        AudioPlayer player = AudioPlayer();

        if (item == 'User not found' && !stateName.contains('outSitLimit')) {
          await player.setAsset('assets/sound/User-not-found.mp3');
          await _playAndDispose(player);
        } else if (item == 'Time Out') {
          stopTakingPictures(id);
          // _showTimeoutMessage(id);
        } else if (item == 'outSitLimit') {
          await player.setAsset('assets/sound/outSitLimit.mp3');
          await _playAndDispose(player);
        } else {
          switch (item) {
            case 'head':
            case 'arm':
            case 'back':
            case 'leg':
              alarm = true;
              await player.setAsset('assets/sound/$item.mp3');
              await _playAndDispose(player);
              break;
          }
        }
      }

      if (alarm) {
        AudioPlayer player = AudioPlayer();
        await player.setAsset('assets/sound/wrong.mp3');
        await _playAndDispose(player);
        alarm = false;
      }
    }

    _isPlaying = false;
  }

// ฟังก์ชันช่วยสำหรับการเล่นและกำจัด AudioPlayer หลังจากเสร็จสิ้นการเล่น
  Future<void> _playAndDispose(AudioPlayer player) async {
    player.play();
    await player.processingStateStream
        .firstWhere((state) => state == ProcessingState.completed);
    await player.dispose();
  }

  void stopTakingPictures(String id) {
    _isTakingPictures = false;
    WakelockPlus.toggle(enable: _isTakingPictures);
    WakelockPlus.disable();
    // WakelockPlus.disable();
    stopDetect(id, Provider.of<UserAPI>(context, listen: false).urlIP!);
    _timer?.cancel();
    Navigator.pop(context);
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
    showInSnackBar('Error: ${e.code}\n${e.description}');
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
