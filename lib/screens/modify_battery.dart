import 'dart:async';
import 'dart:io';

import 'package:bms_massimo/screens/bluetooth_off_screen.dart';
import 'package:bms_massimo/utils/extra.dart';
import 'package:bms_massimo/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../utils/snackbar.dart';
import 'gestione_produzione.dart';

class ModificaBatteria extends StatefulWidget {
  final Battery battery;

  ModificaBatteria({
    required this.battery,
  });

  @override
  State<ModificaBatteria> createState() => _ModificaBatteriaState();
}

class _ModificaBatteriaState extends State<ModificaBatteria> {

  final String targetDevice = 'Batteria1';

  //Comandi
  final TargetCommand command1 = TargetCommand(
    service: 'Service1',
    characteristic: 'Char1',
    message: '1x322'
  );
  final TargetCommand command2 = TargetCommand(
      service: 'Service2',
      characteristic: 'Char2',
      descriptor: 'Desc2',
      message: '1x332'
  );
  final TargetCommand command3 = TargetCommand(
      service: 'Service3',
      characteristic: 'Char2',
      message: '1x232'
  );
  final TargetCommand command4 = TargetCommand(
      service: 'Service4',
      characteristic: 'Char4',
      descriptor: 'Desc4',
      message: '1x8332'
  );

  //Stato del BLE sul dispositivo
  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;
  late StreamSubscription<BluetoothAdapterState> _adapterStateStateSubscription;


  List<BluetoothDevice> _systemDevices = [];
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;
  bool _isFinded = false;
  bool _isDiscoveringServices = false;

  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;
  late StreamSubscription<bool> _isScanningSubscription;

  BluetoothDevice? device;

