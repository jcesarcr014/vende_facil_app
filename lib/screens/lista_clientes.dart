import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:vende_facil/widgets/widgets.dart';

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  final clientesProvider = ClienteProvider();
  bool isLoading = false;
  String textLoading = '';
  double windowWidth = 0.0;
  double windowHeight = 0.0;

  @override
  void initState() {
    setState(() {
      textLoading = 'Leyendo clientes';
      isLoading = true;
    });
    clientesProvider.listarClientes().then((value) {
      setState(() {
        textLoading = '';
        isLoading = false;
      });
      if (value.status != 1) {
        Navigator.pop(context);
        mostrarAlerta(context, 'ERROR', value.mensaje!);
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    return PopScope(
      canPop: false,
      onPopInvoked: (didpop) {
        if (!didpop) Navigator.pushReplacementNamed(context, 'menu');
      },
      child: Scaffold(
          appBar: AppBar(
            title: const Text('Clientes'),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
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
                      ]),
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: windowWidth * 0.01),
                  child: Column(
                    children: [
                      SizedBox(
                        height: windowHeight * 0.02,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: windowWidth * 0.05),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, 'nvo-cliente');
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add),
                              SizedBox(
                                width: 5,
                              ),
                              Text('Nuevo cliente'),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: windowHeight * 0.02,
                      ),
                      const Divider(),
                      SizedBox(
                        height: windowHeight * 0.01,
                      ),
                      Column(children: _clientes())
                    ],
                  ),
                )),
    );
  }

  _clientes() {
    List<Widget> clientes = [];
    for (Cliente cliente in listaClientes) {
      clientes.add(
        Column(
          children: [
            ListTile(
              onTap: () {
                if (cliente.nombre != 'Público en general') {
                  Navigator.pushNamed(context, 'nvo-cliente',
                      arguments: cliente);
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Alerta'),
                        content:
                            const Text('No se puede modificar o eliminar".'),
                        actions: <Widget>[
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    cliente.nombre ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.email),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        cliente.correo ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.smartphone),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(cliente.telefono ?? ''),
                    ],
                  )
                ],
              ),
            ),
            const Divider()
          ],
        ),
      );
    }
    if (clientes.isEmpty) {
      final TextTheme textTheme = Theme.of(context).textTheme;

      clientes.add(Column(
        children: [
          const Opacity(
            opacity: 0.2,
            child: Icon(
              Icons.no_accounts,
              size: 130,
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Text(
            'No hay clientes guardados.',
            style: textTheme.titleMedium,
          )
        ],
      ));
    }
    return clientes;
  }
}
