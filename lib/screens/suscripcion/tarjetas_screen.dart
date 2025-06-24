import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';

class TarjetaScreen extends StatefulWidget {
  const TarjetaScreen({super.key});

  @override
  State<TarjetaScreen> createState() => _TarjetaScreenState();
}

class _TarjetaScreenState extends State<TarjetaScreen> {
  // final suscripcionProvider = SuscripcionProvider();
  int idTarjeta = 0;
  bool isLoading = false;
  String textLoading = '';
  double windowWidth = 0.0;
  double windowHeight = 0.0;

  // ignore: unused_element
  _alertaEliminar() {
    return AlertDialog(
      title: const Text('Eliminar tarjeta'),
      content: const Text('¿Está seguro de eliminar la tarjeta?'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            _eliminarTarjeta();
          },
          child: const Text('Aceptar'),
        ),
      ],
    );
  }

  _eliminarTarjeta() {
    setState(() {
      isLoading = true;
      textLoading = 'Eliminando tarjeta...';
    });
    // suscripcionProvider.eliminarTarjeta(idTarjeta).then((value) {
    //   setState(() {
    //     isLoading = false;
    //     textLoading = '';
    //   });
    //   if (value.status == 1) {
    //     Navigator.pop(context);
    //     mostrarAlerta(context, 'OK', value.mensaje!);
    //   } else {
    //     mostrarAlerta(context, 'Error', 'Error: ${value.mensaje}');
    //   }
    // });
  }

  @override
  void initState() {
    setState(() {
      isLoading = true;
      textLoading = 'Cargando tarjetas...';
    });
    // suscripcionProvider.listarTarjetas().then((value) {
    //   setState(() {
    //     isLoading = false;
    //     textLoading = '';
    //   });
    //   if (value.status != 1) {
    //     mostrarAlerta(context, 'Error', 'Error: ${value.mensaje}');
    //   }
    // });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis tarjetas'),
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
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: windowWidth * 0.0),
              child: Column(
                children: [
                  SizedBox(
                    height: windowHeight * 0.02,
                  ),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: windowWidth * 0.07),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, 'nvo-tarjetas');
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add),
                          SizedBox(
                            width: 5,
                          ),
                          Text('Agregar tarjeta bancaria'),
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
                  Column(children: _tarjetas())
                ],
              ),
            ),
    );
  }

  _tarjetas() {
    List<Widget> lista = [];
    if (listaTarjetas.isNotEmpty) {
      for (var tarjeta in listaTarjetas) {
        lista.add(
          ListTile(
            title: Text('XXXX-XXXX-XXXX-${tarjeta.numero}'),
            trailing: IconButton(
              onPressed: () {
                setState(() {
                  idTarjeta = tarjeta.id!;
                });
              },
              icon: const Icon(Icons.delete),
            ),
          ),
        );
      }
    } else {
      final TextTheme textTheme = Theme.of(context).textTheme;
      lista.add(Column(
        children: [
          const Opacity(
            opacity: 0.2,
            child: Icon(
              Icons.credit_card,
              size: 130,
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Text(
            'No hay tarjetas guardadas.',
            style: textTheme.titleMedium,
          )
        ],
      ));
    }
    return lista;
  }
}