  @override
  void initState() {
    super.initState();

    _adapterStateStateSubscription = FlutterBluePlus.adapterState.listen((state) {
      _adapterState = state;
      if (mounted) {
        setState(() {});
      }
    });

    _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
      _scanResults = results;
      if (mounted) {
        setState(() {});
      }
    }, onError: (e) {
      Snackbar.show(ABC.c, prettyException("Scan Error:", e), success: false);
    });

    _isScanningSubscription = FlutterBluePlus.isScanning.listen((state) {
      _isScanning = state;
      if (mounted) {
        setState(() {});
      }
    });


  }

  @override
  void dispose() {
    _adapterStateStateSubscription.cancel();
    _scanResultsSubscription.cancel();
    _isScanningSubscription.cancel();
    super.dispose();
  }

  List<int> convertHexStringToBytes(String hexString) {
    List<int> bytes = [];
    for (int i = 0; i < hexString.length; i += 2) {
      String hex = hexString.substring(i, i + 2);
      bytes.add(int.parse(hex, radix: 16));
    }
    return bytes;
  }


  //Funzione che cerca in background il dispositivo
  Future launchScanning() async {
    try {
      _systemDevices = await FlutterBluePlus.systemDevices;
    } catch (e) {
      Snackbar.show(ABC.c, prettyException("System Devices Error:", e), success: false);
    }
    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
    } catch (e) {
      Snackbar.show(ABC.c, prettyException("Start Scan Error:", e), success: false);
    }
    if (mounted) {
      setState(() {});
    }

    Future.delayed(Duration(milliseconds: 100));

    FlutterBluePlus.stopScan();

    try {
      device = _systemDevices.firstWhere((element) => element.name == targetDevice);

      if(device != null){
        setState(() {
          this.device = device;
          _isFinded = true;

          device!.connectAndUpdateStream().catchError((e) {
            Snackbar.show(ABC.c, prettyException("Connect Error:", e), success: false);
          });

        });
      }
    } catch (e) {
      // If device is not found, display an error message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Dispositivo non trovato: $e"),
          );
        },
      );
    }
  }

  Future<bool> launchCharacteristicCommand(TargetCommand tc) async {
    List<BluetoothService> _services = [];
    List<BluetoothCharacteristic> _characteristics = [];

    try {
      if(device!= null){
        _services = await device!.discoverServices();
        Snackbar.show(ABC.c, "Discover Services: Success", success: true);

        BluetoothCharacteristic _characteristic;

        _characteristics = _services.firstWhere((element) => element.serviceUuid == tc.service).characteristics;
        _characteristic = _characteristics.firstWhere((element) => element.serviceUuid == tc.characteristic);

        writeCharacteristic(_characteristic, tc.message);
        return true;

      } return false;

    } catch (e) {
      Snackbar.show(ABC.c, prettyException("Discover Services Error:", e), success: false);
      // If device is not found, display an error message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Dispositivo non trovato: $e"),
          );
        },
      );
      return false;

    }






  }
  Future<bool> launchDescriptorCommand(TargetCommand tc) async {
    List<BluetoothService> _services = [];
    List<BluetoothCharacteristic> _characteristics = [];

    try {
      if (device != null){
        _services = await device!.discoverServices();
        Snackbar.show(ABC.c, "Discover Services: Success", success: true);

        List<BluetoothDescriptor> _descriptors = [];
        BluetoothDescriptor _descriptor;

        _characteristics = _services.firstWhere((element) => element.serviceUuid == tc.service).characteristics;
        _descriptors = _characteristics.firstWhere((element) => element.serviceUuid == tc.characteristic).descriptors;
        _descriptor = _descriptors.firstWhere((element) => element.serviceUuid == tc.descriptor);

        setState(() {
          _isFinded = true;
        });

        writeDescriptor(_descriptor, tc.message);

        return true;
      }
      return false;

    } catch (e) {
      Snackbar.show(ABC.c, prettyException("Discover Services Error:", e), success: false);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Dispositivo non trovato: $e"),
          );
        },
      );
      return false;
    }

  }

  Future writeCharacteristic(BluetoothCharacteristic c, String hexString) async {
    try {
      List<int> bytes = convertHexStringToBytes(hexString);
      await c.write(bytes, withoutResponse: c.properties.writeWithoutResponse);
      Snackbar.show(ABC.c, "Write: Success", success: true);
      if (c.properties.read) {
        await c.read();
      }
    } catch (e) {
      Snackbar.show(ABC.c, prettyException("Write Error:", e), success: false);
    }
  }
  Future writeDescriptor(BluetoothDescriptor d,  String hexString) async {
    try {
      List<int> bytes = convertHexStringToBytes(hexString);
      await d.write(bytes);
      Snackbar.show(ABC.c, "Descriptor Write : Success", success: true);
    } catch (e) {
      Snackbar.show(ABC.c, prettyException("Descriptor Write Error:", e), success: false);
    }
  }

  Widget buildTitle(BuildContext context) {
    return Column(
      children: [
        Text(
          'Modifica Batteria',
          style: Theme.of(context).primaryTextTheme.titleLarge?.copyWith(color: Colors.white),
        ),
        device!= null?
          Text(
            'Dispositivo: ${device!.advName}',
            style: Theme.of(context).primaryTextTheme.titleSmall?.copyWith(color: Colors.white),
          )
          : Text('')
      ],
    );
  }

  Widget buildInfo(BuildContext context) {
    return Column(
      children: [
        Text(
          'NFC: ${widget.battery.nfcCode}',
          style: Theme.of(context).primaryTextTheme.titleLarge?.copyWith(color: Colors.white),
        ),
        SizedBox(height: 20,),
        Text(
          'MAC: ${widget.battery.macAddress}',
          style: Theme.of(context).primaryTextTheme.titleLarge?.copyWith(color: Colors.white),
        ),
        SizedBox(height: 20,),
        Text(
          'Codice: ${widget.battery.batteryCode}',
          style: Theme.of(context).primaryTextTheme.titleLarge?.copyWith(color: Colors.white),
        ),

      ],
    );
  }

  //Bottoni Ble
  Widget buildModificaPaccoButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(5),
      child: ElevatedButton(
          child: Text("Modifica Pacco"),
          style: ButtonStyle(
            textStyle: MaterialStateProperty.all<TextStyle>(
              TextStyle(color: Colors.white), // Imposta il colore del testo su bianco
            ),
          ),
          onPressed: ()  {
          }),
    );
  }

  Widget buildSetParametriButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(5),

      child: ElevatedButton(
          child: Text("Set Parametri"),
          style: ButtonStyle(
            textStyle: MaterialStateProperty.all<TextStyle>(
              TextStyle(color: Colors.white), // Imposta il colore del testo su bianco
            ),
          ),
          onPressed: ()  {
            command1.hasDescriptor()?
              launchCharacteristicCommand(command1)
              :launchDescriptorCommand(command1);
          }),
    );
  }

  Widget buildInitButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(5),

      child: ElevatedButton(
          child: Text("Init"),
          style: ButtonStyle(
            textStyle: MaterialStateProperty.all<TextStyle>(
              TextStyle(color: Colors.white), // Imposta il colore del testo su bianco
            ),
          ),
          onPressed: ()  {
            command2.hasDescriptor()?
              launchCharacteristicCommand(command2)
              :launchDescriptorCommand(command2);
          }),
    );
  }

  Widget buildFreezeButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(5),

      child: ElevatedButton(
          child: Text("Freeze"),
          style: ButtonStyle(
            textStyle: MaterialStateProperty.all<TextStyle>(
              TextStyle(color: Colors.white), // Imposta il colore del testo su bianco
            ),
          ),
          onPressed: ()  {
            command3.hasDescriptor()?
              launchCharacteristicCommand(command3)
              :launchDescriptorCommand(command3);
          }),
    );
  }

  Widget buildDefreezeButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(5),
      child: ElevatedButton(
          child: Text("Defreeze"),
          style: ButtonStyle(
            textStyle: MaterialStateProperty.all<TextStyle>(
              TextStyle(color: Colors.white), // Imposta il colore del testo su bianco
            ),
          ),
          onPressed: ()  {
            command4.hasDescriptor()?
              launchCharacteristicCommand(command4)
              :launchDescriptorCommand(command4);
            }
          ),
    );
  }

  Widget _buildButtonColumn(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        buildModificaPaccoButton(context),
        buildSetParametriButton(context),
        buildInitButton(context),
        buildFreezeButton(context),
        buildDefreezeButton(context),
      ],
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    return ElevatedButton(
        child: Text("Annulla"),
        style: ButtonStyle(
          textStyle: MaterialStateProperty.all<TextStyle>(
            TextStyle(color: Colors.white), // Imposta il colore del testo su bianco
          ),
        ),
        onPressed: ()  {
          MaterialPageRoute(
              builder: (context) {
                return GestioneProduzione();
              }
          );
        }
    );
  }

  Widget _buildRetryButton(BuildContext context) {
    return ElevatedButton(
        child: Text("Riprova"),
        style: ButtonStyle(
          textStyle: MaterialStateProperty.all<TextStyle>(
            TextStyle(color: Colors.white), // Imposta il colore del testo su bianco
          ),
        ),
        onPressed: ()  {
          launchScanning();
        }
    );
  }


  @override
  Widget build(BuildContext context) {
    return _adapterState == BluetoothAdapterState.on?
      ScaffoldMessenger(
        key: Snackbar.snackBarKeyModifyBattery,
        child:  _isFinded?
          Scaffold(
          backgroundColor: Colors.lightBlue,
          appBar: AppBar(
            backgroundColor: Colors.transparent ,
            title: buildTitle(context),
            centerTitle: true,
            iconTheme: IconThemeData(color: Colors.white), // Imposta il colore della freccia di navigazione su bianco

          ),
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                buildInfo(context),
                SizedBox(height: 50,),
                _buildButtonColumn(context),
                SizedBox(height: 50,),
                _buildCancelButton(context)
              ],
            ),
          ),
        )
          :Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent ,
            title: buildTitle(context),
            centerTitle: true,
            iconTheme: IconThemeData(color: Colors.white), // Imposta il colore della freccia di navigazione su bianco

          ),
          backgroundColor: Colors.lightBlue,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Text(
                  'Dispositivo non trovato',
                  style: Theme.of(context).primaryTextTheme.titleLarge?.copyWith(color: Colors.white),
                ),
                _buildRetryButton(context),
              ],
            ),
          ),
        ),
      )
    : BluetoothOffScreen();
  }
}


