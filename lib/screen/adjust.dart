// import 'dart:typed_data';

// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:app_sit/screen/load.dart';
import 'package:app_sit/services/userAPI.dart';
import 'package:app_sit/widget/indicator.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
// import 'package:opencv_dart/opencv_dart.dart' as cv;

class AdjustPage extends StatefulWidget {
  final Uint8List imageBytes;
  final Map<String, List<double>> data;
  // final List<double> imgSize;
  final bool isLeft;
  const AdjustPage(
      {super.key,
      required this.imageBytes,
      required this.data,
      // required this.imgSize,
      required this.isLeft});

  @override
  State<AdjustPage> createState() => _AdjustPageState();
}

Future<void> setNewPoint(
    String id, String imgStr, String newPoint, String isLeft) async {
  const url = 'http://mesb.in.th:8000/set_calibrate/';
  final res = await http.post(Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UtF-8'
      },
      body: jsonEncode(<String, String>{
        'accountID': id,
        'imgStr': imgStr,
        'newPoint': newPoint,
        'is_left': isLeft
      }));

  if (res.statusCode == 200) {
    print('Set New Point Finish\n$newPoint');
  } else {
    print('Error:${res.statusCode}');
  }
}

class PointsLinePainter extends CustomPainter {
  final double headValueX,
      headValueY,
      backValueX,
      backValueY,
      armValueX,
      armValueY,
      legValueX,
      legValueY;
  final Function(Map<String, List<double>>)? onAngleUpdate;
  final double earX,
      earY,
      shoulderX,
      shoulderY,
      elbowX,
      elbowY,
      hipX,
      hipY,
      kneeX,
      kneeY,
      ankleX,
      ankleY;

  PointsLinePainter({
    required this.headValueX,
    required this.headValueY,
    required this.backValueX,
    required this.backValueY,
    required this.armValueX,
    required this.armValueY,
    required this.legValueX,
    required this.legValueY,
    this.onAngleUpdate,
    required this.earX,
    required this.earY,
    required this.shoulderX,
    required this.shoulderY,
    required this.elbowX,
    required this.elbowY,
    required this.hipX,
    required this.hipY,
    required this.kneeX,
    required this.kneeY,
    required this.ankleX,
    required this.ankleY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 4;

    // double earX = 0.38671621680259705;
    // double earY = 0.17606954276561737;
    // double shoulderX = 0.30389082431793213;
    // double shoulderY = 0.29502516984939575;
    // double elbowX = 0.39642563462257385;
    // double elbowY = 0.4462054669857025;
    // double hipX = 0.3572821021080017;
    // double hipY = 0.5594013929367065;
    // double kneeX = 0.7130148410797119;
    // double kneeY = 0.5667864680290222;
    // double ankleX = 0.7089780569076538;
    // double ankleY = 0.7508898377418518;

    // double headNewValueX = earX + headValueX;
    // double headNewValueY = headValueX < 0 ? earY : earY + headValueX;
    // double armNewValueX = elbowX + armValueX;
    // double armNewValueY = elbowY - armValueX;
    // double legNewValueX = ankleX + legValueX;

    // final point = [
    //   Offset(size.width * (headNewValueX + backValueX),
    //       size.height * (headNewValueY)),
    //   Offset(size.width * (shoulderX + backValueX), size.height * (shoulderY)),
    //   Offset(size.width * (armNewValueX + backValueX),
    //       size.height * (armNewValueY)),
    //   Offset(size.width * hipX, size.height * hipY),
    //   Offset(size.width * kneeX, size.height * kneeY),
    //   Offset(size.width * legNewValueX, size.height * ankleY),
    // ];
    double newEarX = earX + headValueX; //+ backValueX;
    double newEarY = earY + headValueY; //+ backValueY;
    double newShoulderX = shoulderX + backValueX;
    double newShoulderY = shoulderY + backValueY;
    double newElbowX = elbowX + armValueX; //+ backValueX;
    double newElbowY = elbowY + armValueY; //+ backValueY;
    double newAnkleX = ankleX + legValueX;
    double newAnkleY = ankleY + legValueY;
    final point = [
      Offset(size.width * (newEarX), size.height * (newEarY)),
      Offset(size.width * (newShoulderX), size.height * (newShoulderY)),
      Offset(size.width * (newElbowX), size.height * (newElbowY)),
      Offset(size.width * hipX, size.height * hipY),
      Offset(size.width * kneeX, size.height * kneeY),
      Offset(size.width * (newAnkleX), size.height * (newAnkleY)),
    ];

    //(backValue - 1) * 0.02
    for (int i = 0; i < 2; i++) {
      canvas.drawLine(point[i], point[i + 1], paint);
    }

    canvas.drawLine(point[1], point[3], paint);

    for (int i = 3; i < point.length - 1; i++) {
      canvas.drawLine(point[i], point[i + 1], paint);
    }

    final pointPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (final point in point) {
      canvas.drawCircle(point, 4.0, pointPaint);
    }

    // Set angle and trigger callback
    Map<String, List<double>> calculatedAngle = setAngle(
        newEarX,
        newEarY,
        newShoulderX,
        newShoulderY,
        newElbowX,
        newElbowY,
        hipX,
        hipY,
        kneeX,
        kneeY,
        newAnkleX,
        newAnkleY);

    if (onAngleUpdate != null) {
      onAngleUpdate!(
          calculatedAngle); // Trigger the callback with the new angle
    }
  }

  @override
  bool shouldRepaint(covariant PointsLinePainter oldDelegate) {
    // Repaint only when slider values change
    return oldDelegate.headValueX != headValueX ||
        oldDelegate.backValueX != backValueX ||
        oldDelegate.armValueX != armValueX ||
        oldDelegate.legValueX != legValueX;
  }

  Map<String, List<double>> setAngle(
      double earX,
      double earY,
      double shoulderX,
      double shoulderY,
      double elbowX,
      double elbowY,
      double hipX,
      double hipY,
      double kneeX,
      double kneeY,
      double ankleX,
      double ankleY) {
    return {
      'Ear': [earX, earY],
      'Shoulder': [shoulderX, shoulderY],
      'Elbow': [elbowX, elbowY],
      'Hip': [hipX, hipY],
      'Knee': [kneeX, kneeY],
      'Ankle': [ankleX, ankleY],
    };
  }
}

class PointsLinePainter1 extends CustomPainter {
  final bool left;
  final double hipX, hipY, kneeX;

