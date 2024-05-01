import 'package:birriadon/services/firestore_service.dart';
import 'package:flutter/material.dart';

class GastoScreen extends StatefulWidget {
  @override
  _GastoScreenState createState() => _GastoScreenState();
}

class _GastoScreenState extends State<GastoScreen> {
  TextEditingController _nombreController = TextEditingController();
  TextEditingController _cantidadController = TextEditingController();
  TextEditingController _costoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Registro de Gastos'),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
                left: 12.0, top: 12.0, right: 12.0, bottom: 16.0),
            margin: EdgeInsets.only(bottom: 16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    gradient: LinearGradient(
                      colors: [Colors.pinkAccent, Colors.cyan],
                    ),
                  ),
                  padding: EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: Colors.black,
                      ),
                      SizedBox(width: 8.0),
                      Flexible(
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            children: [
                              TextSpan(
                                text: '¡Listo para añadir tu producto!.',
                              ),
                              TextSpan(
                                text: 'Completa los campos a continuación',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.0),
                _buildTextFieldWithIcon(
                  controller: _nombreController,
                  hintText: 'Nombre del Producto',
                  icon: Icons.shopping_cart,
                ),
                _buildTextFieldWithIcon(
                  controller: _cantidadController,
                  hintText: 'Cantidad',
                  icon: Icons.format_list_numbered,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                _buildTextFieldWithIcon(
                  controller: _costoController,
                  hintText: 'Costo',
                  icon: Icons.attach_money,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                SizedBox(height: 20.0),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      await _agregarProducto();
                      await FirestoreService.getInventoryData();
                      setState(() {});
                    },
                    child: Text('Agregar Producto'),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.0),
          Text(
            'Productos Agregados',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10.0),
          Expanded(child: _buildProductosList()),
        ],
      ),
    );
  }

  Widget _buildTextFieldWithIcon({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: Colors.grey), // Añade un borde con color gris
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          border: InputBorder.none, // Oculta el borde del TextField
          hintText: hintText,
          prefixIcon: Icon(icon),
          fillColor: Colors.transparent, // Establece el fondo transparente
          filled: true, // Activa el relleno del fondo
        ),
      ),
    );
  }

  Widget _buildProductosList() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: FirestoreService.getInventoryData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          List<Map<String, dynamic>>? productos = snapshot.data;
          if (productos == null || productos.isEmpty) {
            return Center(
              child: Text('No hay productos disponibles'),
            );
          }
          return ListView.builder(
            itemCount: productos.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> producto = productos[index];
              return Dismissible(
                key: Key(producto['nombre'] ??
                    index.toString()), // Usar index como clave alternativa
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Confirmación'),
                        content: Text(
                            '¿Estás seguro de eliminar ${producto['nombre']}?'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text('Sí'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text('No'),
                          ),
                        ],
                      );
                    },
                  );
                },
                onDismissed: (direction) async {
                  String nombreProducto = producto['nombre'];
                  await FirestoreService.deleteInventoryItem(nombreProducto);
                  setState(() {
                    // Llama al callback para notificar a corte_screen
                  });
                },
                child: Card(
                  margin: EdgeInsets.symmetric(vertical: 5.0),
                  child: ListTile(
                    leading: Text(
                      '${producto['cantidad']}',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    title: Text(producto['nombre'] ?? 'Nombre no especificado'),
                    trailing: Container(
                      padding: EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(10.0),
                          bottomLeft: Radius.circular(10.0),
                        ),
                      ),
                      child: Text(
                        '\$${producto['costo']}',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _agregarProducto() async {
    String nombre = _nombreController.text;
    String cantidadText = _cantidadController.text;
    String costoText = _costoController.text;

    // Verificar si todos los campos están llenos
    if (nombre.isNotEmpty && cantidadText.isNotEmpty && costoText.isNotEmpty) {
      double cantidad = double.tryParse(cantidadText) ?? 0.0;
      double costo = double.tryParse(costoText) ?? 0.0;

      if (cantidad > 0 && costo > 0) {
        try {
          // Guardar el producto en Firestore
          await FirestoreService.addInventoryItem(nombre, cantidad, costo);
          // Limpiar los campos de entrada
          _nombreController.clear();
          _cantidadController.clear();
          _costoController.clear();
        } catch (error) {
          print('Error al agregar el producto a Firestore: $error');
        }
      } else {
        // Mostrar mensaje de error si la cantidad o el costo no son válidos
        _mostrarError(
            'Por favor ingrese valores válidos para cantidad y costo.');
      }
    } else {
      // Mostrar mensaje de error si algún campo está vacío
      _mostrarError('Por favor complete todos los campos.');
    }
  }

  void _mostrarError(String mensaje) {
    // Mostrar un AlertDialog con el mensaje de error
    // ...
  }
}
