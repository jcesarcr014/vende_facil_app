import 'package:flutter/material.dart';
import 'package:vende_facil/screens/screens.dart';

import '../models/producto_model.dart';

class AppRoutes {
  static const initialRoute = 'splash';

  static Map<String, Widget Function(BuildContext)> routes = {
    'abonoD': (BuildContext context) => const DetallesAbonoScreen(),
    'apartadosD': (BuildContext context) => const DetallesApartadoScreen(),
    'eliminar-producto-sucursal': (BuildContext context) =>
        const EliminarProductoSucursal(),
    'agregar-producto-sucursal': (BuildContext context) =>
        const AgregarProductoSucursal(),
    'products-menu': (BuildContext context) => const ProductsScreen(),
    'splash': (BuildContext context) => const SplashScreen(),
    'select-branch-office': (BuildContext context) => const SucursalesScreen(),
    'home': (BuildContext context) => const HomeScreen(),
    'login': (BuildContext context) => const LoginScreen(),
    'registro': (BuildContext context) => const RegistroScreen(),
    'recupera': (BuildContext context) => const RecuperaPassScreen(),
    'nva-categoria': (BuildContext context) => const AgregaCategoriaScreen(),
    'categorias': (BuildContext context) => const CategoriasScreens(),
    'nvo-cliente': (BuildContext context) => const AgregaClienteScreen(),
    'clientes': (BuildContext context) => const ClientesScreen(),
    'nvo-descuento': (BuildContext context) => const AgregaDescuentoScreen(),
    'descuentos': (BuildContext context) => const DescuentosScreen(),
    'nvo-producto': (BuildContext context) => const AgregaProductoScreen(),
    'productos': (BuildContext context) => const ProductosScreen(),
    'historial': (BuildContext context) => const HistorialScreen(),
    'config': (BuildContext context) => const ConfigScreen(),
    'config-impresora': (BuildContext context) => const ImpresoraScreen(),
    'detalle-venta': (BuildContext context) => const VentaDetalleScreen(),
    'menu-negocio': (BuildContext context) => const MenuEmpresaScreen(),
    'negocio': (BuildContext context) => const AgregarEmpresa(),
    'menu': (BuildContext context) => const MenuScreen(),
    'suscripcion': (BuildContext context) => const SuscripcionScreen(),
    'tarjetas': (BuildContext context) => const TarjetaScreen(),
    'nvo-tarjetas': (BuildContext context) => const AgregaTarjetaScreen(),
    "ventasD": (BuildContext context) => const VentaDetallesScreen(),
    'perfil': (BuildContext context) => const PerfilScreen(),
    'abono_detalle': (BuildContext context) =>
        const AbonoDetallesScreen(), // detalle apartado
    'config-apartado': (BuildContext context) => const AjustesApartadoScreen(),
    'empleados': (BuildContext context) => const ListaEmpleadosScreen(),
    'nvo-empleado': (BuildContext context) => const RegistroEmpleadoScreen(),
    'perfil-empleado': (BuildContext context) => const PerfilEmpleadosScreen(),
    'venta': (BuildContext context) => const VentaScreen(),
    'apartado': (BuildContext context) => const ApartadoDetalleScreen(),
    'planes': (BuildContext context) => const PlanesScreen(),
    'nvo-pass': (BuildContext context) => const CambioPassScreen(),
    'lista-sucursales': (BuildContext context) => const ListaSucursalesScreen(),
    'nva-sucursal': (BuildContext context) => const RegistroSucursalesScreen(),
    'ticket': (BuildContext context) => const TicketScreen(),
    'InventoryPage': (BuildContext context) => const InventoryPage(),
    'abonosPagos': (BuildContext context) =>
        const AbonoScreenpago(), //realizar abono
    'listaCotizaciones': (BuildContext context) =>
        const HistorialCotizacionesScreen(),
    'HomerCotizar': (BuildContext context) => const HomeCotizarScreen(),
    'DetalleCotizar': (BuildContext context) => const CotizacionDetalleScreen(),
    'selecionarSA': (BuildContext context) => const SucursalesAbonoScreen(),
    'menuAbonos': (BuildContext context) => const MenuAbonoScreen(),
    'detalleCotizacions': (BuildContext context) =>
        const CotizacionDetallesScreen(),
    'lista-apartados': (BuildContext context) =>
        const AbonosLiquidados(), //lista abonos
    'historial_empleado': (BuildContext context) =>
        const HistorialEmpleadoScreen(),
    'seleccionar-sucursal-cotizacion': (BuildContext context) =>
        const SeleccionarSucursal(),
    'menu-historial': (BuildContext context) => const MenuHistorialScreen(),
    'cortes-empleados': (BuildContext context) => const CortesEmpleadosScreen(),
    'corte-detalle': (BuildContext context) => const CorteDetalleScreen(),
    'ventas-dia': (BuildContext context) => const ReporteDetalleDiaScreen(),
    'venta-detalles': (BuildContext context) =>
        const VentaDetallesScreen(), // detalle venta
  };

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return MaterialPageRoute(builder: (context) => const ErrorScreen());
  }
}
