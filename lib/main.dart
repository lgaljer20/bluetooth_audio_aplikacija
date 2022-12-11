import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import './pretraga.dart';

class Uredaj extends ListTile {
  Uredaj({
    required BluetoothDevice uredaj,
    int? rssi,
    GestureTapCallback? onTap,
    bool enabled = true,
  }) : super(
    onTap: onTap,
    enabled: enabled,
    title: Text(uredaj.name ?? "Uredaj je bez naziva"),
    subtitle: Text( "Adresa uređaja: " + uredaj.address.toString()),
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        uredaj.isConnected
            ? Icon(Icons.import_export)
            : Container(width: 0, height: 0),
        uredaj.isBonded
            ? Icon(Icons.check)
            : Container(width: 0, height: 0),
      ],
    ),
  );
}

void main() => runApp(new Pocetna());

class Pocetna extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: MainPage());
  }
}

class MainPage extends StatefulWidget {

  @override
  _MainPage createState() => new _MainPage();
}

class _MainPage extends State<MainPage> {

  BluetoothState bluetoothStanje = BluetoothState.UNKNOWN;

  @override
  void initState() {
    super.initState();

    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        bluetoothStanje = state;
      });
    });

    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        bluetoothStanje = state;

      });
    });

  }



  @override
  void dispose() {
    FlutterBluetoothSerial.instance.setPairingRequestHandler(null);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aplikacija za bluetooth povezivanje'),
      ),
      body: Container(
        alignment: Alignment.topCenter,
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Divider(),
            SwitchListTile(
              title:  bluetoothStanje.isEnabled ? Text('Ugasi bluetooth') : Text("Upali bluetooth"),
              value: bluetoothStanje.isEnabled,
              onChanged: (bool value) {
                future() async {
                  if (value)
                    await FlutterBluetoothSerial.instance.requestEnable();
                  else
                    await FlutterBluetoothSerial.instance.requestDisable();
                }
                future().then((_) {
                  setState(() {});
                });
              },
              //secondary: bluetoothStanje.isEnabled ? Text('Ugasi bluetooth') : Text('Upali bluetooth'),
            ),
            ListTile(
              title: ElevatedButton(
                  child: const Text('Pretraži bluetooth uređaje'),
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return Pretraga();
                        },
                      ),
                    );
                  }),
            ),

          ],
        ),
      ),
    );
  }
}


