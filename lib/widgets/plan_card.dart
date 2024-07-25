import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';

class PlanCard extends StatelessWidget {
  final PlanSuscripcion plan;
  final VoidCallback onTap;

  // ignore: use_super_parameters
  const PlanCard({Key? key, required this.plan, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<DetallePlan> planDetalles =
        listaDetalles.where((detalle) => detalle.idPlan == plan.id).toList();


    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4.0,
        margin: const EdgeInsets.all(8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                plan.nombrePlan ?? '',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('Costo: ${plan.monto} ${plan.divisa}'),
              const SizedBox(height: 8),
              const Text('Detalles:'),
              const SizedBox(height: 8),
              ...planDetalles
                  .map((detalle) => Text('- ${detalle.descripcion}'))
                  // ignore: unnecessary_to_list_in_spreads
                  .toList(),
              const SizedBox(height: 8),
              plan.activo == true
                  ? const Icon(Icons.check, color: Colors.green)
                  : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
