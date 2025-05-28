// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:vende_facil/widgets/mostrar_alerta_ok.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:vende_facil/models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      textLoading = 'Cargando datos del ticket';
    });

    final TicketModel? model =
        await ticketProvider.getData(sesion.idNegocio.toString(), null);

    setState(() {
      datosTicket.message = model!.message ?? 'No hay mensaje personalizado';
      isLoading = false;
      textLoading = '';
    });
  }

  _requestPermissions() async {
    setState(() {
      isLoading = true;
      textLoading = 'Validando permisos';
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

    setState(() {
      isLoading = false;
      textLoading = '';
    });

    if (statusNearbyDevices.isGranted &&
        statusBluetoothConnect.isGranted &&
        statusBluetoothScan.isGranted &&
        statusLocation.isGranted) {
      // Permisos concedidos, continuamos
    } else {
      mostrarAlerta(context, 'Atención',
          'Debe otorgar los permisos necesarios para poder imprimir. Vendo Facil es compatible con impresoras de 58 mm.');
    }
  }

  getBluetoots() async {
    setState(() {
      isLoading = true;
      textLoading = 'Buscando dispositivos Bluetooth';
      items = [];
    });

    final List<BluetoothInfo> listResult =
        await PrintBluetoothThermal.pairedBluetooths;

    setState(() {
      isLoading = false;
      textLoading = '';
    });

    if (listResult.isEmpty) {
      _msj =
          "No hay impresoras vinculadas. Por favor, vincule una impresora en la configuración de Bluetooth de su dispositivo.";
    } else {
      _msj = "Seleccione una impresora para conectar:";
    }

    setState(() {
      items = listResult;
    });
  }

  connect(String mac) async {
    setState(() {
      isLoading = true;
      textLoading = "Conectando a la impresora...";
    });

    final bool result =
        await PrintBluetoothThermal.connect(macPrinterAddress: mac);

    if (result) {
      connected = true;
      connectedDeviceMac = mac;
      await SharedPreferences.getInstance().then((prefs) {
        prefs.setString('macPrinter', mac);
      });
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
    setState(() {
      isLoading = true;
      textLoading = "Desconectando...";
    });

    final bool status = await PrintBluetoothThermal.disconnect;

    await SharedPreferences.getInstance().then((prefs) {
      prefs.remove('macPrinter');
    });

    setState(() {
      connected = false;
      isLoading = false;
      textLoading = '';
    });
  }

  Future<void> printTest() async {
    setState(() {
      isLoading = true;
      textLoading = "Imprimiendo ticket de prueba...";
    });

    bool conexionStatus = await PrintBluetoothThermal.connectionStatus;

    if (conexionStatus) {
      bool result = false;
      List<int> ticket = await testTicket();
      result = await PrintBluetoothThermal.writeBytes(ticket);

      setState(() {
        isLoading = false;
        textLoading = '';
      });

      if (result) {
        mostrarAlerta(
            context, 'Éxito', 'Impresión de prueba enviada correctamente');
      } else {
        mostrarAlerta(
            context, 'Error', 'No se pudo enviar la impresión de prueba');
      }
    } else {
      setState(() {
        disconnect();
        isLoading = false;
        textLoading = '';
      });

      mostrarAlerta(context, 'Error',
          'La impresora se ha desconectado. Por favor, conéctela nuevamente.');
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración de Impresora'),
        automaticallyImplyLeading: true,
        elevation: 2,
      ),
      body: isLoading ? _buildLoadingIndicator() : _buildContent(),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Espere... $textLoading',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          const CircularProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildActionsCard(),
          const SizedBox(height: 20),
          _buildDevicesCard(),
        ],
      ),
    );
  }

  Widget _buildActionsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(
              'Acciones de Impresora',
              Icons.print_outlined,
              Colors.blue,
            ),
            const SizedBox(height: 24),
            const Text(
              'Utilice estas opciones para gestionar la conexión con su impresora térmica Bluetooth:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildActionButton(
                  icon: Icons.refresh_outlined,
                  label: 'Actualizar',
                  color: Colors.blue,
                  onPressed: getBluetoots,
                ),
                _buildActionButton(
                  icon: Icons.print_outlined,
                  label: 'Imprimir prueba',
                  color: Colors.green,
                  onPressed: connected ? printTest : null,
                ),
                _buildActionButton(
                  icon: Icons.bluetooth_disabled_outlined,
                  label: 'Desconectar',
                  color: Colors.red,
                  onPressed: connected ? disconnect : null,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildConnectionStatus(),
          ],
        ),
      ),
    );
  }

  Widget _buildDevicesCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(
              'Dispositivos Disponibles',
              Icons.bluetooth_outlined,
              Colors.indigo,
            ),
            const SizedBox(height: 16),
            Text(
              _msj,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            _buildDevicesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionStatus() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: connected
            ? Colors.green.withOpacity(0.1)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: connected ? Colors.green : Colors.grey,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            connected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
            color: connected ? Colors.green : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estado:',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  connected ? 'Conectado' : 'Desconectado',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: connected ? Colors.green : Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          if (connected)
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDevicesList() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bluetooth_searching,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No se encontraron dispositivos',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Verifique que su impresora esté encendida y emparejada',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              itemCount: items.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                BluetoothInfo device = items[index];
                bool isConnected =
                    connected && device.macAdress == connectedDeviceMac;

                return ListTile(
                  onTap: () {
                    String mac = device.macAdress;
                    connect(mac);
                  },
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isConnected
                          ? Colors.green.withOpacity(0.1)
                          : Colors.blue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isConnected ? Icons.print : Icons.bluetooth,
                      color: isConnected ? Colors.green : Colors.blue,
                      size: 24,
                    ),
                  ),
                  title: Text(
                    device.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    "MAC: ${device.macAdress}",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  trailing: isConnected
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green),
                          ),
                          child: const Text(
                            'Conectado',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      : const Icon(Icons.chevron_right),
                );
              },
            ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 16),
          label: Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: onPressed != null ? color : Colors.grey[300],
            foregroundColor:
                onPressed != null ? Colors.white : Colors.grey[600],
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }
}
