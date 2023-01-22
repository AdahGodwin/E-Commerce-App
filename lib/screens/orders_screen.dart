import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../providers/orders.dart';

import '../widgets/order_item.dart';
import '../widgets/app_drawer.dart';

class OrdersScreen extends StatelessWidget {
  static const routeName = '/orders';

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<Orders>(context, listen: false).getOrders(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.error != null) {
          return Center(
            child: Text('An Error Occured'),
          );
          // /error
        } else {
          return Consumer<Orders>(
            builder: (context, orderData, _) => ListView.builder(
              itemBuilder: (context, index) => OrderList(
                orderData.orders[index],
              ),
              itemCount: orderData.orders.length,
            ),
          );
        }
      },
    );
  }
}
