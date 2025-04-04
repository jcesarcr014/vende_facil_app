// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:vende_facil/providers/providers.dart';
// import 'package:vende_facil/models/models.dart';
// import 'package:vende_facil/screens/productos/qr_scanner_screen.dart';
// import 'package:vende_facil/screens/ventas/resultados.dart';
// import 'package:vende_facil/widgets/widgets.dart';
// import 'package:vende_facil/providers/globals.dart' as globals;
// import 'package:vende_facil/util/actualiza_venta.dart' as totales;

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   final articulosProvider = ArticuloProvider();
//   final categoriasProvider = CategoriaProvider();
//   final descuentoProvider = DescuentoProvider();
//   final clienteProvider = ClienteProvider();
//   final apartadoProvider = ApartadoProvider();
//   final CantidadConttroller = TextEditingController()..text = '1';
//   final TotalConttroller = TextEditingController();
//   final EfectivoConttroller = TextEditingController();
//   final TarjetaConttroller = TextEditingController();
//   final CambioConttroller = TextEditingController();
//   final variablesprovider = VariablesProvider();
//   final busquedaController = TextEditingController();
//   List<Producto> productosFiltrados = [];

//   bool isLoading = false;
//   String textLoading = '';
//   double windowWidth = 0.0;
//   double windowHeight = 0.0;

//   @override
//   void initState() {
//     totales.ActualizaMontos;
//     setState(() {
//       textLoading = 'Actualizando lista de articulos';
//       isLoading = true;
//     });
//     articulosProvider.listarProductosSucursal(sesion.idSucursal!).then((value) {
//       setState(() {
//         productosFiltrados = List.from(listaProductosSucursal);
//         globals.actualizaArticulos = false;
//         textLoading = '';
//         isLoading = false;
//       });
//     });
//     super.initState();
//   }

//   @override
//   void dispose() {
//     busquedaController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     windowWidth = MediaQuery.of(context).size.width;
//     windowHeight = MediaQuery.of(context).size.height;
//     return PopScope(
//       canPop: false,
//       onPopInvoked: (didpop) {
//         if (!didpop) Navigator.pushReplacementNamed(context, 'menu');
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text('${sesion.sucursal}'),
//           automaticallyImplyLeading: false,
//           actions: [
//             IconButton(
//               onPressed: () {
//                 Navigator.pushReplacementNamed(context, 'menu');
//               },
//               icon: const Icon(Icons.menu),
//             ),
//           ],
//         ),
//         body: (isLoading)
//             ? Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text('Espere...$textLoading'),
//                     SizedBox(
//                       height: windowHeight * 0.01,
//                     ),
//                     const CircularProgressIndicator(),
//                   ],
//                 ),
//               )
//             : SingleChildScrollView(
//                 padding: EdgeInsets.symmetric(horizontal: windowWidth * 0.0),
//                 child: Column(
//                   children: [
//                     ..._listaWidgets(),
//                     ..._productos(),
//                   ],
//                 ),
//               ),
//       ),
//     );
//   }

//   _alertaElimnar() {
//     showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (context) {
//           return AlertDialog(
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//             title: const Text(
//               '¡Alerta!',
//               textAlign: TextAlign.center,
//               style: TextStyle(color: Colors.red),
//             ),
//             content: const Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   '¿Desea eliminar la lista de articulos de compra ? Esta acción no podrá revertirse.',
//                 )
//               ],
//             ),
//             actions: [
//               ElevatedButton(
//                   onPressed: () {
//                     ventaTemporal.clear();
//                     setState(() {});
//                     totalVT = 0.0;
//                     Navigator.pop(context);
//                   },
//                   child: const Text('Eliminar')),
//               ElevatedButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: const Text('Cancelar'))
//             ],
//           );
//         });
//   }