  const PointsLinePainter1({
    Key? key,
    required this.left,
    required this.hipX,
    required this.hipY,
    required this.kneeX,
  });
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 4;

    double diffValueXR = 0.7 - hipX;
    double diffValueYR = 0.55 - hipY;
    double diffKneeXR = 0.35 - kneeX;
    // Define the points based on the example image
    final pointRight = [
      Offset(size.width * (0.7 - diffValueXR),
          size.height * (0.17 - diffValueYR)), // head
      Offset(size.width * (0.7 - diffValueXR),
          size.height * (0.4 - diffValueYR)), // shoulder
      // Offset(size.width * 0.48, size.height * 0.4), // arm
      Offset(size.width * hipX, size.height * hipY), // waist
      Offset(size.width * (kneeX), size.height * (0.55 - diffValueYR)), // knee
      Offset(size.width * (0.35 - diffKneeXR),
          size.height * (0.77 - diffValueYR)), // foot
    ];

    double diffValueXL = 0.35 - hipX;
    double diffValueYL = 0.55 - hipY;
    double diffKneeXL = 0.7 - kneeX;
    final pointLeft = [
      Offset(size.width * (0.35 - diffValueXL),
          size.height * (0.17 - diffValueYL)),
      Offset(
          size.width * (0.35 - diffValueXL), size.height * (0.4 - diffValueYL)),
      Offset(size.width * hipX, size.height * hipY),
      Offset(size.width * (kneeX), size.height * (0.55 - diffValueYL)),
      Offset(
          size.width * (0.7 - diffKneeXL), size.height * (0.77 - diffValueYL)),
    ];

