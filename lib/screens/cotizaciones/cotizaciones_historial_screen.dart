// ignore_for_file: unnecessary_import

import 'package:flutter/material.dart';
import 'package:vende_facil/models/cuenta_sesion_modelo.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:vende_facil/widgets/widgets.dart';

class HistorialCotizacionesScreen extends StatefulWidget {
  const HistorialCotizacionesScreen({
    super.key,
  });

  @override
  State<HistorialCotizacionesScreen> createState() =>
      _HistorialCotizacionesScreenState();
}

class _HistorialCotizacionesScreenState
    extends State<HistorialCotizacionesScreen> {
  final cotizaciones = CotizarProvider();
  bool isLoading = false;
  String textLoading = '';

  @override
  void initState() {
    setState(() {
      isLoading = true;
      textLoading = 'Cargando cotizaciones';
    });

    if (sesion.tipoUsuario == 'P') {
      cotizaciones.cotizacionesNegocio(sesion.idNegocio!).then((resp) {
        setState(() {
          isLoading = false;
          textLoading = '';
        });
      });
    } else {
      cotizaciones.cotizacionesSucursal(sesion.idSucursal!).then((resp) {
        setState(() {
          isLoading = false;
          textLoading = '';
        });
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final windowWidth = MediaQuery.of(context).size.width;
    final windowHeight = MediaQuery.of(context).size.height;
    return PopScope(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Historial de Cotizaciones'),
          automaticallyImplyLeading: true,
        ),
        body: (isLoading)
            ? Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Espere...$textLoading'),
                      SizedBox(
                        height: windowHeight * 0.01,
                      ),
                      const CircularProgressIndicator(),
                    ]),
              )
            : Padding(
                padding: EdgeInsets.symmetric(horizontal: windowWidth * 0.04),
                child: SingleChildScrollView(
                  child: _listaCotizaciones(),
                ),
              ),
      ),
    );
  }

  _listaCotizaciones() {
    if (listacotizacion.isEmpty) {
      return const Center(
        child: Text(
            'No hay cotizaciones realizadas en el rango de fechas seleccionado.'),
      );
    } else {
      return Column(
        children: listacotizacion.map((cotizar) {
          return ListTile(
            title: Text(cotizar.folio!),
            subtitle: Text('Cliente: ${cotizar.nombreCliente!}'),
            trailing: Text('\$${cotizar.subtotal}'),
            onTap: () {
              setState(() {
                isLoading = true;
                textLoading = 'Cargando detalles';
              });
              cotizaciones.cotizacionDetalle(cotizar.id!).then((resp) {
                setState(() {
                  isLoading = false;
                  textLoading = '';
                });
                if (resp.status == 1) {
                  Navigator.pushNamed(context, 'detalleCotizacions');
                } else {
                  mostrarAlerta(
                      context, 'ERROR', 'Ocurrio un error: ${resp.mensaje}');
                }
              });
            },
          );
        }).toList(),
      );
    }
  }
}
