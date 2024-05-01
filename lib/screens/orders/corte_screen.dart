import 'package:birriadon/data/models/cortes.dart';
import 'package:birriadon/services/corte_service.dart';
import 'package:birriadon/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class CorteScreen extends StatefulWidget {
  @override
  _CorteScreenState createState() => _CorteScreenState();
}

class _CorteScreenState extends State<CorteScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Corte de Ventas'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: FutureBuilder(
            future: getTotals(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }

              final cortes = snapshot.data;
              if (cortes == null) {
                print('error');
                return Text('Cortes es null');
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTotalCard(
                    icon: Icons.attach_money,
                    color: Colors.green,
                    title: 'Total Ventas',
                    amount: cortes.totalVentas,
                  ),
                  SizedBox(height: 20),
                  _buildTotalCard(
                    icon: Icons.local_shipping,
                    color: Colors.blue,
                    title: 'Total Costo de Envío',
                    amount: cortes.totalCostoEnvio,
                  ),
                  SizedBox(height: 20),
                  _buildTotalCard(
                    icon: Icons.inventory,
                    color: Colors.orange,
                    title: 'Total Gastos Semanales',
                    amount: cortes.totalCostoInventario,
                  ),
                  SizedBox(height: 20),
                  SfCartesianChart(
                    primaryXAxis: CategoryAxis(),
                    series: <CartesianSeries>[
                      ColumnSeries<Map<String, dynamic>, String>(
                        dataSource: [
                          {
                            'category': 'Ganancias',
                            'amount': cortes.totalVentas -
                                cortes.totalCostoEnvio -
                                cortes.totalCostoInventario
                          },
                          {'category': 'Ventas', 'amount': cortes.totalVentas},
                          {
                            'category': 'Envios',
                            'amount': cortes.totalCostoEnvio
                          },
                          {
                            'category': 'Gastos',
                            'amount': cortes.totalCostoInventario
                          },
                        ],
                        xValueMapper: (Map<String, dynamic> sales, _) =>
                            sales['category'],
                        yValueMapper: (Map<String, dynamic> sales, _) =>
                            sales['amount'],
                        dataLabelSettings: DataLabelSettings(isVisible: true),
                        color: Color.fromRGBO(139, 0, 139, 1), // Morado
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: () {
                        enviarReporte(cortes);
                      },
                      child: const Text('Enviar Reporte'),
                    ),
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void enviarReporte(Cortes cortes) async {
    // Calcular las ganancias restando los costos totales de las ventas
    double ganancias = cortes.totalVentas -
        cortes.totalCostoEnvio -
        cortes.totalCostoInventario;

    // Obtener la fecha actual en formato "yyyy-MM-dd" para usar como identificador
    String fecha = DateFormat('yyyy-MM-dd').format(DateTime.now());

    try {
      // Llamar a FirestoreService.enviarReporte y pasar los parámetros necesarios
      await FirestoreService.enviarReporte(
        fecha,
        cortes.totalVentas, // Se cambió cortes.totalVentas
        cortes.totalCostoEnvio, // Se cambió cortes.totalCostoEnvio
        cortes.totalCostoInventario,
        ganancias,
      );

      // Mostrar un mensaje de confirmación al usuario
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reporte enviado con éxito')),
      );
    } catch (e) {
      // Manejo de errores
      print('Error al enviar el reporte: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ocurrió un error al enviar el reporte')),
      );
    }
  }

  Widget _buildTotalCard({
    required IconData icon,
    required Color color,
    required String title,
    required double amount,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 36),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              '\$${amount.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 24, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
