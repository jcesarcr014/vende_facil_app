import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/widgets/widgets.dart';

import '../search_screenProductos.dart';

class DetallesProductoSucursal extends StatelessWidget {
  final Producto producto;

  const DetallesProductoSucursal({super.key, required this.producto});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del Inventario'),
        actions: [
          IconButton(onPressed: () => showSearch(context: context, delegate: Searchproductos()), icon: const Icon(Icons.search)),
        ],
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.02,),
              InputField(controller: TextEditingController(text: producto.producto), readOnly: true,),
              const SizedBox(height: 20,),
              InputField(controller: TextEditingController(text: producto.clave), readOnly: true,),
              const SizedBox(height: 20,),
              InputField(controller: TextEditingController(text: producto.codigoBarras), readOnly: true,),
              const SizedBox(height: 20,),
              Row(
                children: [
                  const Expanded(
                    child: Text('Cantidad')
                  ),
                  Expanded(
                    child: InputField(controller: TextEditingController(text: producto.cantidadInv.toString() == "null" ? '0' : producto.cantidadInv.toString()))
                  )
                ],
              ),
              const SizedBox(height: 20,),
              Row(
                children: [
                  const Expanded(
                    child: Text('Apartados')
                  ),
                  Expanded(
                    child: InputField(controller: TextEditingController(text: producto.apartadoInv.toString() == "null" ? '0' : producto.apartadoInv.toString()), readOnly: true,)
                  )
                ],
              ),
              const SizedBox(height: 20,),
              Row(
                children: [
                  const Expanded(
                    child: Text('Disponibles')
                  ),
                  Expanded(
                    child: InputField(controller: TextEditingController(text: producto.disponibleInv.toString() == "null" ? '0' : producto.disponibleInv.toString()), readOnly: true,)
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}