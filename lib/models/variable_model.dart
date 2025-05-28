class VariableConf {
  int id;
  String nombre;
  String valor;

  VariableConf({required this.id, required this.nombre, required this.valor});

  static void asignarVariablesGlobales(List<VariableConf> listaVariables) {
    varAplicaApartado = false;
    varPorcentajeAnticipo = 0.0;
    varProductosApartado = 0;
    varAplicaMayoreo = false;
    varProductosMayoreo = 0;
    varEmpleadoInventario = false;
    varEmpleadoCorte = false;
    varAplicaInventario = false;

    for (var variable in listaVariables) {
      switch (variable.nombre) {
        case 'aplica_apartado':
          varAplicaApartado = variable.valor == '1';
          break;
        case 'porcentaje_anticipo':
          varPorcentajeAnticipo = double.tryParse(variable.valor) ?? 0.0;
          break;
        case 'productos_apartados':
          varProductosApartado = int.tryParse(variable.valor) ?? 0;
          break;
        case 'aplica_mayoreo':
          varAplicaMayoreo = variable.valor == '1';
          break;
        case 'productos_mayoreo':
          varProductosMayoreo = int.tryParse(variable.valor) ?? 0;
          break;
        case 'empleado_cantidades':
          varEmpleadoInventario = variable.valor == '1';
          break;
        case 'empleado_corte':
          varEmpleadoCorte = variable.valor == '1';
          break;
        case 'aplica_iventario':
          varAplicaInventario = variable.valor == '1';
          break;
      }
    }
  }
}

List<VariableConf> listaVariables = [];
bool varAplicaApartado = false;
double varPorcentajeAnticipo = 0.0;
int varProductosApartado = 0;
bool varAplicaMayoreo = false;
int varProductosMayoreo = 0;
bool varEmpleadoInventario = false;
bool varEmpleadoCorte = false;
bool varAplicaInventario = false;
