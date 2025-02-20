import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:vende_facil/widgets/widgets.dart';

class MenuAbonoScreen extends StatefulWidget {
  const MenuAbonoScreen({super.key});

  @override
  State<MenuAbonoScreen> createState() => _MenuAbonoScreenState();
}

class _MenuAbonoScreenState extends State<MenuAbonoScreen> {
  final apartadoProvider = ApartadoProvider();
  double windowWidth = 0.0;
  double windowHeight = 0.0;
  bool isLoading = false;
  String textLoading = '';
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return PopScope(
      canPop: false,
      onPopInvoked: (didpop) {
        if (!didpop) Navigator.pushReplacementNamed(context, 'menu');
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Menu apartados'),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, 'menu');
                },
                icon: const Icon(Icons.menu)),
          ],
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
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.0),
                child: Column(
                  children: [
                    ListTile(
                        leading: const Icon(Icons.list_alt),
                        title: const Text('Abonar',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                        subtitle: const Text(
                            'Visualiza  lista de apartados pendientes de liquidar'),
                        trailing: const Icon(Icons.arrow_right),
                        onTap: () {
                          if (sesion.tipoUsuario == 'P') {
                            Navigator.pushNamed(context, 'selecionarSA',
                                arguments: 1);
                          } else {
                            setState(() {
                              isLoading = true;
                              textLoading = 'Leyendo movimientos';
                            });

                            apartadoProvider
                                .apartadosPendientesSucursal()
                                .then((resp) {
                              setState(() {
                                isLoading = false;
                                textLoading = '';
                              });
                              if (resp.status == 1) {
                                Navigator.pushNamed(context, 'lista-apartados',
                                    arguments: 1);
                              } else {
                                mostrarAlerta(context, 'ERROR',
                                    'Ocurrio un error ${resp.mensaje}');
                              }
                            });
                          }
                        }),
                    ListTile(
                        leading: const Icon(Icons.list_alt),
                        title: const Text('Entregar productos',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                        subtitle: const Text('Lista de apartados pagados'),
                        trailing: const Icon(Icons.arrow_right),
                        onTap: () {
                          if (sesion.tipoUsuario == 'P') {
                            Navigator.pushNamed(context, 'selecionarSA',
                                arguments: 1);
                          } else {
                            setState(() {
                              isLoading = true;
                              textLoading = 'Leyendo movimientos';
                            });
                            apartadoProvider
                                .apartadosPagadosSucursal()
                                .then((resp) {
                              setState(() {
                                isLoading = false;
                                textLoading = '';
                              });
                              if (resp.status == 1) {
                                Navigator.pushNamed(context, 'lista-apartados',
                                    arguments: 2);
                              } else {
                                mostrarAlerta(context, 'ERROR',
                                    'Ocurrio un error ${resp.mensaje}');
                              }
                            });
                          }
                        }),
                    // if (sesion.tipoUsuario == 'P')
                    //   ListTile(
                    //       leading: const Icon(Icons.check),
                    //       title: const Text(
                    //         'Apartados entregados',
                    //         style: TextStyle(fontWeight: FontWeight.bold),
                    //       ),
                    //       subtitle: const Text('Lista de apartados entregados'),
                    //       trailing: const Icon(Icons.arrow_right),
                    //       onTap: () async {
                    //         final resultado =
                    //             await apartadoProvider.apartadosEntregadosNegocio();
                    //         if (resultado.status != 1) {
                    //           mostrarAlerta(context, 'Error',
                    //               resultado.mensaje ?? 'Intentalo mas tarde');
                    //           return;
                    //         }
                    //         listaClientesApartadosLiquidados.clear();
                    //         for (var apartadoPagado in apartadosPagados) {
                    //           listaClientesApartadosLiquidados.add(
                    //               listaClientes.firstWhere(
                    //                   (cliente) =>
                    //                       cliente.id == apartadoPagado.clienteId,
                    //                   orElse: () => Cliente(
                    //                       id: 0, nombre: 'Publico en general')));
                    //         }
                    //         Navigator.pushNamed(context, 'abonos-liquidados');
                    //       }),
                    // if (sesion.tipoUsuario == 'P')
                    //   ListTile(
                    //       leading: const Icon(Icons.check),
                    //       title: const Text(
                    //         'Apartados cancelados',
                    //         style: TextStyle(fontWeight: FontWeight.bold),
                    //       ),
                    //       subtitle: const Text(
                    //           'Visualiza una lista de tus abonos liquidados'),
                    //       trailing: const Icon(Icons.arrow_right),
                    //       onTap: () async {
                    //         final resultado =
                    //             await apartadoProvider.apartadosPagadosNegocio();
                    //         if (resultado.status != 1) {
                    //           mostrarAlerta(context, 'Error',
                    //               resultado.mensaje ?? 'Intentalo mas tarde');
                    //           return;
                    //         }
                    //         listaClientesApartadosLiquidados.clear();
                    //         for (var apartadoPagado in apartadosPagados) {
                    //           listaClientesApartadosLiquidados.add(
                    //               listaClientes.firstWhere(
                    //                   (cliente) =>
                    //                       cliente.id == apartadoPagado.clienteId,
                    //                   orElse: () => Cliente(
                    //                       id: 0, nombre: 'Publico en general')));
                    //         }
                    //         Navigator.pushNamed(context, 'abonos-liquidados');
                    //       }),
                  ],
                )),
      ),
    );
  }
}
