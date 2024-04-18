import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:vende_facil/widgets/widgets.dart';

class DescuentosScreen extends StatefulWidget {
  const DescuentosScreen({super.key});

  @override
  State<DescuentosScreen> createState() => _DescuentosScreenState();
}

class _DescuentosScreenState extends State<DescuentosScreen> {
  final descuentosProvider = DescuentoProvider();
  bool isLoading = false;
  String textLoading = '';
  double windowWidth = 0.0;
  double windowHeight = 0.0;

  @override
  void initState() {
    setState(() {
      textLoading = 'Leyendo descuentos';
      isLoading = true;
    });
    descuentosProvider.listarDescuentos().then((value) {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Descuentos'),
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
                    padding:
                        EdgeInsets.symmetric(horizontal: windowWidth * 0.05),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, 'nvo-descuento');
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add),
                          SizedBox(
                            width: 5,
                          ),
                          Text('Nuevo Descuento'),
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
                  Column(
                    children: _descuentos(),
                  )
                ],
              ),
            ),
    );
  }

  _descuentos() {
    List<Widget> descuentos = [];
    for (Descuento descuento in listaDescuentos) {
      descuentos.add(Column(
        children: [
          ListTile(
            onTap: (() => Navigator.pushNamed(context, 'nvo-descuento',
                arguments: descuento)),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(descuento.nombre!),
                Text((descuento.tipoValor == 1)
                    ? '${descuento.valor!.toStringAsFixed(2)} %'
                    : '${descuento.valor!.toStringAsFixed(2)} \$'),
              ],
            ),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tipo'),
                Text((descuento.valorPred == 1)
                    ? 'Variable'
                    : 'Fijo')
              ],
            ),
          )
        ],
      ));
    }
    return descuentos;
  }
}
