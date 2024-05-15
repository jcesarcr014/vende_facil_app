class PlanSuscripcion {
  int? id;
  String? monto;
  String? idPlanOp;
  String? nombrePlan;
  String? periodicidad;
  String? divisa;
  bool? activo;

  PlanSuscripcion({
    this.id,
    this.monto,
    this.idPlanOp,
    this.nombrePlan,
    this.periodicidad,
    this.divisa,
    this.activo,
  });
}

List<PlanSuscripcion> listaPlanes = [];
