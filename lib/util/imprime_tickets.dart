import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:intl/intl.dart';

class ImpresionesTickets {
  final respuesta = Resultado();
  TicketModel? datosTicket = TicketModel();
  Negocio? sucursal = Negocio();
  final ticketProvider = TicketProvider();
  final negocioProvider = NegocioProvider();
  String mensajeTicket = '';
  String nombreSucursal = '';
  String direccionSucursal = '';
  String telefonoSucursal = '';
  int cantidadArticulos = 0;

  Future<Resultado> imprimirVenta(VentaCabecera venta) async {
    await obtieneDatosTicket();
    List<int> bytes = [];
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    bytes += generator.reset();
    bytes += generator.text(' $nombreSucursal \n',
        styles: PosStyles(align: PosAlign.center, bold: true));
    bytes += generator.text('Direccion: $direccionSucursal ');
    bytes += generator.text('Telefono: $telefonoSucursal ');
    bytes += generator.text(
        'Fecha compra: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}');
    bytes += generator.text(
        'Hora compra: ${DateFormat('HH-mm-ss').format(DateTime.now())} \n');

    bytes += generator.text('Detalles de venta \n',
        styles: PosStyles(align: PosAlign.left, bold: true));

    for (ItemVenta item in ventaTemporal) {
      if (item.cantidad < 0.5) {
        cantidadArticulos++;
      } else {
        cantidadArticulos += item.cantidad.toInt();
      }

      bytes += generator.row([
        PosColumn(
          text: item.cantidad.toString(),
          width: 2,
          styles: PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: item.articulo,
          width: 7,
          styles: PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: '\$${item.totalItem.toStringAsFixed(2)}',
          width: 3,
          styles: PosStyles(align: PosAlign.right),
        ),
      ]);
    }

    bytes += generator.feed(2);
    bytes += generator.row([
      PosColumn(
        text: 'Total de articulos: ',
        width: 10,
        styles: PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: cantidadArticulos.toString(),
        width: 2,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Subtoal',
        width: 8,
        styles: PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: '\$${venta.subtotal!.toStringAsFixed(2)}',
        width: 4,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'Descuento',
        width: 8,
        styles: PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: '\$${venta.descuento!.toStringAsFixed(2)}',
        width: 4,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'Total',
        width: 8,
        styles: PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: '\$${venta.total!.toStringAsFixed(2)}',
        width: 4,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);
    bytes += generator.feed(1);
    bytes += generator.text('$mensajeTicket ',
        styles: PosStyles(align: PosAlign.center, bold: true));
    bytes += generator.feed(2);

    bool conexionStatus = await PrintBluetoothThermal.connectionStatus;

    if (conexionStatus) {
      bool result = false;

      result = await PrintBluetoothThermal.writeBytes(bytes);
      if (result) {
        respuesta.status = 1;
        respuesta.mensaje = 'Ticket impreso correctamente';
      } else {
        respuesta.status = 0;
        respuesta.mensaje = 'No se pudo imprimir el ticket';
      }
    } else {
      respuesta.status = 0;
      respuesta.mensaje = 'No se pudo conectar a la impresora';
    }
    return respuesta;
  }

  Future<Resultado> imprimirApartado(VentaCabecera venta) async {
    await obtieneDatosTicket();
    List<int> bytes = [];
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    bytes += generator.reset();
    bytes += generator.text(' $nombreSucursal \n',
        styles: PosStyles(align: PosAlign.center, bold: true));
    bytes += generator.text('Direccion: $direccionSucursal ');
    bytes += generator.text('Telefono: $telefonoSucursal ');
    bytes += generator.text(
        'Fecha compra: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}');
    bytes += generator.text(
        'Hora compra: ${DateFormat('HH-mm-ss').format(DateTime.now())} \n');

    bytes += generator.text('Detalles de venta \n',
        styles: PosStyles(align: PosAlign.left, bold: true));

    for (ItemVenta item in ventaTemporal) {
      if (item.cantidad < 0.5) {
        cantidadArticulos++;
      } else {
        cantidadArticulos += item.cantidad.toInt();
      }

      bytes += generator.row([
        PosColumn(
          text: item.cantidad.toString(),
          width: 2,
          styles: PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: item.articulo,
          width: 7,
          styles: PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: '\$${item.totalItem.toStringAsFixed(2)}',
          width: 3,
          styles: PosStyles(align: PosAlign.right),
        ),
      ]);
    }

    bytes += generator.feed(2);
    bytes += generator.row([
      PosColumn(
        text: 'Total de articulos: ',
        width: 10,
        styles: PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: cantidadArticulos.toString(),
        width: 2,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);

    // a partir de aqui cambia por que debe mostrar los que ya tiene mas el anticipo y el faltannte
    
    bytes += generator.row([
      PosColumn(
        text: 'Subtoal',
        width: 8,
        styles: PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: '\$${venta.subtotal!.toStringAsFixed(2)}',
        width: 4,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'Descuento',
        width: 8,
        styles: PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: '\$${venta.descuento!.toStringAsFixed(2)}',
        width: 4,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'Total',
        width: 8,
        styles: PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: '\$${venta.total!.toStringAsFixed(2)}',
        width: 4,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);
    bytes += generator.feed(1);
    bytes += generator.text('$mensajeTicket ',
        styles: PosStyles(align: PosAlign.center, bold: true));
    bytes += generator.feed(2);

    bool conexionStatus = await PrintBluetoothThermal.connectionStatus;

    if (conexionStatus) {
      bool result = false;

      result = await PrintBluetoothThermal.writeBytes(bytes);
      if (result) {
        respuesta.status = 1;
        respuesta.mensaje = 'Ticket impreso correctamente';
      } else {
        respuesta.status = 0;
        respuesta.mensaje = 'No se pudo imprimir el ticket';
      }
    } else {
      respuesta.status = 0;
      respuesta.mensaje = 'No se pudo conectar a la impresora';
    }
    return respuesta;
  }

  Future<void> obtieneDatosTicket() async {
    datosTicket =
        await ticketProvider.getData(sesion.idNegocio.toString(), null);

    sucursal =
        await negocioProvider.consultaSucursal(sesion.idSucursal.toString());
    nombreSucursal = sucursal!.nombreNegocio ?? 'Vendo Facil';
    direccionSucursal = sucursal!.direccion ?? '';
    telefonoSucursal = sucursal!.telefono ?? '';

    mensajeTicket = datosTicket!.message ?? 'Gracias por su compra';
  }
}
