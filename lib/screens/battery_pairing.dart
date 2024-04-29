import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/snackbar.dart';
import '../utils/utils.dart';
import 'package:bms_massimo/screens/modify_battery.dart';

import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_scanner_overlay/qr_scanner_overlay.dart';

import 'package:nfc_manager/nfc_manager.dart';

class BatteryPairing extends StatefulWidget {

  @override
  State<BatteryPairing> createState() => _BatteryPairingState();
}
class _BatteryPairingState extends State<BatteryPairing> {

  //Battery param
  late String nfcCode;
  late String macAddress;
  late String batteryCode;

  //Current Step
  int _currentStep = 0;

  //NFC Searching
  bool nfcIsSearching = true;

  //NFC Result
  ValueNotifier<dynamic> result = ValueNotifier(null);

  //QR Param
  bool isFlashOn = false;
  bool isFrontCamera = false;
  bool isScanCompleted = false;
  MobileScannerController cameraController = MobileScannerController();

  //Battery code
  TextEditingController batteryCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();

    result.addListener(() {
      checkNFCValue(result.value);
    });
  }

  //Check the NFC value
  void checkNFCValue(String value) {
    if (value.isNotEmpty && value != null) {
      setState(() {
        nfcCode = value;
        _currentStep ++;
      });
    }
  }

  //Check the QR code value
  void checkQRCodeValue(String value) {
    if (value.isNotEmpty && value != null) {
      setState(() {
        macAddress = value;
      });
    }
  }

  //Check the battery code value
  void checkBCodeValue(String value) {
    if (value.isNotEmpty && value != null) {
      setState(() {
        batteryCode = value;
      });
    }
  }

  //QR close QR searcher
  void closeScreen() {
    setState(() {
      isScanCompleted = false;
    });
  }

  //NFC scanning
  void _scanningNFCTag() {
    try {
      NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
        result.value = tag.data;
        NfcManager.instance.stopSession();
      });
      Timer(Duration(seconds: 15), () {
        if (result.value == null) {
          setState(() {
            // Visualizza il pulsante per riprovare
          });
        }
      });
    } on Exception catch (e) {
      Snackbar.show(
          ABC.b, prettyException("NFC search Error:", e), success: false);
    }
  }

  //Verifica finale da fare se i 3 valore insieme coincidono
  bool verify(){
    return true;
  }

  //Funzione per lanciare al db il nuovo dispositivo
  Future insertToDBNewBattery() async {
    return true;
  }


  bool isNumeric(String value) {
    if (value == null) {
      return false;
    }
    return double.tryParse(value) != null;
  }


  Widget buildTitle(BuildContext context) {
    return Text(
      'Assembla Batteria',
      style: Theme
          .of(context)
          .primaryTextTheme
          .titleLarge
          ?.copyWith(color: Colors.white),
    );
  }

  //Stepper
  Widget buildStepper(BuildContext context) {
    return Stepper(
      type: StepperType.horizontal,
      currentStep: _currentStep,
      elevation: 0,

      controlsBuilder: (BuildContext context, ControlsDetails details) {
        return Row(
          children: [
            TextButton(
                onPressed: () {},
                child: Text('')
            ),
            TextButton(
                onPressed: () {},
                child: Text('')
            )
          ],
        ); // Restituisce un widget vuoto per nascondere i pulsanti incorporati
      },

      steps: <Step>[
        Step(
          title: Text('Step 1'),
          content: Container(
            color: Colors.red,
            alignment: Alignment.center,
            child: buildFirstStep(context),
          ),
        ),
        Step(
          title: Text('Step 2'),
          content: Container(
            color: Colors.green,

            alignment: Alignment.center,
            child: buildSecondStep(context),
          ),
        ),
        Step(
          title: Text('Step 3'),
          content: Container(
            color: Colors.purple,

            alignment: Alignment.center,
            child: buildThirdStep(context),
          ),
        ),
      ],
    );
  }

  //First Step NFC
  Widget buildFirstStep(BuildContext context) {
    _scanningNFCTag();

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        SizedBox(height: 50,),
        FutureBuilder<bool>(
          future: NfcManager.instance.isAvailable(),
          builder: (context, ss) =>
            ss.data != true
              ? Center(
                child: Text(
                  'NFC is not Available',
                  style: Theme
                      .of(context)
                      .primaryTextTheme
                      .titleLarge
                      ?.copyWith(color: Colors.white),

                )
              )
            : ValueListenableBuilder<dynamic>(
                valueListenable: result,
                builder: (context, value, child) {
                  if (value == null && nfcIsSearching) {
                    return CircularProgressIndicator();
                  } else if (value == null && !nfcIsSearching) {
                    return Center(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            nfcIsSearching = true;
                            result.value = null;
                            _scanningNFCTag();
                          });
                        },
                        child: Center(child: Text('Riprova')),
                      ),
                    );
                  } else {
                    return Text('Dispositivo: ${value.toString()}');
                  }
                },
            ),

        ),
        SizedBox(height: 50,),
        Icon(
          Icons.nfc,
          size: 150,
          color: Colors.white,
        ),
        SizedBox(height: 50,),

      ],
    );
  }

  //Second Step QR
  Widget buildSecondStep(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(

        children: [
          SizedBox(height: 20,),
          Text(
            'Inquadra il codice a barre',
            style: Theme
                .of(context)
                .primaryTextTheme
                .titleLarge
                ?.copyWith(color: Colors.white),
          ),
          SizedBox(height: 50,),

          SizedBox(
            width: double.infinity,
            height: 300,
            child: Stack(
              children: [
                MobileScanner(
                  controller: cameraController,
                  allowDuplicates: false,
                  onDetect: (barcode, args) {
                    if (!isScanCompleted) {
                      String code = barcode.rawValue ?? "---";
                      isScanCompleted = true;
                      closeScreen();

                      if (code.trim().isNotEmpty && code != null) {
                        checkQRCodeValue(code.trim());
                        setState(() {
                          _currentStep++;
                        });
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
            ),
          ),
        ],
      ),
    );
  }

  //Third Step Code
  Widget buildThirdStep(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: TextFormField(
            controller: batteryCodeController,
            decoration: InputDecoration(
              labelText: 'Inserisci il codice batteria',
              labelStyle: TextStyle(color: Colors.white),
              errorStyle: TextStyle(color: Colors.red),
              counterStyle: TextStyle(color: Colors.white),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white), // Colore del bordo quando il campo non è in focus
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white), // Colore del bordo quando il campo è in focus
              ),
            ),
            style: TextStyle(color: Colors.white),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Il campo è richiesto';
              } else if (value.length != 10) {
                return 'Il codice batteria deve essere lungo 10 caratteri';
              } else if (!isNumeric(value)) {
                return 'Il codice batteria deve contenere solo numeri';
              }
              return null;
            },
            cursorColor: Colors.white,
            keyboardType: TextInputType.number,
            maxLength: 10,
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
          ),
        ),
      ],
    );
  }

  //Bottoms Buttons
  Widget _buildBottomButtons(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ElevatedButton(
              child: Text("Indietro"),
              style: ButtonStyle(
                textStyle: MaterialStateProperty.all<TextStyle>(
                  TextStyle(color: Colors
                      .white), // Imposta il colore del testo su bianco
                ),
              ),
              onPressed: () {
                setState(() {
                  _currentStep --;
                });
              }
          ),
          ElevatedButton(
              child: Text("Avanti"),
              style: ButtonStyle(
                textStyle: MaterialStateProperty.all<TextStyle>(
                  TextStyle(color: Colors
                      .white), // Imposta il colore del testo su bianco
                ),
              ),
              onPressed: () {
                setState(() {
                  _currentStep ++;
                });
                if (!verify()) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) {
                          return ModificaBatteria(battery: new Battery(
                              nfcCode: 'nfcCode',
                              macAddress: 'macAddress',
                              batteryCode: 'batteryCode'),);
                        }
                    ),
                  );
                }
              }
          ),
          _currentStep == 2 ?
            ElevatedButton(
              child: Text("Ultimo Avanti"),
              style: ButtonStyle(
                textStyle: MaterialStateProperty.all<TextStyle>(
                  TextStyle(color: Colors
                      .white), // Imposta il colore del testo su bianco
                ),
              ),
              onPressed: () {
                //Controllo battery code e salvo
                checkBCodeValue(batteryCodeController.text);

                if (verify()) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) {
                          return ModificaBatteria(battery: new Battery(
                              nfcCode: nfcCode,
                              macAddress: macAddress,
                              batteryCode: batteryCode),);
                        }
                    ),
                  );
                }
              }
          )
            : SizedBox(width: 50,)
        ],
      );
  }


  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: Snackbar.snackBarKeyBatteryPairing,
      child: Scaffold(
        backgroundColor: Colors.lightBlue,
        appBar: AppBar(
          backgroundColor: Colors.transparent ,
          title: buildTitle(context),
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white), // Imposta il colore della freccia di navigazione su bianco

        ),
        body: Column(
          children: [
            Expanded(child: buildStepper(context)),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: _buildBottomButtons(context)

      ),
    );

  }
}

