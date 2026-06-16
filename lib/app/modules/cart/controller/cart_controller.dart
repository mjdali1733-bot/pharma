import 'dart:convert';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shopperz/app/modules/auth/controller/auth_controler.dart';
import 'package:shopperz/app/modules/cart/model/product_model.dart';
import 'package:shopperz/app/modules/shipping/controller/show_address_controller.dart';
import 'package:shopperz/main.dart';
import '../../../../config/theme/app_color.dart';
import '../../../../widgets/custom_snackbar.dart';
import '../model/cart_model.dart';

class CartController extends GetxController {
  final showAddressController = Get.put(ShowAddressController());
  final authController = Get.put(AuthController());
  final cartItems = <CartModel>[].obs;
  final numOfItems = 1.obs;
  final quantityTax = 0.0.obs;
  final taxRate = 0.0.obs;
  double productShippingCharge = 0.0;
  String shippingMethod = "0";
  final shippingAreaCost = 0.0.obs;
  double totalIndividualProductTax = 0.0;
  double flatRateShippingCost = 0.0;
  double multiplyShippingAmount = 0.0;
  bool isProductAdded = false;
  bool _isRestoringCart = false;
  final GetStorage _storage = GetStorage();

  static const String _guestCartKey = 'guest_cart_items';

  @override
  onInit() {
    authController.getSetting();
    restoreCachedCart();
    super.onInit();
  }

  decrement() {
    if (numOfItems.value > 1) {
      numOfItems.value--;
    }
  }

  void addItem({
    required ProductModel product,
    int? variationId,
    String? shippingAmount,
    String? finalVariation,
    String? sku,
    dynamic taxJson,
    dynamic stock,
    dynamic shipping,
    double? totalTax,
    double? totalPrice,
    dynamic productVariationPrice,
    dynamic productVariationOldPrice,
    dynamic productVariationCurrencyPrice,
    dynamic productVariationOldCurrencyPrice,
    int? variationStock,
    String? flatShippingCost,
  }) {
    isProductAdded = false;
    final selectedVariationId = variationId ?? 0;
    final maxQuantity =
        int.tryParse(product.data?.maximumPurchaseQuantity.toString() ?? '') ??
        1000000;

    for (var item in cartItems) {
      if (item.product.data?.id == product.data?.id &&
          item.variationId == selectedVariationId) {
        final newQuantity = item.quantity.value + numOfItems.value;

        if (newQuantity > maxQuantity) {
          customSnackbar(
            "INFO".tr,
            "YOU_ALREADY_ADDED_THE_MAXIMUM_QUANTITY".tr,
            AppColor.redColor,
          );
          return;
        } else {
          item.quantity.value = newQuantity;
          isProductAdded = true;
          _persistCart();
          return;
        }
      }
    }

    cartItems.add(
      CartModel(
        product: product,
        variationId: selectedVariationId,
        quantity: numOfItems.value,
        shippingCharge: shippingAmount ?? "0",
        finalVariationString: finalVariation ?? "null",
        sku: sku ?? "null",
        taxObject: taxJson,
        stock: stock ?? variationStock ?? product.data?.stock ?? 1000000,
        variationPrice: productVariationPrice,
        variationOldPrice: productVariationOldPrice,
        variationCurrencyPrice: productVariationCurrencyPrice,
        variationOldCurrencyPrice: productVariationOldCurrencyPrice,
        shippingObject: shipping,
        totalProductTax: totalTax,
        flatShippingCharge: flatShippingCost,
        variationStock: variationStock,
      ),
    );
    isProductAdded = true;
    _persistCart();
  }

