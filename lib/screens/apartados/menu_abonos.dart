import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:vende_facil/widgets/widgets.dart';

class MenuAbonoScreen extends StatelessWidget {
  static final apartadoProvider = ApartadoProvider();
  static final clienteProvider = ClienteProvider();

  const MenuAbonoScreen({super.key});

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
          title: const Text('Abonos'),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, 'menu');
                },
                icon: const Icon(Icons.menu)),
          ],
        ),
        body: SingleChildScrollView(
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
                      sesion.tipoUsuario == 'P'
                          ? Navigator.pushNamed(context, 'selecionarSA')
                          : Navigator.pushNamed(context, 'nvo-abono');
                    }),
                if (sesion.tipoUsuario == 'P')
                  ListTile(
                      leading: const Icon(Icons.check),
                      title: const Text(
                        'Abonos Liquidados',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text(
                          'Visualiza una lista de tus abonos liquidados'),
                      trailing: const Icon(Icons.arrow_right),
                      onTap: () async {
                        final resultado =
                            await apartadoProvider.apartadosPagadosNegocio();
                        if (resultado.status != 1) {
                          mostrarAlerta(context, 'Error',
                              resultado.mensaje ?? 'Intentalo mas tarde');
                          return;
                        }
                        listaClientesApartadosLiquidados.clear();
                        for (var apartadoPagado in apartadosPagados) {
                          listaClientesApartadosLiquidados.add(
                              listaClientes.firstWhere(
                                  (cliente) =>
                                      cliente.id == apartadoPagado.clienteId,
                                  orElse: () => Cliente(
                                      id: 0, nombre: 'Publico en general')));
                        }
                        Navigator.pushNamed(context, 'abonos-liquidados');
                      }),
              ],
            )),
      ),
    );
  }
}
