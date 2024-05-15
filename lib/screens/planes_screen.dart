import 'package:flutter/material.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/widgets/widgets.dart'; // Asegúrate de tener el import correcto

class PlanesScreen extends StatefulWidget {
  const PlanesScreen({super.key});

  @override
  State<PlanesScreen> createState() => _PlanesScreenState();
}

class _PlanesScreenState extends State<PlanesScreen> {
  final suscripcionProvider = SuscripcionProvider();
  bool isLoading = false;
  String textLoading = '';

  @override
  void initState() {
    super.initState();
    setState(() {
      textLoading = 'Leyendo planes';
      isLoading = true;
    });
    suscripcionProvider.obtienePlanes().then((value) {
      setState(() {
        textLoading = '';
        isLoading = false;
      });
      if (value.status != 1) {
        Navigator.pop(context);
        mostrarAlerta(
            context, 'ERROR', 'Error al leer los planes. ${value.mensaje}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Planes de suscripción'),
        automaticallyImplyLeading: true,
      ),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  Text(textLoading),
                ],
              ),
            )
          : ListView.builder(
              itemCount: listaPlanes.length,
              itemBuilder: (context, index) {
                PlanSuscripcion plan = listaPlanes[index];
                return PlanCard(
                  plan: plan,
                  onTap: () {
                    // if (!plan.activo!) {
                    //   Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //       builder: (context) =>
                    //           ConfirmarSuscripcionScreen(plan: plan),
                    //     ),
                    //   );
                    // }
                  },
                );
              },
            ),
    );
  }
}
