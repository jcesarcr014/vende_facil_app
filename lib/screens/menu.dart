import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vende_facil/util/limpia_datos.dart';
import 'package:vende_facil/widgets/widgets.dart'; // Asegúrate que mostrarAlerta está aquí

// Definición de la clase MenuItemData (como se mostró arriba)
class MenuItemData {
  final String title;
  final String route;
  final IconData icon;
  final Color iconColor;
  final String? subtitle;

  MenuItemData({
    required this.title,
    required this.route,
    required this.icon,
    required this.iconColor,
    this.subtitle,
  });
}

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final usuarioProvider = UsuarioProvider();
  final corteProvider = CorteProvider();
  final limpiaDatos = LimpiaDatos();
  bool isLoading = false;
  String textLoading = '';
  final TextEditingController _montoController = TextEditingController();

  // Paleta de colores sugerida para los iconos, puedes ajustarla
  final Map<String, Color> _iconColors = {
    'inicio': Colors.blue.shade700,
    'abonos': Colors.green.shade600,
    'historial': Colors.orange.shade700,
    'productos': Colors.purple.shade600,
    'categorias': Colors.teal.shade600,
    'descuentos': Colors.red.shade600,
    'clientes': Colors.indigo.shade600,
    'empresa': Colors.brown.shade600,
    'configuracion': Colors.grey.shade700,
    'salir': Colors.red.shade800,
  };

  // Mapeo de rutas a iconos de Material Design
  final Map<String, IconData> _materialIcons = {
    'home': Icons.payments_outlined, // O Icons.home_outlined
    'menuAbonos': Icons.payment_outlined,
    'historial_empleado': Icons.receipt_long_outlined,
    'menu-historial': Icons.history_outlined,
    'productos': Icons.inventory_2_outlined, // O Icons.shopping_bag_outlined
    'categorias': Icons.category_outlined,
    'descuentos': Icons.local_offer_outlined,
    'clientes': Icons.people_alt_outlined,
    'menu-negocio': Icons.business_outlined,
    'config': Icons.settings_outlined,
    'login': Icons.logout_outlined,
    // Añade más si es necesario, ej: 'suscripcion': Icons.subscriptions_outlined,
  };

  @override
  void initState() {
    super.initState();
    if (sesion.caja != true && sesion.tipoUsuario == 'E') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _validarCaja();
      });
    }
  }

  @override
  void dispose() {
    _montoController.dispose();
    super.dispose();
  }

  Future<void> _validarCaja() async {
    if (!mounted) return;
    sesion.caja = false; // Asumimos que no está abierta hasta confirmar
    final resultado = await corteProvider.validarCaja();

    if (resultado.status == 1) {
      // status 1 significa que NO hay caja abierta
      if (mounted) {
        _mostrarDialogoEfectivoInicial();
      }
    } else {
      // status 0 o diferente de 1 significa que SÍ hay caja o no se requiere
      if (mounted) {
        setState(() {
          sesion.caja = true;
        });
      }
    }
  }

  void _mostrarDialogoEfectivoInicial() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          title: const Text('Registro de Efectivo Inicial'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Es tu primera venta desde el último corte. Por favor, ingresa la cantidad de efectivo con la que cuentas en caja:',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _montoController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                decoration: InputDecoration(
                  labelText: 'Monto en efectivo',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  prefixIcon: const Icon(Icons.attach_money),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.pop(context);
                // Podrías considerar cerrar la app o llevar a una pantalla de "espera"
                // si no pueden operar sin caja. Por ahora, solo cierra el diálogo.
                // sesion.caja sigue siendo false.
              },
            ),
            ElevatedButton(
              // Botón más prominente para la acción principal
              style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              onPressed: () async {
                if (_montoController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Por favor, ingresa una cantidad.'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                  return;
                }
                if (!mounted) return;
                setState(() {
                  isLoading = true;
                  textLoading = 'Registrando efectivo...';
                });
                Navigator.pop(
                    context); // Cierra el diálogo antes de la operación async

                final resultado = await corteProvider
                    .agregarEfectivoInicial(_montoController.text);

                if (!mounted) return;
                setState(() {
                  isLoading = false;
                  if (resultado.status == 1) {
                    sesion.caja = true;
                  } else {
                    sesion.caja = false; // Mantener o re-validar
                  }
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(resultado.mensaje ?? 'Operación completada.'),
                    backgroundColor:
                        resultado.status == 1 ? Colors.green : Colors.redAccent,
                  ),
                );
                if (resultado.status != 1) {
                  _mostrarDialogoEfectivoInicial();
                }
              },
              child: const Text('Registrar',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  List<MenuItemData> _getMenuItems() {
    List<MenuItemData> items = [];

    // Lógica para determinar qué ítems mostrar
    // Similar a tu lógica original, pero construyendo objetos MenuItemData
    if (sesion.idNegocio != 0) {
      if (sesion.tipoUsuario == "E") {
        items = [
          MenuItemData(
              title: 'Caja',
              route: 'home',
              icon: _materialIcons['home']!,
              iconColor: _iconColors['inicio']!),
          MenuItemData(
              title: 'Abonos',
              route: 'menuAbonos',
              icon: _materialIcons['menuAbonos']!,
              iconColor: _iconColors['abonos']!),
          MenuItemData(
              title: 'Historial',
              route: 'historial_empleado',
              icon: _materialIcons['historial_empleado']!,
              iconColor: _iconColors['historial']!),
          MenuItemData(
              title: 'Productos',
              route: 'productos',
              icon: _materialIcons['productos']!,
              iconColor: _iconColors['productos']!),
          MenuItemData(
              title: 'Categorias',
              route: 'categorias',
              icon: _materialIcons['categorias']!,
              iconColor: _iconColors['categorias']!),
          MenuItemData(
              title: 'Clientes',
              route: 'clientes',
              icon: _materialIcons['clientes']!,
              iconColor: _iconColors['clientes']!),
          MenuItemData(
              title: 'Configuracion',
              route: 'config',
              icon: _materialIcons['config']!,
              iconColor: _iconColors['configuracion']!),
          MenuItemData(
              title: 'Cerrar Sesión',
              route: 'login',
              icon: _materialIcons['login']!,
              iconColor: _iconColors['salir']!),
        ];
      } else {
        // Asumo tipoUsuario == "P" (Propietario)
        items = [
          MenuItemData(
              title: 'Caja',
              route: 'home',
              icon: _materialIcons['home']!,
              iconColor: _iconColors['inicio']!),
          MenuItemData(
              title: 'Abonos',
              route: 'menuAbonos',
              icon: _materialIcons['menuAbonos']!,
              iconColor: _iconColors['abonos']!),
          MenuItemData(
              title: 'Historial',
              route: 'menu-historial',
              icon: _materialIcons['menu-historial']!,
              iconColor: _iconColors['historial']!),
          MenuItemData(
              title: 'Productos',
              route: 'productos',
              icon: _materialIcons['productos']!,
              iconColor: _iconColors['productos']!),
          MenuItemData(
              title: 'Categorias',
              route: 'categorias',
              icon: _materialIcons['categorias']!,
              iconColor: _iconColors['categorias']!),
          MenuItemData(
              title: 'Descuentos',
              route: 'descuentos',
              icon: _materialIcons['descuentos']!,
              iconColor: _iconColors['descuentos']!),
          MenuItemData(
              title: 'Clientes',
              route: 'clientes',
              icon: _materialIcons['clientes']!,
              iconColor: _iconColors['clientes']!),
          MenuItemData(
              title: 'Empresa',
              route: 'menu-negocio',
              icon: _materialIcons['menu-negocio']!,
              iconColor: _iconColors['empresa']!),
          MenuItemData(
              title: 'Configuracion',
              route: 'config',
              icon: _materialIcons['config']!,
              iconColor: _iconColors['configuracion']!),
          MenuItemData(
              title: 'Cerrar Sesión',
              route: 'login',
              icon: _materialIcons['login']!,
              iconColor: _iconColors['salir']!),
        ];
      }
    } else {
      // Sin negocio seleccionado
      items = [
        MenuItemData(
            title: 'Empresa',
            route: 'menu-negocio',
            icon: _materialIcons['menu-negocio']!,
            iconColor: _iconColors['empresa']!),
        MenuItemData(
            title: 'Configuracion',
            route: 'config',
            icon: _materialIcons['config']!,
            iconColor: _iconColors['configuracion']!),
        MenuItemData(
            title: 'Cerrar Sesión',
            route: 'login',
            icon: _materialIcons['login']!,
            iconColor: _iconColors['salir']!),
      ];
    }
    return items;
  }

  void _handleMenuItemTap(MenuItemData item) async {
    if (!mounted) return;

    if (item.route == 'login') {
      setState(() => isLoading = true);
      textLoading = 'Cerrando sesión...';
      UsuarioProvider().logout().then((value) async {
        setState(() => isLoading = false);
        if (!mounted) return;
        if (value.status == 1) {
          limpiaDatos.limpiaDatos();
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('token', '');
          Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
        } else {
          mostrarAlerta(
              context, "Alerta", value.mensaje ?? "Error al cerrar sesión.");
        }
      });
      return; // Importante para no continuar con otras navegaciones
    }

    // Validaciones específicas antes de navegar
    if (item.route == 'menuAbonos' && !varAplicaApartado) {
      mostrarAlerta(context, 'ATENCIÓN',
          'El sistema de apartado no está habilitado en su negocio.');
      return;
    }
    if (item.route == 'home' && sesion.tipoUsuario == "P") {
      // Para propietario, 'home' podría ser un dashboard o seleccionar sucursal
      // Si siempre es seleccionar sucursal para venta:
      Navigator.pushNamed(context, 'select-branch-office');
      return;
    }
    if (item.route == 'home' &&
        sesion.tipoUsuario == 'E' &&
        sesion.caja == false) {
      mostrarAlerta(context, 'ATENCIÓN',
          'Debes registrar el efectivo inicial antes de comenzar con las ventas.');
      _validarCaja(); // Volvemos a validar por si necesita abrir la caja
      return;
    }

    // Navegaciones especiales
    if (item.route == 'productos') {
      Navigator.pushNamed(context, 'products-menu');
      return;
    }

    Navigator.pushNamed(context, item.route);
  }

  @override
  Widget build(BuildContext context) {
    final List<MenuItemData> menuOptions = _getMenuItems();
    final String appBarTitle = 'Menú Principal';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final exit = await showDialog<bool>(
              context: context,
              barrierDismissible: false,
              builder: ((context) {
                return AlertDialog(
                  title: const Text('Salir'),
                  content: const Text('¿Desea salir de la aplicación?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('No'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Si'),
                    ),
                  ],
                );
              }));
          if (exit ?? false) {
            SystemNavigator.pop();
          }
        }
      },
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              title: Text(appBarTitle),
              centerTitle: true,
              elevation: 2,
              // No automaticallyImplyLeading si es la pantalla principal post-login
              // A menos que quieras un botón de "atrás" a una pantalla anterior al menú.
            ),
            body: GridView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: menuOptions.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount:
                    2, // Puedes cambiar a 3 si hay muchos items o son pequeños
                childAspectRatio:
                    1.1, // Ajusta para que las tarjetas se vean bien (ancho/alto)
                crossAxisSpacing: 12.0,
                mainAxisSpacing: 12.0,
              ),
              itemBuilder: (BuildContext context, int index) {
                final item = menuOptions[index];
                return _buildGridMenuCard(
                    context, item, () => _handleMenuItemTap(item));
              },
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 20),
                      Text(
                        textLoading,
                        style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            decoration: TextDecoration.none),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Widget para las tarjetas del GridView
  Widget _buildGridMenuCard(
      BuildContext context, MenuItemData item, VoidCallback onTap) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding:
              const EdgeInsets.all(12.0), // Un poco menos padding para grid
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(
                    12), // Ajusta según el tamaño del icono
                decoration: BoxDecoration(
                  color: item.iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  item.icon,
                  size: 38, // Icono un poco más grande para el grid
                  color: item.iconColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                item.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15, // Un poco más pequeño para caber bien
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (item.subtitle != null && item.subtitle!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  item.subtitle!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
