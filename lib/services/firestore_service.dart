import 'package:birriadon/data/models/order_model.dart' as my_order;
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static Future<void> enviarPedido(my_order.Order order, String cliente,
      String ubicacion, double costoEnvio) async {
    try {
      CollectionReference orders =
          FirebaseFirestore.instance.collection('orders');

      double precioTotal = order.price * order.counter;

      await orders.add({
        'name': order.name,
        'price': precioTotal,
        'quantity': order.counter,
        'cliente': cliente,
        'ubicacion': ubicacion,
        'costoEnvio': costoEnvio,
      });
      print("Pedido enviado correctamente");
    } catch (error) {
      print("Error al enviar el pedido: $error");
      throw error;
    }
  }

  static Future<void> deleteOrder(String cliente) async {
    try {
      CollectionReference orders =
          FirebaseFirestore.instance.collection('orders');

      QuerySnapshot querySnapshot =
          await orders.where('cliente', isEqualTo: cliente).get();
      for (var doc in querySnapshot.docs) {
        doc.reference.delete();
      }

      print("Pedido eliminado correctamente");
    } catch (error) {
      print("Error al eliminar el pedido: $error");
      throw error;
    }
  }

  static Future<void> updateOrderLocation(
      String nuevaUbicacion, String cliente) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('cliente', isEqualTo: cliente)
          .get();

      for (var doc in querySnapshot.docs) {
        DocumentReference orderRef = doc.reference;
        await orderRef.update({'ubicacion': nuevaUbicacion});
      }

      print("Ubicación del pedido actualizada correctamente");
    } catch (error) {
      print("Error al actualizar la ubicación del pedido: $error");
      throw error;
    }
  }

  static Future<List<Map<String, dynamic>>> getAllOrders() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('orders').get();
      List<Map<String, dynamic>> orders = [];
      for (var doc in querySnapshot.docs) {
        orders.add(doc.data() as Map<String, dynamic>);
      }
      return orders;
    } catch (error) {
      print("Error al obtener todos los pedidos: $error");
      throw error;
    }
  }

  static Future<List<Map<String, dynamic>>> getOrders() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('orders').get();
      List<Map<String, dynamic>> orders = [];
      for (var doc in querySnapshot.docs) {
        orders.add(doc.data() as Map<String, dynamic>);
      }
      return orders;
    } catch (error) {
      print("Error al obtener los pedidos: $error");
      throw error;
    }
  }

  static Future<List<Map<String, dynamic>>> getInventoryData() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('inventory').get();
      List<Map<String, dynamic>> inventory = [];
      for (var doc in querySnapshot.docs) {
        inventory.add(doc.data() as Map<String, dynamic>);
      }
      return inventory;
    } catch (error) {
      print("Error al obtener los datos del inventario: $error");
      throw error;
    }
  }

  static Future<void> addInventoryItem(
      String nombre, double cantidad, double costo) async {
    try {
      CollectionReference inventory =
          FirebaseFirestore.instance.collection('inventory');
      await inventory.add({
        'nombre': nombre,
        'cantidad': cantidad,
        'costo': costo,
      });
      print("Producto agregado correctamente a Firestore");
    } catch (error) {
      print("Error al agregar el producto a Firestore: $error");
      throw error;
    }
  }

  static Future<void> deleteInventoryItem(String nombre) async {
    try {
      CollectionReference inventory =
          FirebaseFirestore.instance.collection('inventory');

      QuerySnapshot querySnapshot =
          await inventory.where('nombre', isEqualTo: nombre).get();
      for (var doc in querySnapshot.docs) {
        doc.reference.delete();
      }

      print("Producto eliminado correctamente");
    } catch (error) {
      print("Error al eliminar el producto: $error");
      throw error;
    }
  }

  static Future<void> enviarReporte(
      String identificador,
      double totalVentas,
      double totalCostoEnvio,
      double totalCostoInventario,
      double ganancias) async {
    try {
      // Accede a la instancia de Firestore
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Define los datos a enviar en el reporte
      Map<String, dynamic> reporteData = {
        'identificador': identificador,
        'totalVentas': totalVentas,
        'totalCostoEnvio': totalCostoEnvio,
        'totalCostoInventario': totalCostoInventario,
        'ganancias': ganancias
      };

      // Agrega un nuevo documento a la colección 'historial' con un identificador único
      await firestore
          .collection('historial')
          .doc(identificador)
          .set(reporteData);

      // Impresión para confirmar el envío exitoso (opcional)
      print('Reporte enviado con éxito a la colección historial');
    } catch (e) {
      // Manejo de errores
      print('Error al enviar el reporte: $e');
      throw e;
    }
  }
  // Agrega más métodos para el inventario según sea necesario...
}
