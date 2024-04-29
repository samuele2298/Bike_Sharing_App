import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_scanner_overlay/qr_scanner_overlay.dart';

import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Scanner',
      debugShowCheckedModeBanner: false,
      home: Step1(),
    );
  }
}

class Step1 extends StatefulWidget {
  const Step1({super.key});

  @override
  State<Step1> createState() => _Step1State();
}
class _Step1State extends State<Step1> {
  bool isFlashOn = false;
  bool isFrontCamera = false;
  bool isScanCompleted = false;
  MobileScannerController cameraController = MobileScannerController();

  void closeScreen() {
    setState(() {
      isScanCompleted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber.shade900,
        leading: IconButton(
            style: ButtonStyle(
                iconSize: MaterialStatePropertyAll(30),
                iconColor: MaterialStatePropertyAll(Colors.amber.shade900),
                backgroundColor: MaterialStatePropertyAll(Colors.white70)
            ),
            onPressed: (){},
            icon: Icon(
                Icons.qr_code_scanner
            )
        ),
        centerTitle: true,
        title: Text(
          "Test QR",
          style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold
          ),
        ),
        actions: [
          IconButton(
            onPressed: (){
              setState(() {
                isFlashOn = !isFlashOn;
              });
              cameraController.toggleTorch();
            },
            icon: Icon(
              Icons.flash_on,
              color: isFlashOn ? Colors.white
                  : Colors.black,
            ),
          ),
          IconButton(
              onPressed: (){
                setState(() {
                  isFrontCamera = !isFrontCamera;
                });
                cameraController.switchCamera();
              },
              icon: Icon(
                Icons.flip_camera_android,
                color: isFrontCamera ? Colors.white
                    : Colors.black,
              )
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Text(
                        "Step 1",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 30,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                    Text(
                      "Let the scan do the magic - It starts on its own!",
                      style: TextStyle(
                          color: Colors.black54,
                          fontSize: 16
                      ),
                    )
                  ],
                )
            ),
            SizedBox(
              height: 20,
            ),
            Expanded(
                flex: 2,
                child: Stack(
                  children: [
                    MobileScanner(
                      controller: cameraController,
                      allowDuplicates: false,
                      onDetect: (barcode, args) {
                        if (!isScanCompleted) {
                          isScanCompleted = true;
                          String code = barcode.rawValue ?? "---";
                          closeScreen();

                          if (code.trim() == 'test1') {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) {
                                    return const Step2();
                                  }
                              ),
                            );
                          }else{
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) {
                                    return QRResult(
                                        code: code,
                                        closeScreen: closeScreen,
                                        step: 1
                                    );
                                  }
                              ),
                            );
                          }
                        }
                      },
                    ),
                    QRScannerOverlay(
                      overlayColor: Colors.black26,
                      borderColor: Colors.amber.shade900,
                      borderRadius: 20,
                      borderStrokeWidth: 10,
                      scanAreaWidth: 250,
                      scanAreaHeight: 250,
                    )
                  ],
                )
            ),
            Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "|Scan properly to see results|",
                      style: TextStyle(
                          color: Colors.amber.shade900,
                          fontSize: 20
                      ),
                    ),
                  ],
                )
            ),
          ],
        ),
      ),
    );
  }
}

class Step2 extends StatefulWidget {
  const Step2({super.key});

  @override
  State<Step2> createState() => _Step2State();
}
class _Step2State extends State<Step2> {
  bool isFlashOn = false;
  bool isFrontCamera = false;
  bool isScanCompleted = false;
  MobileScannerController cameraController = MobileScannerController();

  void closeScreen() {
    setState(() {
      isScanCompleted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber.shade900,
        leading: IconButton(
            style: ButtonStyle(
                iconSize: MaterialStatePropertyAll(30),
                iconColor: MaterialStatePropertyAll(Colors.amber.shade900),
                backgroundColor: MaterialStatePropertyAll(Colors.white70)
            ),
            onPressed: (){},
            icon: Icon(
                Icons.qr_code_scanner
            )
        ),
        centerTitle: true,
        title: Text(
          "Test QR",
          style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold
          ),
        ),
        actions: [
          IconButton(
            onPressed: (){
              setState(() {
                isFlashOn = !isFlashOn;
              });
              cameraController.toggleTorch();
            },
            icon: Icon(
              Icons.flash_on,
              color: isFlashOn ? Colors.white
                  : Colors.black,
            ),
          ),
          IconButton(
              onPressed: (){
                setState(() {
                  isFrontCamera = !isFrontCamera;
                });
                cameraController.switchCamera();
              },
              icon: Icon(
                Icons.flip_camera_android,
                color: isFrontCamera ? Colors.white
                    : Colors.black,
              )
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Text(
                        "Step 2",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 30,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                    Text(
                      "Let the scan do the magic - It starts on its own!",
                      style: TextStyle(
                          color: Colors.black54,
                          fontSize: 16
                      ),
                    )
                  ],
                )
            ),
            SizedBox(
              height: 20,
            ),
            Expanded(
                flex: 2,
                child: Stack(
                  children: [
                    MobileScanner(
                      controller: cameraController,
                      allowDuplicates: false,
                      onDetect: (barcode, args) {
                        if (!isScanCompleted) {
                          isScanCompleted = true;
                          String code = barcode.rawValue ?? "---";

                          closeScreen();
                          if (code == 'test2') {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) {
                                    return Step3();
                                  }
                              ),
                            );
                          } else{
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) {
                                    return QRResult(
                                        code: code,
                                        closeScreen: closeScreen,
                                        step: 2
                                    );
                                  }
                              ),
                            );
                          }
                        }
                      },
                    ),
                    QRScannerOverlay(
                      overlayColor: Colors.black26,
                      borderColor: Colors.amber.shade900,
                      borderRadius: 20,
                      borderStrokeWidth: 10,
                      scanAreaWidth: 250,
                      scanAreaHeight: 250,
                    )
                  ],
                )
            ),
            Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "|Scan properly to see results|",
                      style: TextStyle(
                          color: Colors.amber.shade900,
                          fontSize: 20
                      ),
                    ),
                  ],
                )
            ),
          ],
        ),
      ),
    );
  }
}

