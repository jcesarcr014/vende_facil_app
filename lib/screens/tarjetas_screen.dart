import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:vende_facil/app_theme.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:vende_facil/widgets/widgets.dart';
=======
>>>>>>> 19a980dbe31c4065349feb9e1a43bd41ef6772d7

class TarjetaScreen extends StatefulWidget {
  const TarjetaScreen({super.key});

  @override
  State<TarjetaScreen> createState() => _TarjetaScreenState();
}

class _TarjetaScreenState extends State<TarjetaScreen> {
  bool isLoading = false;
  String textLoading = '';
  double windowWidth = 0.0;
  double windowHeight = 0.0;
  int _pagina = 1;
  final controllerTarjeta = TextEditingController();
  final controllerCCV = TextEditingController();
  final controllerTitular = TextEditingController();
  String fechaM = '00';
  String fechaA = '00';

  @override
<<<<<<< HEAD
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Tarjetas Bancarias'),
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
                child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: _lista(),
                ),
              )));
  }

  _lista() {
    List<Widget> listaItems = [];
    if (_pagina == 1) {
      listaItems.clear();
      listaItems.add(const SizedBox(
        height: 10,
      ));
      for (var tarjeta in listatarjetas) {
        listaItems.add(ListTile(
            title: Text('**** **** **** ${tarjeta.digitos}'),
            subtitle: Text('Banco emisor: ${tarjeta.banco}')));
        listaItems.add(const SizedBox(
          height: 30,
        ));
      }
      listaItems.add(ElevatedButton(
          onPressed: () {
            setState(() {
              _pagina = 2;
            });
          },
          child: const Text('Nueva tarjeta')));
    }

    if (_pagina == 2) {
      listaItems.clear();
      listaItems.add(const SizedBox(
        height: 10,
      ));
      listaItems.add(InputField(
          labelText: 'Numero de Tarjeta',
          keyboardType: TextInputType.number,
          controller: controllerTarjeta));

      listaItems.add(const SizedBox(
        height: 30,
      ));
      listaItems.add(const Text(
        'Fecha Vencimiento',
        style: TextStyle(
          color: Color(0xFF2A7BFF),
        ),
      ));
      listaItems.add(const SizedBox(
        height: 10,
      ));
      listaItems.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Row(
          children: [
            _monthExp(),
            const SizedBox(
              width: 30,
            ),
            _yearExp()
          ],
        ),
      ));
      listaItems.add(const SizedBox(
        height: 20,
      ));
      listaItems.add(InputField(
          labelText: 'CCV',
          keyboardType: TextInputType.number,
          controller: controllerCCV));
      listaItems.add(const SizedBox(
        height: 35,
      ));
      listaItems.add(ElevatedButton(
          onPressed: () {
            setState(() {
              _pagina = 1;
            });
          },
          child: const Text('Guardar')));
    }

    return listaItems;
  }

  List<String> meses = [
    '01',
    '02',
    '03',
    '04',
    '05',
    '06',
    '07',
    '08',
    '09',
    '10',
    '11',
    '12'
  ];
  _monthExp() {
    var listaYearVenc = [
      const DropdownMenuItem(value: '00', child: Text('Mes'))
    ];
    for (var mes in meses) {
      listaYearVenc.add(DropdownMenuItem(value: mes, child: Text(mes)));
    }

    if (fechaM.isEmpty) {
      fechaM = '00';
    }
    return DropdownButton(
        value: fechaM,
        items: listaYearVenc,
        onChanged: (value) {
          fechaM = value.toString();

          setState(() {});
        });
  }

  _yearExp() {
    var listaYearVenc = [
      const DropdownMenuItem(value: '00', child: Text('Año'))
    ];
    int currentYear = DateTime.now().year;
    for (var x = currentYear; x < currentYear + 15; x++) {
      listaYearVenc.add(DropdownMenuItem(
          value: x.toString().substring(2),
          child: Text(x.toString().substring(2))));
    }

    if (fechaA.isEmpty) {
      fechaA = '00';
    }
    return DropdownButton(
        value: fechaA,
        items: listaYearVenc,
        onChanged: (value) {
          fechaA = value.toString();

          setState(() {});
        });
=======

  @override
  void initState() {
    super.initState();
>>>>>>> 19a980dbe31c4065349feb9e1a43bd41ef6772d7
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
        automaticallyImplyLeading: false,
        actions: [
          //IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          //IconButton(onPressed: () {}, icon: const Icon(Icons.qr_code_scanner)),
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
                          Text('nuevas targeta'),
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
                ],
              ),
            ),
    );
  }

}

