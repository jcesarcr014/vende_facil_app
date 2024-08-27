class PlanSuscripcion {
  int? id;
  String? monto;
  String? idPlanOp;
  String? nombrePlan;
  String? periodicidad;
  int? sucursales;
  int? empleados;
  String? divisa;
  bool? activo;

  PlanSuscripcion({
    this.id,
    this.monto,
    this.idPlanOp,
    this.nombrePlan,
    this.periodicidad,
    this.sucursales,
    this.empleados,
    this.divisa,
    this.activo,
  });
}

List<PlanSuscripcion> listaPlanes = [];
