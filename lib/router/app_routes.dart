import 'package:flutter/material.dart';
import 'package:vende_facil/screens/screens.dart';

class AppRoutes {
  static const initialRoute = 'login';

  static Map<String, Widget Function(BuildContext)> routes = {
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
    'bar-code': (BuildContext context) => const BarCode(),
    'negocio': (BuildContext context) => const AgregarEmpresa(),
    'menu': (BuildContext context) => const MenuScreen(),
    'suscripcion': (BuildContext context) => const SuscripcionScreen(),
    'tarjetas': (BuildContext context) => const TarjetaScreen(),
  };

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return MaterialPageRoute(builder: (context) => const ErrorScreen());
  }
}
