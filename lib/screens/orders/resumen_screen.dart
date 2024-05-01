import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ResumenScreen extends StatefulWidget {
  @override
  _ResumenScreenState createState() => _ResumenScreenState();
}

class _ResumenScreenState extends State<ResumenScreen> {
  List<ChartData> _chartData = [];

  @override
  void initState() {
    super.initState();
    _fetchDataFromFirestore();
  }

  Future<void> _fetchDataFromFirestore() async {
    try {
      // Obtener los datos de Firestore para la colección 'historial'
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('historial').get();

      List<ChartData> data = [];

      // Iterar sobre los documentos obtenidos
      querySnapshot.docs.forEach((doc) {
        // Extraer los datos necesarios de cada documento
        String fecha = doc.id;
        double ganancias =
            (doc['ganancias'] ?? 0).toDouble(); // Convertir a double
        double totalCostoEnvio =
            (doc['totalCostoEnvio'] ?? 0).toDouble(); // Convertir a double
        double totalVentas =
            (doc['totalVentas'] ?? 0).toDouble(); // Convertir a double
        double totalCostoInventario =
            (doc['totalCostoInventario'] ?? 0).toDouble(); // Convertir a double

        // Agregar los datos a la lista para la gráfica
        data.add(ChartData(fecha, ganancias, totalCostoEnvio, totalVentas,
            totalCostoInventario));
      });

      // Actualizar el estado con los datos obtenidos
      setState(() {
        _chartData = data;
      });
    } catch (e) {
      print('Error al obtener los datos de Firestore: $e');
      // Manejar el error según sea necesario
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Resumen de Ganancias'),
      ),
      body: Center(
        child: _chartData.isNotEmpty
            ? Column(
                children: [
                  Expanded(
                    child: SfCartesianChart(
                      primaryXAxis: CategoryAxis(),
                      series: <CartesianSeries>[
                        LineSeries<ChartData, String>(
                          dataSource: _chartData,
                          xValueMapper: (ChartData data, _) => data.fecha,
                          yValueMapper: (ChartData data, _) => data.ganancias,
                          name: 'Ganancias',
                        ),
                        LineSeries<ChartData, String>(
                          dataSource: _chartData,
                          xValueMapper: (ChartData data, _) => data.fecha,
                          yValueMapper: (ChartData data, _) =>
                              data.totalCostoEnvio,
                          name: 'Costo de Envío',
                        ),
                        LineSeries<ChartData, String>(
                          dataSource: _chartData,
                          xValueMapper: (ChartData data, _) => data.fecha,
                          yValueMapper: (ChartData data, _) => data.totalVentas,
                          name: 'Total de Ventas',
                        ),
                        LineSeries<ChartData, String>(
                          dataSource: _chartData,
                          xValueMapper: (ChartData data, _) => data.fecha,
                          yValueMapper: (ChartData data, _) =>
                              data.totalCostoInventario,
                          name: 'Costo de Inventario',
                        ),
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildLegendItem(Colors.yellow, 'Ganancias'),
                          _buildLegendItem(Colors.green, 'Costo de Envío'),
                          _buildLegendItem(Colors.orange, 'Total de Ventas'),
                          _buildLegendItem(Colors.pink, 'Costo de Inventario'),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          color: color,
        ),
        SizedBox(width: 5),
        Text(label),
      ],
    );
  }
}

class ChartData {
  final String fecha;
  final double ganancias;
  final double totalCostoEnvio;
  final double totalVentas;
  final double totalCostoInventario;

  ChartData(this.fecha, this.ganancias, this.totalCostoEnvio, this.totalVentas,
      this.totalCostoInventario);
}
