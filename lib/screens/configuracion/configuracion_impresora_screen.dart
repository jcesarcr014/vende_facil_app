import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:vende_facil/widgets/mostrar_alerta_ok.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:vende_facil/models/models.dart';

class ImpresoraScreen extends StatefulWidget {
  const ImpresoraScreen({super.key});

  @override
  State<ImpresoraScreen> createState() => _ImpresoraScreenState();
}

class _ImpresoraScreenState extends State<ImpresoraScreen> {
  final ticketProvider = TicketProvider();
  TicketModel datosTicket = TicketModel();
  bool isLoading = false;
  String textLoading = '';
  List<BluetoothInfo> items = [];
  String _msj = 'Dispositivos disponibles.';
  bool connected = false;
  String connectedDeviceMac = '';

  leeDatosTicket() async {
    setState(() {
      isLoading = true;
      textLoading = 'Cargando datos...';
    });
    final TicketModel? model =
        await ticketProvider.getData(sesion.idNegocio.toString(), null);
    setState(() {
      datosTicket.message = model!.message ?? 'No hay mensaje personalizado';
    });
    setState(() {
      isLoading = false;
      textLoading = '';
    });
  }

  _requestPermissions() async {
    setState(() {
      isLoading = true;
      textLoading = 'Validando permisos...';
    });
    // Solicitar permisos de Bluetooth y ubicación
    var statusNearbyDevices = await Permission.nearbyWifiDevices.status;
    var statusBluetoothConnect = await Permission.bluetoothConnect.status;
    var statusBluetoothScan = await Permission.bluetoothScan.status;
    var statusLocation = await Permission.location.status;

    if (!statusNearbyDevices.isGranted) {
      statusNearbyDevices = await Permission.nearbyWifiDevices.request();
    }

    if (!statusBluetoothConnect.isGranted) {
      statusBluetoothConnect = await Permission.bluetoothConnect.request();
    }

    if (!statusBluetoothScan.isGranted) {
      statusBluetoothScan = await Permission.bluetoothScan.request();
    }

    if (!statusLocation.isGranted) {
      statusLocation = await Permission.location.request();
    }

    bool conexionStatus = await PrintBluetoothThermal.connectionStatus;
    connected = conexionStatus;
    print('Conectado a la impresora:  - $conexionStatus');
    setState(() {
      isLoading = false;
      textLoading = '';
    });
    if (statusNearbyDevices.isGranted &&
        statusBluetoothConnect.isGranted &&
        statusBluetoothScan.isGranted &&
        statusLocation.isGranted) {
    } else {
      print('statusNearbyDevices: $statusNearbyDevices');
      print('statusBluetoothConnect: $statusBluetoothConnect');
      print('statusBluetoothScan: $statusBluetoothScan');
      print('statusLocation: $statusLocation');
      mostrarAlerta(context, 'Atención',
          'Debes otrogar los permisos necesarios para poder imprimir');
    }
  }

  getBluetoots() async {
    setState(() {
      isLoading = true;
      textLoading = 'Buscando dispositivos';
      items = [];
    });

    final List<BluetoothInfo> listResult =
        await PrintBluetoothThermal.pairedBluetooths;

    setState(() {
      isLoading = false;
      textLoading = '';
    });

    if (listResult.length == 0) {
      _msj =
          "No hay impresoras vinculadas, por favor vincula una impresora en la configuración de Bluetooth.";
    } else {
      _msj = "Selecciona una impresora para conectar.";
    }

    setState(() {
      items = listResult;
    });
  }

  connect(String mac) async {
    setState(() {
      isLoading = true;
      textLoading = "Conectando a impresora...";
    });
    final bool result =
        await PrintBluetoothThermal.connect(macPrinterAddress: mac);

    if (result) {
      connected = true;
      connectedDeviceMac = mac;
    } else {
      connected = false;
      connectedDeviceMac = '';
    }

    setState(() {
      isLoading = false;
      textLoading = '';
    });
  }

  Future<void> disconnect() async {
    final bool status = await PrintBluetoothThermal.disconnect;
    setState(() {
      connected = false;
    });
  }

