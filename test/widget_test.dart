import 'package:flutter_test/flutter_test.dart';
import 'package:mandalar_x/features/cart/model/cart_product_model.dart';
import 'package:mandalar_x/features/order_history/model/order_item_model.dart';

void main() {
  test('cart final price applies the existing discount', () {
    final item = CartProductModel(
      productId: 'product-1',
      itemCount: 2,
      price: 10000,
      discount: 10,
    );

    expect(item.finalPrice, 9000);
    expect(item.finalPrice * item.itemCount, 18000);
  });

  test('order item uses the discounted cart price and quantity', () {
    final item = CartProductModel(
      productId: 'product-1',
      itemCount: 3,
      price: 12000,
      discount: 25,
      ownerId: 'owner-1',
      productName: 'Noodles',
    );

    final orderItem = OrderItemModel.fromCart(item);

    expect(orderItem.quantity, 3);
    expect(orderItem.price, 9000);
    expect(orderItem.price * orderItem.quantity, 27000);
    expect(orderItem.ownerId, 'owner-1');
  });
}