    final pointsSquare = [
      Offset(size.width * 0, size.height * 0),
      Offset(size.width * 1, size.height * 0),
      Offset(size.width * 1, size.height * 1),
      Offset(size.width * 0, size.height * 1),
      Offset(size.width * 0, size.height * 0),
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

class _AdjustPageState extends State<AdjustPage> {
  int selectedRadio = 1;
  double _currentValueHeadX = 0;
  double _currentValueHeadY = 0;
  double _currentValueBackX = 0;
  double _currentValueBackY = 0;
  double _currentValueArmX = 0;
  double _currentValueArmY = 0;
  double _currentValueLegX = 0;
  double _currentValueLegY = 0;

  Map<String, List<double>>? newAngle;
  // Map<String, String>? API = {};
  Size? imageSize;
  // Future<void> drawLineWithOpenCV() async {
  //   // โหลดหรือสร้างภาพว่าง ๆ
  //   cv.Mat image =
  //       cv.Mat.eye(500, 500, cv.MatType.CV_8UC3); // สร้างภาพขนาด 500x500

  //   // กำหนดจุดเริ่มต้นและจุดสิ้นสุด
  //   cv.Point start = cv.Point(100, 100);
  //   cv.Point end = cv.Point(400, 400);

  //   // กำหนดสีของเส้น (เช่น สีแดง)
  //   cv.Scalar lineColor = cv.Scalar(0, 0, 255); // รูปแบบ BGR สำหรับสีแดง

  //   // กำหนดความหนาของเส้น
  //   int thickness = 2;

  //   // วาดเส้นลงบนภาพ
  //   cv.line(image, start, end, lineColor, thickness: thickness);

  //   // บันทึกหรือแสดงภาพ
  //   String outputPath = 'output_image.jpg';
  //   await cv.imwrite(outputPath, image);
  //   print('วาดเส้นและบันทึกเป็น $outputPath');
  // }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String? idUser = Provider.of<UserAPI>(context).user?.id;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ปรับค่าอ้างอิง',
          style: GoogleFonts.mitr(fontSize: 30),
        ),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(
                      'คำแนะนำ',
                      style: GoogleFonts.mitr(fontSize: 25),
                    ),
                    content: Text(
                      'เส้นสีแดง คือ เส้นแกนอุดมคติ\nเส้นสีฟ้า คือ เส้นแกนเริ่มต้นที่ไว้ใช้ตรวจจับท่านั่งของผู้ใช้งาน\n\t\t\t\tในหน้านี้ผู้ใช้งานสามารถปรับแกนเริ่มต้นของผู้ใช้งานให้ใกล้เคียงแกนอุดมคติได้ เพื่อพัฒนาท่านั่งให้ใกล้เคียงกับท่านั่งในอุดมคติมากยิ่งขึ้น',
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
            icon: const Icon(Icons.info),
            iconSize: 30,
          )
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(2),
            height: 400,
            child: Stack(children: <Widget>[
              Center(
                  child: SizedBox(
                width: 270, // ความกว้าง
                height: 400, // ความยาว
                child: Image.memory(
                  widget.imageBytes,
                  fit: BoxFit.fill, // เลือกวิธีการแสดงภาพ
                ),
              )),
              Center(
                child: CustomPaint(
                  size: const Size(270, 400), // Fixed size to avoid overflow
                  painter: PointsLinePainter1(
                    left: widget.isLeft,
                    hipX: widget.data['Hip']![0],
                    hipY: widget.data['Hip']![1],
                    kneeX: widget.data['Knee']![0],
                  ),
                ),
              ),
              Center(
                child: CustomPaint(
                  size: const Size(270, 400), // Fixed size to avoid overflow
                  painter: PointsLinePainter(
                    headValueX: _currentValueHeadX,
                    headValueY: _currentValueHeadY,
                    armValueX: _currentValueArmX,
                    armValueY: _currentValueArmY,
                    backValueX: _currentValueBackX,
                    backValueY: _currentValueBackY,
                    legValueX: _currentValueLegX,
                    legValueY: _currentValueLegY,
                    onAngleUpdate: (Map<String, List<double>> updatedAngle) {
                      newAngle = updatedAngle;
                      // print(newAngle);
                    },
                    earX: widget.data['Ear']![0],
                    earY: widget.data['Ear']![1],
                    shoulderX: widget.data['Shoulder']![0],
                    shoulderY: widget.data['Shoulder']![1],
                    elbowX: widget.data['Elbow']![0],
                    elbowY: widget.data['Elbow']![1],
                    hipX: widget.data['Hip']![0],
                    hipY: widget.data['Hip']![1],
                    kneeX: widget.data['Knee']![0],
                    kneeY: widget.data['Knee']![1],
                    ankleX: widget.data['Ankle']![0],
                    ankleY: widget.data['Ankle']![1],
                  ),
                ),
              ),
            ]),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                children: [
                  const Indicator(
                    color: Colors.red,
                    text: '',
                    isSquare: false,
                  ),
                  Text(
                    'แกนอุดมคติ',
                    style: GoogleFonts.mitr(fontSize: 16),
                  ),
                ],
              ),
              Row(
                children: [
                  const Indicator(
                    color: Colors.blue,
                    text: '',
                    isSquare: false,
                  ),
                  Text(
                    'แกนเริ่มต้น',
                    style: GoogleFonts.mitr(fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(child: radio()),
          if (selectedRadio != 0)
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: getSelected(),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (selectedRadio == 1) {
                        _currentValueHeadX = 0;
                        _currentValueHeadY = 0;
                      } else if (selectedRadio == 2) {
                        _currentValueBackX = 0;
                        _currentValueBackY = 0;
                      } else if (selectedRadio == 3) {
                        _currentValueArmX = 0;
                        _currentValueArmY = 0;
                      } else if (selectedRadio == 4) {
                        _currentValueLegX = 0;
                        _currentValueLegY = 0;
                      }
                    });
                  },
                  child: Text(
                    'ค่าเริ่มต้น',
                    style: GoogleFonts.mitr(),
                  )),
              ElevatedButton(
                onPressed: () async {
                  String imageBase64 = base64Encode(widget.imageBytes);
                  await setNewPoint(idUser!, imageBase64, jsonEncode(newAngle),
                      widget.isLeft ? 'false' : 'true');
                  clearData();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => LoadPage(
                              user: Provider.of<UserAPI>(context, listen: false)
                                  .userGoogle!,
                            )),
                    ModalRoute.withName('/load'),
                  );
                },
                child: Text(
                  'เสร็จสิ้น',
                  style: GoogleFonts.mitr(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget radio() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 20.0,
      runSpacing: 10.0,
      children: [
        SizedBox(
          width: 150, // กำหนดความกว้างของคอลัมน์
          child: RadioListTile<int>(
            title: Text(
              'ศีรษะ',
              style: GoogleFonts.mitr(),
            ),
            value: 1,
            groupValue: selectedRadio,
            onChanged: (int? value) {
              setState(() {
                selectedRadio = value!;
              });
            },
          ),
        ),
        SizedBox(
          width: 150,
          child: RadioListTile<int>(
            title: Text(
              'หลัง',
              style: GoogleFonts.mitr(),
            ),
            value: 2,
            groupValue: selectedRadio,
            onChanged: (int? value) {
              setState(() {
                selectedRadio = value!;
              });
            },
          ),
        ),
        SizedBox(
          width: 150,
          child: RadioListTile<int>(
            title: Text(
              'แขน',
              style: GoogleFonts.mitr(),
            ),
            value: 3,
            groupValue: selectedRadio,
            onChanged: (int? value) {
              setState(() {
                selectedRadio = value!;
              });
            },
          ),
        ),
        SizedBox(
          width: 150,
          child: RadioListTile<int>(
            title: Text(
              'ขา',
              style: GoogleFonts.mitr(),
            ),
            value: 4,
            groupValue: selectedRadio,
            onChanged: (int? value) {
              setState(() {
                selectedRadio = value!;
              });
            },
          ),
        ),
      ],
    );
  }