  Future<void> printTest() async {
    bool conexionStatus = await PrintBluetoothThermal.connectionStatus;

    if (conexionStatus) {
      bool result = false;

      List<int> ticket = await testTicket();
      result = await PrintBluetoothThermal.writeBytes(ticket);
    } else {
      setState(() {
        disconnect();
      });
    }
  }

  Future<List<int>> testTicket() async {
    await leeDatosTicket();
    List<int> bytes = [];

    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    bytes += generator.reset();
    bytes += generator.text('VENDO FACIL\n\n',
        styles: PosStyles(align: PosAlign.center, bold: true));
    bytes += generator.text('Prueba de impresion\n\n');
    bytes += generator.text(
        'Regular: aA bB cC dD eE fF gG hH iI jJ kK lL mM nN oO pP qQ rR sS tT uU vV wW xX yY zZ');
    bytes += generator.text('Special 1: ñÑ àÀ èÈ éÉ üÜ çÇ ôÔ');
    bytes += generator.text('Mensaje personalizado: \n');
    bytes += generator.text('${datosTicket.message} \n\n');
    bytes += generator.text('Bold text', styles: PosStyles(bold: true));
    bytes += generator.text('Reverse text', styles: PosStyles(reverse: true));
    bytes += generator.text('Underlined text',
        styles: PosStyles(underline: true), linesAfter: 1);
    bytes +=
        generator.text('Align left', styles: PosStyles(align: PosAlign.left));
    bytes += generator.text('Align center',
        styles: PosStyles(align: PosAlign.center));
    bytes += generator.text('Align right',
        styles: PosStyles(align: PosAlign.right), linesAfter: 1);

    bytes += generator.row([
      PosColumn(
        text: 'col3',
        width: 3,
        styles: PosStyles(align: PosAlign.center, underline: true),
      ),
      PosColumn(
        text: 'col6',
        width: 6,
        styles: PosStyles(align: PosAlign.center, underline: true),
      ),
      PosColumn(
        text: 'col3',
        width: 3,
        styles: PosStyles(align: PosAlign.center, underline: true),
      ),
    ]);
    final List<int> barData = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 4];
    bytes += generator.barcode(Barcode.upcA(barData));
    bytes += generator.qrcode('example.com');
    bytes += generator.text(
      'Text size 100%',
      styles: PosStyles(
        fontType: PosFontType.fontA,
      ),
    );
    bytes += generator.text(
      'Text size 200%',
      styles: PosStyles(
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );

    bytes += generator.feed(2);

    return bytes;
  }

  @override
  void initState() {
    getBluetoots();
    _requestPermissions();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          title: const Text('Configuración de Impresora Bluetooth'),
        ),
        body: isLoading
            ? Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Espere...'),
                      SizedBox(
                        height: screenHeight * 0.01,
                      ),
                      const CircularProgressIndicator(),
                    ]),
              )
            : SingleChildScrollView(
                child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ElevatedButton(
                                onPressed: () {
                                  getBluetoots();
                                },
                                child: Text('Actualizar lista')),
                            ElevatedButton(
                              onPressed: connected ? disconnect : null,
                              child: Text("Desconectar"),
                            ),
                            ElevatedButton(
                              onPressed: connected ? printTest : null,
                              child: Text("Imprimir prueba"),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(_msj),
                        Container(
                            height: screenHeight * 0.5,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              color: Colors.grey.withOpacity(0.3),
                            ),
                            child: ListView.builder(
                              itemCount: items.length > 0 ? items.length : 0,
                              itemBuilder: (context, index) {
                                BluetoothInfo device = items[index];
                                return ListTile(
                                  onTap: () {
                                    String mac = device.macAdress;
                                    connect(mac);
                                  },
                                  trailing: (connected &&
                                          device.macAdress ==
                                              connectedDeviceMac)
                                      ? Icon(Icons
                                          .check) // Muestra el icono solo en el dispositivo conectado
                                      : null,
                                  title: Text('Nombre: ${device.name}'),
                                  subtitle: Text(
                                      "Dirección MAC: ${device.macAdress}"),
                                );
                              },
                            ))
                      ],
                    ))));
  }
}
