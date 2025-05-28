import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImpresionesTickets {
  final respuesta = Resultado();
  TicketModel? datosTicket = TicketModel();
  Sucursal? sucursal = Sucursal();
  final ticketProvider = TicketProvider();
  final negocioProvider = NegocioProvider();
  String mensajeTicket = '';
  String nombreSucursal = '';
  String direccionSucursal = '';
  String telefonoSucursal = '';
  int cantidadArticulos = 0;

  Future<Resultado> imprimirCorte(int bandera) async {
    await SharedPreferences.getInstance().then((prefs) async {
      String mac = prefs.getString('macPrinter') ?? '';
      if (mac.isEmpty) {
        respuesta.status = 0;
        respuesta.mensaje = 'No se pudo conectar a la impresora';
        return respuesta;
      } else {
        try {
          await PrintBluetoothThermal.connect(macPrinterAddress: mac);
        } catch (e) {
          respuesta.status = 0;
          respuesta.mensaje = 'No se pudo conectar a la impresora';
          return respuesta;
        }
      }
    });

    (bandera == 1)
        ? await obtieneDatosTicket(sesion.idSucursal.toString())
        : null;
    List<int> bytes = [];
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    bytes += generator.reset();
    (bandera == 1)
        ? bytes += generator.text(' $nombreSucursal \n',
            styles: PosStyles(align: PosAlign.center, bold: true))
        : null;
    (bandera == 1)
        ? bytes += generator.text(' ${sesion.nombreUsuario} \n',
            styles: PosStyles(align: PosAlign.center, bold: true))
        : bytes += generator.text(' ${corteActual.empleado} \n',
            styles: PosStyles(align: PosAlign.center, bold: true));
    bytes += generator.text(
        'Fecha corte: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(corteActual.fecha!))}');
    bytes += generator.text(
        'Hora corte: ${DateFormat('HH-mm-ss').format(DateTime.parse(corteActual.fecha!))} \n');
    bytes +=
        generator.text('Efectivo en caja: ${corteActual.efectivoInicial!} \n');

    bytes += generator.text('Detalles de corte \n',
        styles: PosStyles(align: PosAlign.left, bold: true));

    for (MovimientoCorte item in listaMovimientosCorte) {
      String tipoMov = '';
      switch (item.tipoMovimiento) {
        case 'VT':
          tipoMov = 'Venta tienda';
          break;
        case 'VD':
          tipoMov = 'Venta domicilio';
          break;
        case 'P':
          tipoMov = 'Apartado';
          break;
        case 'A':
          tipoMov = 'Abono';
          break;
        case 'E':
          tipoMov = 'Entraga apartado';
          break;
        default:
          tipoMov = 'Desconocido';
          break;
      }
      bytes += generator.row([
        PosColumn(
          text: tipoMov,
          width: 12,
          styles: PosStyles(align: PosAlign.left),
        ),
      ]);

      bytes += generator.row([
        PosColumn(
          text: '${item.folio}',
          width: 12,
          styles: PosStyles(align: PosAlign.left),
        ),
      ]);

      bytes += generator.row([
        PosColumn(
          text: 'E: \$${item.montoEfectivo}',
          width: 4,
          styles: PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: 'T: \$${item.montoTarjeta}',
          width: 4,
          styles: PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: '\$${item.total}',
          width: 4,
          styles: PosStyles(align: PosAlign.right),
        ),
      ]);
      bytes += generator.feed(1);
    }

    bytes += generator.feed(2);
    bytes += generator.row([
      PosColumn(
        text: 'Total de movimientos: ',
        width: 10,
        styles: PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: corteActual.numVentas.toString(),
        width: 2,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Ventas en Efectivo',
        width: 8,
        styles: PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: '\$${corteActual.ventasEfectivo}',
        width: 4,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'Ventas en Tarjeta',
        width: 8,
        styles: PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: '\$${corteActual.ventasTarjeta}',
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
        text: '\$${corteActual.totalIngresos} \n',
        width: 4,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'Diferencia(${corteActual.tipoDiferencia})',
        width: 8,
        styles: PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text:
            '\$${double.parse(corteActual.diferencia!).abs().toStringAsFixed(2)}',
        width: 4,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.feed(3);

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

  Future<Resultado> imprimirVenta(VentaCabecera venta, double tarjeta,
      double efectivo, double cambio, bool copia) async {
    await SharedPreferences.getInstance().then((prefs) async {
      String mac = prefs.getString('macPrinter') ?? '';
      if (mac.isEmpty) {
        respuesta.status = 0;
        respuesta.mensaje = 'No se pudo conectar a la impresora';
        return respuesta;
      } else {
        try {
          await PrintBluetoothThermal.connect(macPrinterAddress: mac);
        } catch (e) {
          respuesta.status = 0;
          respuesta.mensaje = 'No se pudo conectar a la impresora';
          return respuesta;
        }
      }
    });

    await obtieneDatosTicket(venta.id_sucursal.toString());
    List<int> bytes = [];
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    bytes += generator.reset();
    bytes += generator.text(' $nombreSucursal \n',
        styles: PosStyles(align: PosAlign.center, bold: true));
    bytes += generator.text('$direccionSucursal ',
        styles: PosStyles(align: PosAlign.left, bold: false));
    bytes += generator.text('$telefonoSucursal ',
        styles: PosStyles(align: PosAlign.left, bold: false));
    bytes += generator.row([
      PosColumn(
        text: 'Atendio: ',
        width: 4,
        styles: PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: '${sesion.nombreUsuario}',
        width: 8,
        styles: PosStyles(align: PosAlign.left),
      ),
    ]);
    bytes += generator.feed(1);
    bytes += generator.text('CLIENTE: ${venta.nombreCliente} \n',
        styles: PosStyles(align: PosAlign.left, bold: false));

    bytes += generator.text(
        'Fecha compra: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}');
    bytes += generator
        .text('Hora compra: ${DateFormat('HH:mm:ss').format(DateTime.now())}');
    bytes += generator.text(
        'Tipo compra: ${(venta.tipoVenta == 0) ? 'Tienda' : 'Domicilio'} \n');

    bytes += generator.text('Detalles de la venta \n',
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
        text: 'Artículos vendidos: ',
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
      if (copia) result = await PrintBluetoothThermal.writeBytes(bytes);
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

  Future<Resultado> imprimirApartado(
      ApartadoCabecera apartado,
      double totalAnticipo,
      double totalFaltante,
      double tarjeta,
      double efectivo,
      bool copia) async {
    await SharedPreferences.getInstance().then((prefs) async {
      String mac = prefs.getString('macPrinter') ?? '';
      if (mac.isEmpty) {
        respuesta.status = 0;
        respuesta.mensaje = 'No se pudo conectar a la impresora';
        return respuesta;
      } else {
        try {
          await PrintBluetoothThermal.connect(macPrinterAddress: mac);
        } catch (e) {
          respuesta.status = 0;
          respuesta.mensaje = 'No se pudo conectar a la impresora';
          return respuesta;
        }
      }
    });
    cantidadArticulos = 0;
    await obtieneDatosTicket(sesion.idSucursal.toString());
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
        'Hora compra: ${DateFormat('HH:mm:ss').format(DateTime.now())} \n');

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
    if (copia) {
      conexionStatus = await PrintBluetoothThermal.connectionStatus;
    }
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

  Future<Resultado> imprimirEntregaApartado(
      ApartadoCabecera apartado,
      double totalAnticipo,
      double totalFaltante,
      double tarjeta,
      double efectivo,
      bool copia) async {
    await SharedPreferences.getInstance().then((prefs) async {
      String mac = prefs.getString('macPrinter') ?? '';
      if (mac.isEmpty) {
        respuesta.status = 0;
        respuesta.mensaje = 'No se pudo conectar a la impresora';
        return respuesta;
      } else {
        try {
          await PrintBluetoothThermal.connect(macPrinterAddress: mac);
        } catch (e) {
          respuesta.status = 0;
          respuesta.mensaje = 'No se pudo conectar a la impresora';
          return respuesta;
        }
      }
    });
    cantidadArticulos = 0;
    await obtieneDatosTicket(sesion.idSucursal.toString());
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
        'Hora compra: ${DateFormat('HH:mm:ss').format(DateTime.now())} \n');

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
    if (copia) {
      conexionStatus = await PrintBluetoothThermal.connectionStatus;
    }
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

  Future<Resultado> imprimirAbono(Abono venta, double abono, double tarjeta,
      double efectivo, double total, bool copia) async {
    await SharedPreferences.getInstance().then((prefs) async {
      String mac = prefs.getString('macPrinter') ?? '';
      if (mac.isEmpty) {
        respuesta.status = 0;
        respuesta.mensaje = 'No se pudo conectar a la impresora';
        return respuesta;
      } else {
        try {
          await PrintBluetoothThermal.connect(macPrinterAddress: mac);
        } catch (e) {
          respuesta.status = 0;
          respuesta.mensaje = 'No se pudo conectar a la impresora';
          return respuesta;
        }
      }
    });
    double pendiente = total - abono;
    await obtieneDatosTicket(sesion.idSucursal.toString());
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

    bytes += generator.row([
      PosColumn(
          text: 'Saldo Anterior',
          width: 8,
          styles: PosStyles(align: PosAlign.left)),
      PosColumn(
        text: '\$${total.toStringAsFixed(2)}',
        width: 4,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
          text: 'Abono', width: 8, styles: PosStyles(align: PosAlign.left)),
      PosColumn(
        text: '\$${abono.toStringAsFixed(2)}',
        width: 4,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);
    bytes += generator.feed(2);

    bytes += generator.row([
      PosColumn(
        text: 'Pendiente',
        width: 8,
        styles: PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: '\$${pendiente.toStringAsFixed(2)}',
        width: 4,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.feed(2);
    bytes += generator.row([
      PosColumn(
          text: 'Tarjeta', width: 8, styles: PosStyles(align: PosAlign.left)),
      PosColumn(
        text: '\$${tarjeta.toStringAsFixed(2)}',
        width: 4,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
          text: 'Efectivo', width: 8, styles: PosStyles(align: PosAlign.left)),
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
      if (copia) result = await PrintBluetoothThermal.writeBytes(bytes);
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

  Future<void> obtieneDatosTicket(String idSuc) async {
    datosTicket =
        await ticketProvider.getData(sesion.idNegocio.toString(), null);

    sucursal = await negocioProvider.consultaSucursal(idSuc);
    nombreSucursal = sucursal!.nombreSucursal ?? 'Vendo Facil';
    direccionSucursal = sucursal!.direccion ?? '';
    telefonoSucursal = sucursal!.telefono ?? '';

    mensajeTicket = datosTicket!.message ?? 'Gracias por su compra';
  }

  Future<Resultado> imprimirInventario(
      String idSucursal, List<Producto> productos) async {
    await SharedPreferences.getInstance().then((prefs) async {
      String mac = prefs.getString('macPrinter') ?? '';
      if (mac.isEmpty) {
        respuesta.status = 0;
        respuesta.mensaje = 'No se pudo conectar a la impresora';
        return respuesta;
      } else {
        try {
          await PrintBluetoothThermal.connect(macPrinterAddress: mac);
        } catch (e) {
          respuesta.status = 0;
          respuesta.mensaje = 'No se pudo conectar a la impresora';
          return respuesta;
        }
      }
    });

    await obtieneDatosTicket(idSucursal);
    List<int> bytes = [];
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);

    // Resetear impresora
    bytes += generator.reset();

    // Encabezado
    bytes += generator.text(' $nombreSucursal \n',
        styles: PosStyles(align: PosAlign.center, bold: true));
    bytes += generator.text('Direccion: $direccionSucursal ',
        styles: PosStyles(align: PosAlign.left, bold: false));
    bytes += generator.text('Telefono: $telefonoSucursal ',
        styles: PosStyles(align: PosAlign.left, bold: false));

    // Fecha y hora del reporte
    bytes += generator.text(
        'Fecha reporte: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}');
    bytes += generator.text(
        'Hora reporte: ${DateFormat('HH:mm:ss').format(DateTime.now())} \n');

    // Título del reporte
    bytes += generator.text('REPORTE DE INVENTARIO \n',
        styles: PosStyles(align: PosAlign.center, bold: true));

    // Encabezado de lista de productos
    bytes += generator.text('Productos en inventario: ${productos.length} \n',
        styles: PosStyles(align: PosAlign.left, bold: true));

    // Imprimir cada producto
    for (Producto producto in productos) {
      // Nombre del producto (truncado si es necesario)
      String nombre = producto.producto ?? 'Sin nombre';
      if (nombre.length > 20) {
        nombre = '${nombre.substring(0, 17)}...';
      }

      bytes += generator.text(nombre,
          styles: PosStyles(align: PosAlign.left, bold: true));

      // Clave y código de barras
      if (producto.clave != null && producto.clave!.isNotEmpty) {
        bytes += generator.text('Clave: ${producto.clave}',
            styles: PosStyles(align: PosAlign.left));
      }

      // Cantidades
      bytes += generator.row([
        PosColumn(
          text: 'Cant: ${producto.cantidadInv ?? 0}',
          width: 4,
          styles: PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: 'Apar: ${producto.apartadoInv ?? 0}',
          width: 4,
          styles: PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: 'Disp: ${producto.disponibleInv ?? 0}',
          width: 4,
          styles: PosStyles(align: PosAlign.left),
        ),
      ]);

      // Separador entre productos
      bytes += generator.feed(1);
    }

    // Resumen de inventario
    bytes += generator.feed(1);
    bytes += generator.text('RESUMEN DE INVENTARIO',
        styles: PosStyles(align: PosAlign.center, bold: true));

    // Calcular totales
    int totalCantidad = 0;
    int totalApartado = 0;
    int totalDisponible = 0;

    for (Producto producto in productos) {
      totalCantidad += producto.cantidadInv?.toInt() ?? 0;
      totalApartado += producto.apartadoInv?.toInt() ?? 0;
      totalDisponible += producto.disponibleInv?.toInt() ?? 0;
    }

    bytes += generator.feed(1);
    bytes += generator.row([
      PosColumn(
        text: 'Total Cantidad:',
        width: 6,
        styles: PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: totalCantidad.toString(),
        width: 6,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'Total Apartado:',
        width: 6,
        styles: PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: totalApartado.toString(),
        width: 6,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'Total Disponible:',
        width: 6,
        styles: PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: totalDisponible.toString(),
        width: 6,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);

    // Pie de página
    bytes += generator.feed(1);
    bytes += generator.text('$mensajeTicket',
        styles: PosStyles(align: PosAlign.center, bold: true));
    bytes += generator.text('VENDE FACIL',
        styles: PosStyles(align: PosAlign.center));
    bytes += generator.feed(4); // Espacio para cortar el papel

    // Imprimir
    bool conexionStatus = await PrintBluetoothThermal.connectionStatus;

    if (conexionStatus) {
      bool result = false;

      result = await PrintBluetoothThermal.writeBytes(bytes);

      if (result) {
        respuesta.status = 1;
        respuesta.mensaje = 'Inventario impreso correctamente';
      } else {
        respuesta.status = 0;
        respuesta.mensaje = 'No se pudo imprimir el inventario';
      }
    } else {
      respuesta.status = 0;
      respuesta.mensaje = 'No se pudo conectar a la impresora';
    }

    return respuesta;
  }

  Future<Resultado> imprimirTicketMovimientos(String idSucursal,
      List<MovimientoCorte> movimientos, String fecha) async {
    await SharedPreferences.getInstance().then((prefs) async {
      String mac = prefs.getString('macPrinter') ?? '';
      if (mac.isEmpty) {
        respuesta.status = 0;
        respuesta.mensaje = 'No se pudo conectar a la impresora';
        return respuesta;
      } else {
        try {
          await PrintBluetoothThermal.connect(macPrinterAddress: mac);
        } catch (e) {
          respuesta.status = 0;
          respuesta.mensaje = 'No se pudo conectar a la impresora';
          return respuesta;
        }
      }
    });

    await obtieneDatosTicket(idSucursal);
    List<int> bytes = [];
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);

    // Resetear impresora
    bytes += generator.reset();

    // Encabezado
    bytes += generator.text(' $nombreSucursal \n',
        styles: PosStyles(align: PosAlign.center, bold: true));
    bytes += generator.text('Direccion: $direccionSucursal ',
        styles: PosStyles(align: PosAlign.left, bold: false));
    bytes += generator.text('Telefono: $telefonoSucursal ',
        styles: PosStyles(align: PosAlign.left, bold: false));

    // Fecha del reporte
    bytes += generator.text(
        'Fecha reporte: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(fecha))}');
    bytes += generator.text(
        'Hora impresion: ${DateFormat('HH:mm:ss').format(DateTime.now())} \n');

    // Título del reporte
    bytes += generator.text('REPORTE DE MOVIMIENTOS \n',
        styles: PosStyles(align: PosAlign.center, bold: true));

    // Encabezado de lista de movimientos
    bytes += generator.text('Total movimientos: ${movimientos.length} \n',
        styles: PosStyles(align: PosAlign.left, bold: true));

    // Variables para totales
    double totalEfectivo = 0;
    double totalTarjeta = 0;
    double totalGeneral = 0;

    // Imprimir cada movimiento
    for (MovimientoCorte movimiento in movimientos) {
      // Determinar tipo de movimiento
      String tipoMov = '';
      switch (movimiento.tipoMovimiento) {
        case 'VT':
          tipoMov = 'Venta tienda';
          break;
        case 'VD':
          tipoMov = 'Venta domicilio';
          break;
        case 'P':
          tipoMov = 'Apartado';
          break;
        case 'A':
          tipoMov = 'Abono';
          break;
        case 'E':
          tipoMov = 'Entrega apartado';
          break;
        case 'CV':
          tipoMov = 'Cancelacion venta';
          break;
        case 'CA':
          tipoMov = 'Cancelacion apartado';
          break;
        default:
          tipoMov = 'Desconocido';
          break;
      }

      // Sumar totales
      totalEfectivo += double.parse(movimiento.montoEfectivo ?? '0');
      totalTarjeta += double.parse(movimiento.montoTarjeta ?? '0');
      totalGeneral += double.parse(movimiento.total ?? '0');

      // Imprimir información del movimiento
      bytes += generator.text(tipoMov,
          styles: PosStyles(align: PosAlign.left, bold: true));

      bytes += generator.text('Folio: ${movimiento.folio ?? ''}',
          styles: PosStyles(align: PosAlign.left));

      bytes += generator.text('Hora: ${movimiento.hora ?? ''}',
          styles: PosStyles(align: PosAlign.left));

      // Montos
      bytes += generator.row([
        PosColumn(
          text: 'Efectivo:',
          width: 6,
          styles: PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: '\$${movimiento.montoEfectivo ?? '0.00'}',
          width: 6,
          styles: PosStyles(align: PosAlign.right),
        ),
      ]);

      bytes += generator.row([
        PosColumn(
          text: 'Tarjeta:',
          width: 6,
          styles: PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: '\$${movimiento.montoTarjeta ?? '0.00'}',
          width: 6,
          styles: PosStyles(align: PosAlign.right),
        ),
      ]);

      bytes += generator.row([
        PosColumn(
          text: 'Total:',
          width: 6,
          styles: PosStyles(align: PosAlign.left, bold: true),
        ),
        PosColumn(
          text: '\$${movimiento.total ?? '0.00'}',
          width: 6,
          styles: PosStyles(align: PosAlign.right, bold: true),
        ),
      ]);

      // Separador entre movimientos
      bytes += generator.feed(1);
      bytes += generator.hr();
    }

    // Resumen de totales
    bytes += generator.feed(1);
    bytes += generator.text('RESUMEN DE TOTALES',
        styles: PosStyles(align: PosAlign.center, bold: true));
    bytes += generator.feed(1);

    bytes += generator.row([
      PosColumn(
        text: 'Total Efectivo:',
        width: 6,
        styles: PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: '\$${totalEfectivo.toStringAsFixed(2)}',
        width: 6,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'Total Tarjeta:',
        width: 6,
        styles: PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: '\$${totalTarjeta.toStringAsFixed(2)}',
        width: 6,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'TOTAL GENERAL:',
        width: 6,
        styles: PosStyles(align: PosAlign.left, bold: true),
      ),
      PosColumn(
        text: '\$${totalGeneral.toStringAsFixed(2)}',
        width: 6,
        styles: PosStyles(align: PosAlign.right, bold: true),
      ),
    ]);

    // Pie de página
    bytes += generator.feed(1);
    bytes += generator.text('$mensajeTicket',
        styles: PosStyles(align: PosAlign.center, bold: true));
    bytes += generator.text('VENDE FACIL',
        styles: PosStyles(align: PosAlign.center));
    bytes += generator.feed(4); // Espacio para cortar el papel

    // Imprimir
    bool conexionStatus = await PrintBluetoothThermal.connectionStatus;

    if (conexionStatus) {
      bool result = false;

      result = await PrintBluetoothThermal.writeBytes(bytes);

      if (result) {
        respuesta.status = 1;
        respuesta.mensaje = 'Movimientos impresos correctamente';
      } else {
        respuesta.status = 0;
        respuesta.mensaje = 'No se pudo imprimir los movimientos';
      }
    } else {
      respuesta.status = 0;
      respuesta.mensaje = 'No se pudo conectar a la impresora';
    }

    return respuesta;
  }
}