  Future<void> clearData() async {
    Provider.of<UserAPI>(context, listen: false).clearProfileData();
  }

  // Widget getSelectedSlider() {
  //   switch (selectedRadio) {
  //     case 1:
  //       return sliderHead();
  //     case 2:
  //       return sliderBack();
  //     case 3:
  //       return sliderArm();
  //     case 4:
  //       return sliderLeg();
  //     default:
  //       return Container();
  //   }
  // }

  // Widget sliderHead() {
  //   return Slider(
  //     value: _currentSliderValueHead,
  //     label: _currentSliderValueHead.toInt() >= 3 ? '' : '',
  //     min: 0,
  //     max: 6,
  //     divisions: 6,
  //     activeColor: Colors.grey,
  //     thumbColor: Colors.black,
  //     inactiveColor: Colors.grey,
  //     onChanged: (double value) {
  //       setState(() {
  //         _currentSliderValueHead = value;
  //       });
  //     },
  //   );
  // }

  // Widget sliderBack() {
  //   return Slider(
  //     value: _currentSliderValueBack,
  //     label: '${_currentSliderValueBack.toInt()}',
  //     min: 0,
  //     max: 6,
  //     divisions: 6,
  //     activeColor: Colors.grey,
  //     thumbColor: Colors.black,
  //     inactiveColor: Colors.grey,
  //     onChanged: (double value) {
  //       setState(() {
  //         _currentSliderValueBack = value;
  //       });
  //     },
  //   );
  // }

  // Widget sliderArm() {
  //   return Slider(
  //     value: _currentSliderValueArm,
  //     label: '${_currentSliderValueArm.toInt()}',
  //     min: 0,
  //     max: 6,
  //     divisions: 6,
  //     activeColor: Colors.grey,
  //     thumbColor: Colors.black,
  //     inactiveColor: Colors.grey,
  //     onChanged: (double value) {
  //       setState(() {
  //         _currentSliderValueArm = value;
  //       });
  //     },
  //   );
  // }

