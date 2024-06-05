import 'package:flutter/material.dart';
import 'package:vende_facil/screens/screens.dart';

class AppRoutes {
  static const initialRoute = 'splash';

  static Map<String, Widget Function(BuildContext)> routes = {
    'splash': (BuildContext context) => const SplashScreen(),
    'home': (BuildContext context) => const HomeScreen(),
    'login': (BuildContext context) => const LoginScreen(),
    'registro': (BuildContext context) => const RegistroScreen(),
    'nva-categoria': (BuildContext context) => const AgregaCategoriaScreen(),
    'categorias': (BuildContext context) => const CategoriasScreens(),
    'nvo-cliente': (BuildContext context) => const AgregaClienteScreen(),
    'clientes': (BuildContext context) => const ClientesScreen(),
    'nvo-descuento': (BuildContext context) => const AgregaDescuentoScreen(),
    'descuentos': (BuildContext context) => const DescuentosScreen(),
    'nvo-producto': (BuildContext context) => const AgregaProductoScreen(),
    'productos': (BuildContext context) => const ProductosScreen(),
    'nvo-abono': (BuildContext context) => const AgregarAbonoScreen(),
    'historial': (BuildContext context) => const HistorialScreen(),
    'config': (BuildContext context) => const ConfigScreen(),
    'detalle-venta': (BuildContext context) => const VentaDetalleScreen(),
    'negocio': (BuildContext context) => const AgregarEmpresa(),
    'menu': (BuildContext context) => const MenuScreen(),
    'suscripcion': (BuildContext context) => const SuscripcionScreen(),
    'tarjetas': (BuildContext context) => const TarjetaScreen(),
    'nvo-tarjetas': (BuildContext context) => const AgregaTarjetaScreen(),
    "ventasD": (BuildContext context) => const VentaDetallesScreen(),
    'perfil': (BuildContext context) => const PerfilScreen(),
    'abono_detalle': (BuildContext context) => const AbonoDetallesScreen(),
    'config-apartado': (BuildContext context) => const AjustesApartadoScreen(),
    'empleados': (BuildContext context) => const ListaEmpleadosScreen(),
    'nvo-empleado': (BuildContext context) => const RegistroEmpleadoScreen(),
    'perfil-empleado': (BuildContext context) => const PerfilEmpleadosScreen(),
    'venta': (BuildContext context) => const VentaScreen(),
    'apartado': (BuildContext context) => const ApartadoDetalleScreen(),
    'planes': (BuildContext context) => const PlanesScreen(),
  };
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return MaterialPageRoute(builder: (context) => const ErrorScreen());
  }
}