//   _listaWidgets() {
//     List<Widget> listaItems = [
//       SizedBox(
//         height: windowHeight * 0.02,
//       ),
//       Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           ElevatedButton(
//             onPressed: () async {
//               final result = await Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => QRScannerScreen(),
//                 ),
//               );
//               if (result == null) return;
//               List<Producto> resultados = listaProductosSucursal
//                   .where((producto) =>
//                       producto.producto
//                           ?.toLowerCase()
//                           .contains(result.toLowerCase()) ??
//                       false)
//                   .toList();
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => Resultados(
//                     resultados: resultados,
//                   ),
//                 ),
//               );
//             },
//             child: SizedBox(
//                 width: windowWidth * 0.09,
//                 height: windowHeight * 0.07,
//                 child: const Center(child: Icon(Icons.qr_code_scanner))),
//           ),
//           SizedBox(
//             width: windowWidth * 0.02,
//           ),
//           ElevatedButton(
//             onPressed: () {
//               if (ventaTemporal.isNotEmpty) {
//                 Navigator.pushNamed(context, 'detalle-venta');
//                 setState(() {});
//               } else {
//                 mostrarAlerta(
//                     context, '¡Atención!', 'No hay productos en la venta.');
//               }
//             },
//             child: SizedBox(
//               height: windowHeight * 0.08,
//               width: windowWidth * 0.4,
//               child: Center(
//                 child: Text('Cobrar \$${totalVT.toStringAsFixed(2)}'),
//               ),
//             ),
//           ),
//           SizedBox(
//             width: windowWidth * 0.02,
//           ),
//           ElevatedButton(
//               onPressed: () {
//                 if (ventaTemporal.isNotEmpty) {
//                   _alertaElimnar();
//                 } else {
//                   mostrarAlerta(
//                       context, '¡Atención!', 'No hay productos en la venta.');
//                 }
//               },
//               child: SizedBox(
//                   width: windowWidth * 0.09,
//                   height: windowHeight * 0.07,
//                   child: const Center(child: Icon(Icons.delete)))),
//         ],
//       ),
//       const Divider(),
//       Padding(
//         padding:
//             EdgeInsets.symmetric(horizontal: windowWidth * 0.05, vertical: 10),
//         child: TextField(
//           controller: busquedaController,
//           decoration: InputDecoration(
//             labelText: 'Buscar',
//             prefixIcon: Icon(Icons.search),
//             border: OutlineInputBorder(),
//             suffixIcon: IconButton(
//               icon: const Icon(Icons.clear),
//               onPressed: () {
//                 busquedaController.clear();
//                 _filtrarProductos('');
//               },
//             ),
//           ),
//           onChanged: _filtrarProductos,
//         ),
//       ),
//     ];

//     return listaItems;
//   }

//   _alertaProducto(Producto producto) {
//     bool isInt = producto.unidad == '1' ? true : false;
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) {
//         return AlertDialog(
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//           content: Row(
//             children: [
//               const Flexible(
//                 child: Text(
//                   'Cantidad :',
//                   style: TextStyle(color: Colors.red),
//                 ),
//               ),
//               SizedBox(
//                 width: windowWidth * 0.05,
//               ),
//               Flexible(
//                 child: InputField(
//                   textCapitalization: TextCapitalization.words,
//                   controller: CantidadConttroller,
//                   keyboardType: isInt
//                       ? TextInputType.number
//                       : TextInputType.numberWithOptions(
//                           decimal: true), // This will show the numeric keyboard
//                   inputFormatters: [
//                     FilteringTextInputFormatter.allow(
//                         RegExp(isInt ? r'^[1-9]\d*' : r'^\d+(\.\d{0,4})?$'))
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           actions: [
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pop(context);
//                 if (CantidadConttroller.text.isEmpty ||
//                     double.parse(CantidadConttroller.text) <= 0) {
//                   mostrarAlerta(context, "AVISO", "Valor invalido");
//                 } else {
//                   if (double.parse(CantidadConttroller.text) >
//                       producto.disponibleInv!) {
//                     mostrarAlerta(context, "AVISO",
//                         "No se puede agregar mas articulos de este producto :${producto.producto}, Productos Disponibles: ${producto.disponibleInv} ");
//                   } else {
//                     _agregaProductoVenta(
//                       producto,
//                       double.parse(CantidadConttroller.text),
//                     );
//                   }
//                 }
//               },
//               child: const Text('Aceptar '),
//             ),
//             ElevatedButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Cancelar'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   _productos() {
//     List<Widget> listaProd = [];
//     if (productosFiltrados.isNotEmpty) {
//       for (Producto producto in productosFiltrados) {
//         for (Categoria categoria in listaCategorias) {
//           if (producto.idCategoria == categoria.id) {
//             for (ColorCategoria color in listaColores) {
//               if (color.id == categoria.idColor) {
//                 listaProd.add(ListTile(
//                   leading: Icon(
//                     Icons.category,
//                     color: color.color,
//                   ),
//                   onTap: () => producto.disponibleInv! > 0
//                       ? _alertaProducto(producto)
//                       : mostrarAlerta(context, "AVISO",
//                           "No cuenta con productos disponibles"),
//                   title: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       SizedBox(
//                         width: windowWidth * 0.45,
//                         child: Text(
//                           producto.producto!,
//                           style: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                           ),
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                     ],
//                   ),
//                   subtitle: Text(categoria.categoria!),
//                 ));
//               }
//             }
//           }
//         }
//       }
//     } else {
//       final TextTheme textTheme = Theme.of(context).textTheme;

//       listaProd.add(Column(
//         children: [
//           const Opacity(
//             opacity: 0.2,
//             child: Icon(
//               Icons.filter_alt_off,
//               size: 130,
//             ),
//           ),
//           const SizedBox(
//             height: 15,
//           ),
//           Text(
//             'No hay productos guardados.',
//             style: textTheme.titleMedium,
//           )
//         ],
//       ));
//     }

//     return listaProd;
//   }

//   void _filtrarProductos(String query) {
//     setState(() {
//       if (query.isEmpty) {
//         productosFiltrados = List.from(listaProductosSucursal);
//       } else {
//         productosFiltrados = listaProductosSucursal
//             .where((producto) =>
//                 producto.producto!.toLowerCase().contains(query.toLowerCase()))
//             .toList();
//       }
//     });
//   }

//   _actualizaTotalTemporal() {
//     totalVT = 0;
//     if (listaVariables.isEmpty) return;
//     var aplica = listaVariables.firstWhere(
//       (variables) => variables.nombre == "aplica_mayoreo",
//     );
//     for (ItemVenta item in ventaTemporal) {
//       if (aplica.valor == "0") {
//         totalVT += item.cantidad * item.precioPublico;
//         item.subTotalItem += item.cantidad * item.precioPublico;
//         item.totalItem += item.cantidad * item.precioPublico;
//       } else {
//         if (item.cantidad >= double.parse(listaVariables[3].valor!)) {
//           totalVT += item.cantidad * item.precioMayoreo;
//           item.subTotalItem += totalVT;
//           item.totalItem += totalVT;
//         } else {
//           totalVT += item.totalItem;
//         }
//       }
//     }
//     setState(() {});
//   }

//   _agregaProductoVenta(Producto producto, cantidad) {
//     bool existe = false;
//     if (producto.unidad == "1") {
//       for (ItemVenta item in ventaTemporal) {
//         if (item.idArticulo == producto.id) {
//           existe = true;
//           item.cantidad++;
//           item.subTotalItem = item.precioPublico * item.cantidad;
//           item.totalItem = item.subTotalItem - item.descuento;
//         }
//       }
//       if (!existe) {
//         ventaTemporal.add(ItemVenta(
//             idArticulo: producto.id!,
//             articulo: producto.producto!,
//             cantidad: cantidad,
//             precioPublico: producto.precioPublico!,
//             precioMayoreo: producto.precioMayoreo!,
//             precioDistribuidor: producto.precioDist!,
//             idDescuento: 0,
//             descuento: 0,
//             subTotalItem: producto.precioPublico!,
//             totalItem: producto.precioPublico!,
//             apartado: (producto.apartado == 1) ? true : false));
//       }
//       _actualizaTotalTemporal();
//     } else {
//       if (producto.unidad == "0") {
//         for (ItemVenta item in ventaTemporal) {
//           if (item.idArticulo == producto.id) {
//             existe = true;
//             item.cantidad++;
//             item.subTotalItem = item.precioPublico * cantidad;
//             item.totalItem = item.subTotalItem - item.descuento;
//           }
//         }
//         if (!existe) {
//           ventaTemporal.add(ItemVenta(
//               idArticulo: producto.id!,
//               articulo: producto.producto!,
//               cantidad: cantidad,
//               precioPublico: producto.precioPublico!,
//               precioDistribuidor: producto.precioDist!,
//               precioMayoreo: producto.precioMayoreo!,
//               idDescuento: 0,
//               descuento: 0,
//               subTotalItem: producto.precioPublico!,
//               totalItem: producto.precioPublico! * cantidad,
//               apartado: (producto.apartado == 1) ? true : false));
//         }
//         _actualizaTotalTemporal();
//       } else {}
//       _actualizaTotalTemporal();
//     }
//   }
// }