  // Widget sliderLeg() {
  //   return Slider(
  //     value: _currentSliderValueLeg,
  //     label: '${_currentSliderValueLeg.toInt()}',
  //     min: 0,
  //     max: 6,
  //     divisions: 6,
  //     activeColor: Colors.grey,
  //     thumbColor: Colors.black,
  //     inactiveColor: Colors.grey,
  //     onChanged: (double value) {
  //       setState(() {
  //         _currentSliderValueLeg = value;
  //       });
  //     },
  //   );
  // }

  Widget getSelected() {
    switch (selectedRadio) {
      case 1:
        return selcetHead();
      case 2:
        return selcetBack();
      case 3:
        return selcetArm();
      case 4:
        return selcetLeg();
      default:
        return Container();
    }
  }

  Widget selcetHead() {
    return SizedBox(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          IconButton(
            onPressed: () {
              setState(() {
                _currentValueHeadY = _currentValueHeadY - 0.02;
              });
            },
            icon: const Icon(Icons.keyboard_double_arrow_up),
            iconSize: 35,
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _currentValueHeadY = _currentValueHeadY + 0.02;
              });
            },
            icon: const Icon(Icons.keyboard_double_arrow_down),
            iconSize: 35,
          ),
          IconButton(
            onPressed: () {
              setState(() {
                // if (_currentValueHeadX > -0.16) {
                _currentValueHeadX = _currentValueHeadX - 0.02;
                print(_currentValueHeadX);
                // }
              });
            },
            icon: const Icon(Icons.keyboard_double_arrow_left),
            iconSize: 35,
          ),
          IconButton(
            onPressed: () {
              setState(() {
                // if (_currentValueHeadX < 0.1) {
                _currentValueHeadX = _currentValueHeadX + 0.02;
                print(_currentValueHeadX);
                // }
              });
            },
            icon: const Icon(Icons.keyboard_double_arrow_right),
            iconSize: 35,
          )
        ],
      ),
    );
  }

  Widget selcetBack() {
    return SizedBox(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          IconButton(
            onPressed: () {
              setState(() {
                _currentValueBackY = _currentValueBackY - 0.02;
              });
            },
            icon: const Icon(Icons.keyboard_double_arrow_up),
            iconSize: 35,
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _currentValueBackY = _currentValueBackY + 0.02;
              });
            },
            icon: const Icon(Icons.keyboard_double_arrow_down),
            iconSize: 35,
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _currentValueBackX = _currentValueBackX - 0.02;
              });
            },
            icon: const Icon(Icons.keyboard_double_arrow_left),
            iconSize: 35,
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _currentValueBackX = _currentValueBackX + 0.02;
              });
            },
            icon: const Icon(Icons.keyboard_double_arrow_right),
            iconSize: 35,
          )
        ],
      ),
    );
  }

  Widget selcetArm() {
    return SizedBox(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          IconButton(
            onPressed: () {
              setState(() {
                _currentValueArmY = _currentValueArmY - 0.02;
              });
            },
            icon: const Icon(Icons.keyboard_double_arrow_up),
            iconSize: 35,
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _currentValueArmY = _currentValueArmY + 0.02;
              });
            },
            icon: const Icon(Icons.keyboard_double_arrow_down),
            iconSize: 35,
          ),
          IconButton(
            onPressed: () {
              setState(() {
                // if (_currentValueArmX > -0.04) {
                _currentValueArmX = _currentValueArmX - 0.02;
                // }
              });
            },
            icon: const Icon(Icons.keyboard_double_arrow_left),
            iconSize: 35,
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _currentValueArmX = _currentValueArmX + 0.02;
              });
            },
            icon: const Icon(Icons.keyboard_double_arrow_right),
            iconSize: 35,
          )
        ],
      ),
    );
  }

  Widget selcetLeg() {
    return SizedBox(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          IconButton(
            onPressed: () {
              setState(() {
                _currentValueLegY = _currentValueLegY - 0.02;
              });
            },
            icon: const Icon(Icons.keyboard_double_arrow_up),
            iconSize: 35,
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _currentValueLegY = _currentValueLegY + 0.02;
              });
            },
            icon: const Icon(Icons.keyboard_double_arrow_down),
            iconSize: 35,
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _currentValueLegX = _currentValueLegX - 0.02;
              });
            },
            icon: const Icon(Icons.keyboard_double_arrow_left),
            iconSize: 35,
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _currentValueLegX = _currentValueLegX + 0.02;
              });
            },
            icon: const Icon(Icons.keyboard_double_arrow_right),
            iconSize: 35,
          )
        ],
      ),
    );
  }
}
