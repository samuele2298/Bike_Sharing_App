import 'dart:io';

import 'package:bms_massimo/screens/battery_pairing.dart';
import 'package:bms_massimo/utils/utils.dart';
import 'package:flutter/material.dart';

import '../utils/snackbar.dart';
import 'modify_battery.dart';

class GestioneProduzione extends StatelessWidget {

  Widget buildTitle(BuildContext context) {
    return Text(
      'Gestione Produzione FIVE',
      style: Theme.of(context).primaryTextTheme.titleLarge?.copyWith(color: Colors.white),
    );
  }

  Widget buildAssemblaButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ElevatedButton(
        child: const Text('Assembla Batteria'),
        onPressed: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) {
                  return BatteryPairing();
                }
            ),
          );
        },
      ),
    );
  }

  Widget buildModificaButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ElevatedButton(
        child: const Text('Modifica Batteria'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) {
                  return ModificaBatteria( battery: new Battery(nfcCode: 'nfcCode', macAddress: 'macAddress', batteryCode: 'batteryCode'),);
                }
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      child: Scaffold(
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
              buildAssemblaButton(context),
              buildModificaButton(context),
            ],
          ),
        ),
      ),
    );
  }
}
