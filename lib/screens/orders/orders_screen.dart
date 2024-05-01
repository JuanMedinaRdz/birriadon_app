import 'package:birriadon/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OrderScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('orders').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final orders = snapshot.data!.docs;
          Map<String, List<Map<String, dynamic>>> ordersByClient = {};
          orders.forEach((order) {
            var orderData = order.data() as Map<String, dynamic>;
            String cliente = orderData['cliente'] ?? '';
            ordersByClient.putIfAbsent(cliente, () => []);
            ordersByClient[cliente]!.add(orderData);
          });

          return ListView.builder(
            itemCount: ordersByClient.length,
            itemBuilder: (context, index) {
              var cliente = ordersByClient.keys.elementAt(index);
              var ordersForClient = ordersByClient[cliente]!;
              return _buildClientOrders(context, cliente, ordersForClient);
            },
          );
        },
      ),
    );
  }

  Widget _buildClientOrders(
      BuildContext context, String cliente, List<Map<String, dynamic>> orders) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Cliente: $cliente',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              return _buildOrderCard(context, orders[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Map<String, dynamic> orderData) {
    String cliente = orderData['cliente'] ?? 'Cliente no especificado';
    String combo = orderData['name'] ?? 'Combo no especificado';
    int cantidad = orderData['quantity'] ?? 0;
    double costoEnvio = orderData['costoEnvio'] ?? 0;
    String ubicacion = orderData['ubicacion'] ?? 'Ubicación no especificada';
    double precio = orderData['price'] ?? 0;

    return Card(
      child: Dismissible(
        key: UniqueKey(),
        background: Container(
          color: Colors.red,
          alignment: Alignment.centerRight,
          child: const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
        ),
        direction: DismissDirection.endToStart,
        confirmDismiss: (direction) async {
          return await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Eliminar pedido'),
                content: const Text(
                    '¿Estás seguro de que deseas eliminar este pedido?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Sí'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('No'),
                  )
                ],
              );
            },
          );
        },
        // Elimina el orden (Por cliente) de la base de datos
        onDismissed: (direction) {
          FirestoreService.deleteOrder(cliente);
        },
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
            ),
            child: Text(
              '\$$precio',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            'Cliente: $cliente',
            style: const TextStyle(fontSize: 20),
          ),
          subtitle: Text(
              'Combo: $combo\nNúmero de pedidos: $cantidad\nCosto de envío: $costoEnvio'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  _showEditDialog(context, orderData);
                },
              ),
              IconButton(
                icon: const Icon(Icons.location_on),
                onPressed: () {
                  _showLocationDialog(context, ubicacion);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, Map<String, dynamic> orderData) {
    String newUbicacion = orderData['ubicacion'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar Ubicación'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: newUbicacion,
                  onChanged: (value) {
                    newUbicacion = value;
                  },
                  decoration: InputDecoration(labelText: 'Nueva Ubicación'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                // Llamar al método de servicio con la nueva ubicación
                await FirestoreService.updateOrderLocation(
                    newUbicacion, orderData['cliente']);
                Navigator.pop(context);
              },
              child: Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _showLocationDialog(BuildContext context, String ubicacion) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ubicación'),
          content: Text(ubicacion),
          actions: [
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: ubicacion));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Ubicación copiada al portapapeles')),
                );
                Navigator.of(context).pop();
              },
              child: const Text('Copiar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }
}
