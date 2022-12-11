import 'dart:async';
import './main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';




class Pretraga extends StatefulWidget {
  @override
  Pretrazivanje createState() => new Pretrazivanje();
}

class Pretrazivanje extends State<Pretraga> {
  StreamSubscription<BluetoothDiscoveryResult>? streamPretplata;
  List<BluetoothDiscoveryResult> listaRezultata =
  List<BluetoothDiscoveryResult>.empty(growable: true);
  bool trazenjeUTijeku = false;

  Pretrazivanje();

  @override
  void initState() {
    super.initState();

    pretragaUredaja();
  }



  void pretragaUredaja() {
    streamPretplata =
        FlutterBluetoothSerial.instance.startDiscovery().listen((rezultat) {
          setState(() {
            final index = listaRezultata.indexWhere(
                    (element) => element.device.address == rezultat.device.address);
            if (index >= 0)
              listaRezultata[index] = rezultat;
            else
              listaRezultata.add(rezultat);
          });
        });

    streamPretplata!.onDone(() {
      setState(() {
        trazenjeUTijeku = false;
      });
    });
  }
  void ponovnaPretragaUredaja() {
    setState(() {
      listaRezultata.clear();
      trazenjeUTijeku = true;

    });
    pretragaUredaja();

  }

  @override
  void dispose() {
    streamPretplata?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: trazenjeUTijeku
            ? Text('Pretraga uređaja')
            : Text('Bluetooth uređaji'),
        actions: <Widget>[
          trazenjeUTijeku
              ? FittedBox(
            child: Container(
              margin: new EdgeInsets.all(16.0),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          )
              : IconButton(
            icon: Icon(Icons.replay),
            onPressed: ponovnaPretragaUredaja,
          )
        ],
      ),
      body: ListView.builder(
        itemCount: listaRezultata.length,
        itemBuilder: (BuildContext context, index) {
          BluetoothDiscoveryResult result = listaRezultata[index];
          final device = result.device;
          final address = device.address;
          return Uredaj(
            uredaj: device,
            rssi: result.rssi,
            onTap: () async {
              try {
                bool bonded = false;
                if (device.isBonded) {
                  await FlutterBluetoothSerial.instance
                      .removeDeviceBondWithAddress(address);
                } else {
                  bonded = (await FlutterBluetoothSerial.instance
                      .bondDeviceAtAddress(address))!;
                }
                setState(() {
                  listaRezultata[listaRezultata.indexOf(result)] = BluetoothDiscoveryResult(
                      device: BluetoothDevice(
                        name: device.name ?? '',
                        address: address,
                        type: device.type,
                        bondState: bonded
                            ? BluetoothBondState.bonded
                            : BluetoothBondState.none,
                      ),
                      rssi: result.rssi);
                });
              } catch (ex) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Pogreška'),
                      content: Text("${ex.toString()}"),
                      actions: <Widget>[
                        new TextButton(
                          child: new Text("Zatvori"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              }
            },
          );
        },
      ),
    );
  }
}
