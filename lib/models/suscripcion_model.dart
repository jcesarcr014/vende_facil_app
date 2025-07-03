class Suscripcion {
  int? idSuscripcion;
  int? idPlan;
  int? limiteSucursales;
  int? limiteEmpleados;
  bool unisucursal;

  Suscripcion({
    this.idSuscripcion,
    this.idPlan,
    this.limiteSucursales,
    this.limiteEmpleados,
    required this.unisucursal,
  });
}

Suscripcion suscripcionActual = Suscripcion(unisucursal: true);
