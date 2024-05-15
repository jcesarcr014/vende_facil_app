import 'package:flutter/material.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/widgets/widgets.dart';

class PlanesScreen extends StatefulWidget {
  const PlanesScreen({super.key});

  @override
  State<PlanesScreen> createState() => _PlanesScreenState();
}

class _PlanesScreenState extends State<PlanesScreen> {
  final suscripcionProvider = SuscripcionProvider();
  bool isLoading = false;
  String textLoading = '';
  double windowWidth = 0.0;
  double windowHeight = 0.0;

  @override
  void initState() {
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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
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
                return ListTile(
                  title: Text(plan.nombrePlan ?? ''),
                  subtitle: Text('${plan.monto} ${plan.divisa}'),
                  trailing: plan.activo == true ? Icon(Icons.check) : null,
                  onTap: () {
                    // Navegar a la pantalla de detalle del plan
                  },
                );
              },
            ),
    );
  }
}
