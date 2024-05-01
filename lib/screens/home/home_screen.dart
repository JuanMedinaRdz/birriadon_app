import 'package:birriadon/data/models/order_model.dart';
import 'package:birriadon/services/firestore_service.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Order> orders = [
    Order(
      iconPath: 'assets/images/Pixies.png',
      name: 'Pixies',
      price: 80,
      counter: 0,
      additionalInfo:
          '3 Quesabirrias de Maíz con complementos (Salsa, Cilantro y Cebolla)',
    ),
    Order(
      iconPath: 'assets/images/juanisimo.png',
      name: 'Juanisimo',
      price: 100,
      counter: 0,
      additionalInfo:
          '4 Quesabirrias de Maíz con complementos (Salsa, Cilantro y Cebolla)',
    ),
    Order(
      iconPath: 'assets/images/croker.png',
      name: 'Croker',
      price: 100,
      counter: 0,
      additionalInfo:
          '3 Quesabirrias de Harina con complementos (Salsa, Cilantro y Cebolla)',
    ),
    Order(
      iconPath: 'assets/images/chester.png',
      name: 'Chester',
      price: 130,
      counter: 0,
      additionalInfo:
          '4 Quesabirrias de Harina con complementos (Salsa, Cilantro y Cebolla)',
    ),
    Order(
      iconPath: 'assets/images/barbilla_roja.png',
      name: 'Barbilla Roja',
      price: 120,
      counter: 0,
      additionalInfo:
          'Burrito de quesabirria en tortilla de harina para burrito con complementos (Salsa, Cilantro y Cebolla)',
    ),
  ];

  // Widget de construcción de la pantalla
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        // Envuelve el GridView en un GestureDetector
        onTap: () {}, // Puedes manejar el toque si lo necesitas
        child: Stack(
          children: [
            GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(8.0),
              mainAxisSpacing: 8.0,
              crossAxisSpacing: 8.0,
              children: orders.map((order) {
                return _buildCard(order);
              }).toList(),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: ElevatedButton(
                  onPressed: _mostrarDialogo,
                  child: const Text('Registrar Pedido'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para construir cada tarjeta de pedido
  Widget _buildCard(Order order) {
    return Card(
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                order.iconPath,
                width: 48,
                height: 48,
              ),
              const SizedBox(height: 8),
              Text('${order.counter}'),
              Text('Combo: ${order.name}'),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      setState(() {
                        order.counter--;
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      setState(() {
                        order.counter++;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: const Icon(Icons.error_outline),
              onPressed: () {
                // Mostrar un AlertDialog con información adicional
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Información Adicional'),
                      content: Text(order
                          .additionalInfo), // Mostrar la información adicional de la orden
                      actions: [
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
              },
            ),
          ),
        ],
      ),
    );
  }

  void _enviarOrdenes() {
    orders.forEach((order) {
      if (order.counter > 0) {
        // Envía la orden a Firestore junto con el cliente, ubicación y costo de envío
        FirestoreService.enviarPedido(
          order,
          cliente,
          ubicacion,
          costoEnvio,
        );
      }
    });
    setState(() {
      for (var order in orders) {
        order.counter = 0;
      }
    });
  }

  String cliente = '';
  String ubicacion = '';
  double costoEnvio = 0;

  // Método para mostrar el diálogo y recoger los datos del cliente, ubicación y costo de envío
  Future<void> _mostrarDialogo() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ingrese Cliente, Ubicación y Costo de Envío'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Cliente'),
                onChanged: (value) {
                  setState(() {
                    cliente = value;
                  });
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Ubicación'),
                onChanged: (value) {
                  setState(() {
                    ubicacion = value;
                  });
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Costo de Envío'),
                onChanged: (value) {
                  setState(() {
                    costoEnvio = double.tryParse(value) ?? 0;
                  });
                },
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                _enviarOrdenes();
                Navigator.of(context).pop();
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }
}
