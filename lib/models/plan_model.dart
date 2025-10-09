class PlanSuscripcion {
  int? id;
  String? nombrePlan;
  String? monto;
  String? periodicidad;
  String? divisa;
  int? sucursales;
  int? empleados;
  int? productos;
  int? ventas;
  String? idStripe;



  PlanSuscripcion({
    this.id,
    this.nombrePlan,
    this.monto,
    this.periodicidad,
    this.divisa,
    this.sucursales,
    this.empleados,
    this.productos,
    this.ventas,
    this.idStripe,
  
  });
}
 



List<PlanSuscripcion> listaPlanes = [];
