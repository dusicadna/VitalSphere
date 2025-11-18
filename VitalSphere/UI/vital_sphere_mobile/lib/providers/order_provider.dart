import 'package:vital_sphere_mobile/model/order.dart';
import 'package:vital_sphere_mobile/providers/base_provider.dart';

class OrderProvider extends BaseProvider<Order> {
  OrderProvider() : super("Order");

  @override
  Order fromJson(dynamic json) {
    return Order.fromJson(json);
  }
}

