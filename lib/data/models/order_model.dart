class Order {
  final String iconPath;
  String name;
  final double price;
  int counter;
  final String additionalInfo;

  // Order({
  //   required this.iconPath,
  //   this.name, // "juan medina"
  //   required this.price,
  //   required this.counter,
  //   required this.additionalInfo,
  // }){
  //   final nameFormatted = this.name?.split(" ");
  //   this.name = nameFormatted[0];
  //   this.lastname = nameFormatted[1];
  // };

  Order({
    required this.iconPath,
    required this.name, // "juan medina"
    required this.price,
    required this.counter,
    required this.additionalInfo,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      iconPath: json['iconPath'],
      name: json['name'],
      price: json['price'],
      counter: json['counter'],
      additionalInfo: json['additionalInfo'],
    );
  }
}
