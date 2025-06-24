import 'package:vende_facil/models/models.dart';

class LimpiaDatos {
  limpiaDatos() {
    // Listas
    listaAbonos.clear();
    listaApartadosPendientes.clear();
    listaApartadosPagados.clear();
    listaApartadosEntregados.clear();
    listaApartadosCancelados.clear();
    detalleApartado.clear();
    listaCategorias.clear();
    listaClientes.clear();
    listaClientesApartadosLiquidados.clear();
    listaCortes.clear();
    detalleCotActual.clear();
    listacotizacion.clear();
    listaDescuentos.clear();
    listaDetalles.clear();
    detallesSuscripcion.clear();
    ventaTemporal.clear();
    cotizarTemporal.clear();
    listaMovimientosCorte.clear();
    // listaPlanes.clear();
    listaProductos.clear();
    listaProductosCotizaciones.clear();
    listaProductosSucursal.clear();
    listasucursalEmpleado.clear();
    listaSucursales.clear();
    listaTarjetas.clear();
    listaEmpleados.clear();
    listaUsuarios.clear();
    listaVariables.clear();
    listaVentaCabecera.clear();
    listaVentaCabecera2.clear();
    listaVentas.clear();
    listaVentadetalles.clear();
    listaVentasDia.clear();
    // Variables
    abonoSeleccionado = Abono();
    apartadoSeleccionado = ApartadoCabecera();
    corteActual = Corte();
    sesion = CuentaSesion();
    cotActual = Cotizacion();
    totalVT = 0;
    sucursalSeleccionado = Sucursal();
    suscripcionActual = PlanSuscripcion(unisucursal: true);
    ticketModel = TicketModel();
    empleadoSeleccionado = Usuario();
  }
}
