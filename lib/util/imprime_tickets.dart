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

  Future<Resultado> imprimirVenta(VentaCabecera venta, double tarjeta, double efectivo, double cambio) async {
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
        text: 'Subtotal',
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

    bytes += generator.feed(2);
    bytes += generator.row([
      PosColumn(
        text: 'Tarjeta',
        width: 8,
        styles: PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: '\$${tarjeta.toStringAsFixed(2)}',
        width: 4,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Efectivo',
        width: 8,
        styles: PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: '\$${efectivo.toStringAsFixed(2)}',
        width: 4,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Cambio',
        width: 8,
        styles: PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: '\$${cambio.toStringAsFixed(2)}',
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

  Future<Resultado> imprimirApartado(ApartadoDetalle apartado, double totalAnticipo, double totalFaltante, double tarjeta, double efectivo) async {
    cantidadArticulos = 0;
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

    bytes += generator.text('Detalles de Apartado \n',
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
        text: 'Subtotal',
        width: 8,
        styles: PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: '\$${apartado.subtotal!.toStringAsFixed(2)}',
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
        text: '\$${apartado.descuento!.toStringAsFixed(2)}',
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
        text: '\$${apartado.total!.toStringAsFixed(2)}',
        width: 4,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);
    bytes += generator.feed(2);

    bytes += generator.row([
      PosColumn(
        text: 'Anticipo',
        width: 8,
        styles: PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: '\$${apartado.total!.toStringAsFixed(2)}',
        width: 4,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'Faltante',
        width: 8,
        styles: PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: '\$${totalFaltante.toStringAsFixed(2)}',
        width: 4,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.feed(2);
    bytes += generator.row([
      PosColumn(
        text: 'Tarjeta',
        width: 8,
        styles: PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: '\$${tarjeta.toStringAsFixed(2)}',
        width: 4,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Efectivo',
        width: 8,
        styles: PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: '\$${efectivo.toStringAsFixed(2)}',
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

  Future<Resultado> imprimirAbono(Abono venta, double abono, double tarjeta, double efectivo, double total) async {
    double pendiente = total - abono;
    await obtieneDatosTicket();
    List<int> bytes = [];
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    bytes += generator.reset();
    bytes += generator.text(' $nombreSucursal \n', styles: PosStyles(align: PosAlign.center, bold: true));
    bytes += generator.text('Direccion: $direccionSucursal ');
    bytes += generator.text('Telefono: $telefonoSucursal ');
    bytes += generator.text('Fecha compra: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}');
    bytes += generator.text('Hora compra: ${DateFormat('HH-mm-ss').format(DateTime.now())} \n');

    bytes += generator.row([
      PosColumn(text: 'Saldo Anterior', width: 8, styles: PosStyles(align: PosAlign.left)),
      PosColumn(
        text: '\$${total.toStringAsFixed(2)}',
        width: 4,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.row([
      PosColumn(text: 'Abono', width: 8, styles: PosStyles(align: PosAlign.left)),
      PosColumn(
        text: '\$${abono.toStringAsFixed(2)}',
        width: 4,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);
    bytes += generator.feed(2);

    bytes += generator.row([
      PosColumn(text: 'Pendiente', width: 8, styles: PosStyles(align: PosAlign.left),),
      PosColumn(
        text: '\$${pendiente.toStringAsFixed(2)}',
        width: 4,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.feed(2);
    bytes += generator.row([
      PosColumn(text: 'Tarjeta', width: 8, styles: PosStyles(align: PosAlign.left)),
      PosColumn(
        text: '\$${tarjeta.toStringAsFixed(2)}',
        width: 4,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(text: 'Efectivo', width: 8, styles: PosStyles(align: PosAlign.left)),
      PosColumn(
        text: '\$${efectivo.toStringAsFixed(2)}',
        width: 4,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.feed(1);
    bytes += generator.text('$mensajeTicket ', styles: PosStyles(align: PosAlign.center, bold: true));
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