  void incrementItem(CartModel cartItem) {
    if (cartItem.variationStock != -1) {
      if (cartItem.variationStock! < 0) {
      } else {
        if (cartItem.quantity.value < cartItem.variationStock!) {
          // maximum purchase quantity null
          if (cartItem.product.data!.maximumPurchaseQuantity == null) {
            cartItem.quantity.value++;
          } else {
            if (cartItem.quantity.value <
                cartItem.product.data!.maximumPurchaseQuantity!) {
              cartItem.quantity.value++;
              _persistCart();
            } else {
              customSnackbar(
                "INFO".tr,
                "MAXIMUM_PURCHASE_QUANTITY_LIMIT_EXCEEDED".tr,
                AppColor.redColor,
              );
            }
          }
        } else {}
      }
    } else {
      if (cartItem.product.data!.stock! > 0) {
        if (cartItem.quantity < cartItem.product.data!.stock!) {
          // maximum purchase qunatity null
          if (cartItem.product.data!.maximumPurchaseQuantity == null) {
            cartItem.quantity.value++;
            update();
          } else {
            if (cartItem.quantity <
                cartItem.product.data!.maximumPurchaseQuantity!) {
              cartItem.quantity.value++;
              update();
              _persistCart();
            } else {
              customSnackbar(
                "INFO".tr,
                "MAXIMUM_PURCHASE_QUANTITY_LIMIT_EXCEEDED".tr,
                AppColor.redColor,
              );
            }
          }
        }
      }
    }
  }

  void decrementItem(CartModel cartItem) {
    if (cartItem.quantity > 1) {
      cartItem.quantity.value--;
      decrementShippingCharge(cartItem);
      _persistCart();
    }
  }

  int getQuantityForProduct(ProductModel product) {
    int quantity = 0;

    for (CartModel cartItem in cartItems) {
      if (cartItem.product.data?.id == product.data?.id) {
        quantity = cartItem.quantity.value;
        break;
      }
    }
    return quantity;
  }

  void removeFromCart(CartModel cartModel) {
    cartItems.remove(cartModel);
    quantityTax.value = 0.0;
    removeProductWiseShippingCharge(cartModel);
    _persistCart();
  }

  void clearCart() {
    cartItems.clear();
    quantityTax.value = 0.0;
    productShippingCharge = 0.0;
    shippingAreaCost.value = 0.0;
    _persistCart();
  }

  void restoreCachedCart() {
    final cachedItems = _readCachedItems(_activeCartKey);
    if (cachedItems.isEmpty) {
      return;
    }

    _isRestoringCart = true;
    cartItems.clear();
    for (final item in cachedItems) {
      _restoreCartItem(item);
    }
    _isRestoringCart = false;
  }

  void syncGuestCartAfterAuth() {
    final guestItems = _readCachedItems(_guestCartKey);
    final userItems = _readCachedItems(_activeCartKey);

    _isRestoringCart = true;
    cartItems.clear();
    for (final item in userItems) {
      _restoreCartItem(item);
    }
    for (final item in guestItems) {
      _restoreCartItem(item);
    }
    _isRestoringCart = false;

    _persistCart();
    _storage.remove(_guestCartKey);
  }

  String get _activeCartKey {
    if (box.read('isLogedIn') == true) {
      final userKey = box.read('justToken') ?? box.read('token') ?? 'user';
      return 'user_cart_items_$userKey';
    }

    return _guestCartKey;
  }

  List<Map<String, dynamic>> _readCachedItems(String key) {
    final cachedValue = _storage.read(key);
    if (cachedValue == null) {
      return [];
    }

    try {
      final decodedValue = cachedValue is String
          ? jsonDecode(cachedValue)
          : cachedValue;
      if (decodedValue is! List) {
        return [];
      }

      return decodedValue
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    } catch (_) {
      return [];
    }
  }

