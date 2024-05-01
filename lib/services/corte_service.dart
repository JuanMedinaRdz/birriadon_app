import 'package:birriadon/data/models/cortes.dart';
import 'package:birriadon/services/firestore_service.dart';

Future<Cortes> getTotals() async {
  List<Map<String, dynamic>> orders = await FirestoreService.getAllOrders();
  double totalVentas = 0;
  double totalCostoEnvio = 0;

  for (var order in orders) {
    totalVentas += order['price'] ?? 0;
    totalCostoEnvio += order['costoEnvio'] ?? 0;
  }

  // Calcular el total de costos del inventario
  List<Map<String, dynamic>> inventory =
      await FirestoreService.getInventoryData();
  double totalCostoInventario = 0;
  for (var item in inventory) {
    if (item['costo'] != null) {
      // Verifica si el valor de 'cost' es válido
      totalCostoInventario += (item['costo']);
    }
  }

  return new Cortes(
      totalVentas: totalVentas,
      totalCostoEnvio: totalCostoEnvio,
      totalCostoInventario: totalCostoInventario);
}
