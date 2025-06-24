class PlanSuscripcion {
  int? idSuscripcion;
  int? idPlan;
  int? limiteSucursales;
  int? limiteEmpleados;
  bool unisucursal;

  PlanSuscripcion({
    this.idSuscripcion,
    this.idPlan,
    this.limiteSucursales,
    this.limiteEmpleados,
    required this.unisucursal,
  });
}

PlanSuscripcion suscripcionActual = PlanSuscripcion(unisucursal: true);