class Step3 extends StatefulWidget {
  const Step3({super.key});

  @override
  State<Step3> createState() => _Step3State();
}
class _Step3State extends State<Step3> {
  bool isFlashOn = false;
  bool isFrontCamera = false;
  bool isScanCompleted = false;
  MobileScannerController cameraController = MobileScannerController();

  void closeScreen() {
    setState(() {
      isScanCompleted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber.shade900,
        leading: IconButton(
            style: ButtonStyle(
                iconSize: MaterialStatePropertyAll(30),
                iconColor: MaterialStatePropertyAll(Colors.amber.shade900),
                backgroundColor: MaterialStatePropertyAll(Colors.white70)
            ),
            onPressed: (){},
            icon: Icon(
                Icons.qr_code_scanner
            )
        ),
        centerTitle: true,
        title: Text(
          "Test QR",
          style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold
          ),
        ),
        actions: [
          IconButton(
            onPressed: (){
              setState(() {
                isFlashOn = !isFlashOn;
              });
              cameraController.toggleTorch();
            },
            icon: Icon(
              Icons.flash_on,
              color: isFlashOn ? Colors.white
                  : Colors.black,
            ),
          ),
          IconButton(
              onPressed: (){
                setState(() {
                  isFrontCamera = !isFrontCamera;
                });
                cameraController.switchCamera();
              },
              icon: Icon(
                Icons.flip_camera_android,
                color: isFrontCamera ? Colors.white
                    : Colors.black,
              )
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Text(
                        "Step 3",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 30,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                    Text(
                      "Let the scan do the magic - It starts on its own!",
                      style: TextStyle(
                          color: Colors.black54,
                          fontSize: 16
                      ),
                    )
                  ],
                )
            ),
            SizedBox(
              height: 20,
            ),
            Expanded(
                flex: 2,
                child: Stack(
                  children: [
                    MobileScanner(
                      controller: cameraController,
                      allowDuplicates: false,
                      onDetect: (barcode, args) {
                        if (!isScanCompleted) {
                          isScanCompleted = true;
                          String code = barcode.rawValue ?? "---";

                          closeScreen();
                          if (code == 'test3') {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) {
                                    return QRResult(
                                        code: "Hai superato i passaggi",
                                        closeScreen: closeScreen,
                                        step: 3

                                    );
                                  }
                              ),
                            );
                          } else{
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) {
                                    return QRResult(
                                        code: code,
                                        closeScreen: closeScreen,
                                        step: 3
                                    );
                                  }
                              ),
                            );
                          }
                        }
                      },
                    ),
                    QRScannerOverlay(
                      overlayColor: Colors.black26,
                      borderColor: Colors.amber.shade900,
                      borderRadius: 20,
                      borderStrokeWidth: 10,
                      scanAreaWidth: 250,
                      scanAreaHeight: 250,
                    )
                  ],
                )
            ),
            Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "|Scan properly to see results|",
                      style: TextStyle(
                          color: Colors.amber.shade900,
                          fontSize: 20
                      ),
                    ),
                  ],
                )
            ),
          ],
        ),
      ),
    );
  }
}

class QRResult extends StatelessWidget {
  final String code;
  final Function() closeScreen;
  final int step;

  const QRResult({
    super.key,
    required this.code,
    required this.closeScreen,
    required this.step
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber.shade900,
        leading: IconButton(
          onPressed: () {
            if(step == 1){
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) {
                      return Step1();
                    }
                ),
              );
            } else if (step== 2){
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) {
                      return Step2();
                    }
                ),
              );
            }
            else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) {
                      return Step3();
                    }
                ),
              );
            }
          },
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
        ),
        centerTitle: true,
        title: Text(
          "Scanned Result",
          style: TextStyle(
              color: Colors.white,
              fontSize: 35,
              fontWeight: FontWeight.bold
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(60),
        child: Column(
          children: [
            SizedBox(
              height: 120,
            ),
            QrImageView(
              data: "",
              size: 300,
              version: QrVersions.auto,
            ),
            Text(
              "Scanned QR",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 25,
                  fontWeight: FontWeight.bold
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              code,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.black87,
                  fontSize: 20
              ),
            ),
            SizedBox(
              height: 20,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width - 150,
              height: 60,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.shade900
                  ),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: code));
                  },
                  child: Text(
                    "Copy",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 25
                    ),
                  )),
            )
          ],
        ),
      ),
    );
  }
}