  void _restoreCartItem(Map<String, dynamic> item) {
    final productJson = item['product'];
    if (productJson is! Map) {
      return;
    }

    final quantity = _intValue(item['quantity'], fallback: 1);
    final previousQuantity = numOfItems.value;
    numOfItems.value = quantity;

    addItem(
      product: ProductModel.fromJson(Map<String, dynamic>.from(productJson)),
      variationId: _intValue(item['variation_id']),
      shippingAmount: item['shipping_charge']?.toString(),
      finalVariation: item['final_variation']?.toString(),
      sku: item['sku']?.toString(),
      taxJson: item['tax_object'],
      stock: item['stock'],
      shipping: item['shipping_object'],
      totalTax: _doubleValue(item['total_product_tax']),
      productVariationPrice: item['variation_price'],
      productVariationOldPrice: item['variation_old_price'],
      productVariationCurrencyPrice: item['variation_currency_price'],
      productVariationOldCurrencyPrice: item['variation_old_currency_price'],
      variationStock: _intValue(item['variation_stock'], nullable: true),
      flatShippingCost: item['flat_shipping_charge']?.toString(),
    );

    numOfItems.value = previousQuantity;
  }

  void _persistCart() {
    if (_isRestoringCart) {
      return;
    }

    final encodedItems = cartItems
        .map(
          (item) => {
            'product': item.product.toJson(),
            'quantity': item.quantity.value,
            'variation_id': item.variationId,
            'shipping_charge': item.shippingCharge,
            'final_variation': item.finalVariationString,
            'sku': item.sku,
            'tax_object': _jsonSafe(item.taxObject),
            'stock': item.stock,
            'shipping_object': _jsonSafe(item.shippingObject),
            'total_product_tax': item.totalProductTax,
            'flat_shipping_charge': item.flatShippingCharge,
            'variation_price': item.variationPrice,
            'variation_old_price': item.variationOldPrice,
            'variation_currency_price': item.variationCurrencyPrice,
            'variation_old_currency_price': item.variationOldCurrencyPrice,
            'variation_stock': item.variationStock,
          },
        )
        .toList();

    _storage.write(_activeCartKey, jsonEncode(encodedItems));
  }

  int _intValue(dynamic value, {int fallback = 0, bool nullable = false}) {
    if (value == null && nullable) {
      return -1;
    }
    return int.tryParse(value.toString()) ?? fallback;
  }

  double? _doubleValue(dynamic value) {
    if (value == null) {
      return null;
    }
    return double.tryParse(value.toString());
  }

  dynamic _jsonSafe(dynamic value) {
    if (value == null) {
      return null;
    }

    try {
      return jsonDecode(jsonEncode(value));
    } catch (_) {
      return null;
    }
  }

  int get totalItems {
    return cartItems.fold(0, (sum, item) => sum + item.quantity.value);
  }

  double get totalPrice {
    final totalPrice = 0.0.obs;
    for (var item in cartItems) {
      totalPrice.value +=
          (item.quantity *
          (double.tryParse(item.variationPrice.toString()) ?? 0));
    }
    return totalPrice.value;
  }

  double get totalTax {
    double tTax = 0.0;
    for (var item in cartItems) {
      tTax +=
          ((item.quantity *
                  (double.tryParse(item.variationPrice.toString()) ?? 0)) /
              100) *
          (item.totalProductTax ?? 0).toDouble();
    }
    return tTax;
  }

  calculateShippingCharge({
    required String shippingMethodStatus,
    String? shippingType,
    String? isProductQntyMultiply,
    String? flatShippingCharge,
  }) {
    productShippingCharge = 0;
    shippingMethod = shippingMethodStatus;
    for (var item in cartItems) {
      if (shippingMethodStatus == "5") {
        if (item.product.data?.shipping?.shippingType == 10 &&
            item.product.data?.shipping?.isProductQuantityMultiply == 5) {
          productShippingCharge +=
              double.parse(item.shippingCharge) * item.quantity.value;
        }
        if (item.product.data?.shipping?.shippingType == 5) {}
        if (item.product.data?.shipping?.shippingType == 10 &&
            item.product.data?.shipping?.isProductQuantityMultiply == 10) {
          productShippingCharge += double.parse(item.shippingCharge);
        }
      }
      if (shippingMethodStatus == "10") {
        productShippingCharge =
            double.tryParse(
              item.flatShippingCharge?.toString() ??
                  flatShippingCharge ??
                  authController
                      .settingModel
                      ?.data
                      ?.shippingSetupFlatRateWiseCost
                      .toString() ??
                  "0",
            ) ??
            0;
      }
    }
  }

  areaWiseShippingCal() {
    final activeShippingMethod = shippingMethod == "0"
        ? authController.shippingMethod
        : shippingMethod;
    shippingMethod = activeShippingMethod;

    if (activeShippingMethod == "15") {
      final selectedAddress =
          showAddressController
              .addressList
              .value
              .data?[showAddressController.selectedAddressIndex.value == -1
              ? 0
              : showAddressController.selectedAddressIndex.value];

      if (showAddressController.areaShippingModel.value.data == null ||
          showAddressController.areaShippingModel.value.data!.isEmpty) {
        shippingAreaCost.value = 0;
        shippingAreaCost.value = double.parse(
          authController.settingModel?.data?.shippingSetupAreaWiseDefaultCost
                  .toString() ??
              "0",
        );
      } else {
        for (var area in showAddressController.areaShippingModel.value.data!) {
          if (selectedAddress!.country!.contains(area.country!) &&
              selectedAddress.state!.contains(area.state!) &&
              selectedAddress.city!.contains(area.city!)) {
            shippingAreaCost.value = double.parse(
              area.shippingCost?.toString() ?? "0",
            );
            print("area.shippingCost = ${area.shippingCost}");
            break;
          } else {
            shippingAreaCost.value = 0;
            shippingAreaCost.value = double.parse(
              authController
                      .settingModel
                      ?.data
                      ?.shippingSetupAreaWiseDefaultCost
                      .toString() ??
                  "0",
            );
          }
        }
      }
    }
  }

  removeProductWiseShippingCharge(CartModel cartModel) {
    if (shippingMethod == "5") {
      if (cartModel.product.data?.shipping?.shippingType == 10 &&
          cartModel.product.data?.shipping?.isProductQuantityMultiply == 5) {
        productShippingCharge -=
            double.parse(cartModel.shippingCharge) * cartModel.quantity.value;
      }
      if (cartModel.product.data?.shipping?.shippingType == 5) {}
      if (cartModel.product.data?.shipping?.shippingType == 10 &&
          cartModel.product.data?.shipping?.isProductQuantityMultiply == 10) {
        productShippingCharge -= double.parse(cartModel.shippingCharge);
      }
    }
    if (shippingMethod == "10") {}
  }

  incrementShippingCharge(CartModel cartModel) {
    if (shippingMethod == "5") {
      if (cartModel.product.data?.shipping?.shippingType == 10 &&
          cartModel.product.data?.shipping?.isProductQuantityMultiply == 5) {
        multiplyShippingAmount = double.parse(cartModel.shippingCharge);
        productShippingCharge += multiplyShippingAmount;
      }
      if (cartModel.product.data?.shipping?.shippingType == 5) {}
      if (cartModel.product.data?.shipping?.shippingType == 10 &&
          cartModel.product.data?.shipping?.isProductQuantityMultiply == 10) {}
    }
    if (shippingMethod == "10") {}
  }

  decrementShippingCharge(CartModel cartModel) {
    if (shippingMethod == "5") {
      if (cartModel.product.data?.shipping?.shippingType == 10 &&
          cartModel.product.data?.shipping?.isProductQuantityMultiply == 5) {
        productShippingCharge -= double.parse(cartModel.shippingCharge);
      }
      if (cartModel.product.data?.shipping?.shippingType == 5) {}
      if (cartModel.product.data?.shipping?.shippingType == 10 &&
          cartModel.product.data?.shipping?.isProductQuantityMultiply == 10) {}
    }
    if (shippingMethod == "10") {}
  }
}
