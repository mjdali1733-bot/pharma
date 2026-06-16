import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shopperz/app/modules/auth/controller/auth_controler.dart';
import 'package:shopperz/app/modules/auth/views/sign_in.dart';
import 'package:shopperz/app/modules/cart/controller/cart_controller.dart';
import 'package:shopperz/app/modules/cart/widgets/cart_item.dart';
import 'package:shopperz/app/modules/navbar/controller/navbar_controller.dart';
import 'package:shopperz/app/modules/product_details/controller/product_details_controller.dart';
import 'package:shopperz/app/modules/shipping/views/shipping_information_screen.dart';
import 'package:shopperz/main.dart';
import 'package:shopperz/utils/images.dart';
import 'package:shopperz/widgets/devider.dart';
import 'package:shopperz/widgets/primary_button.dart';
import 'package:shopperz/widgets/textwidget.dart';

import '../../../../config/theme/app_color.dart';
import '../../../../widgets/custom_snackbar.dart';
import '../../../../widgets/textwidget_with_currency.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final cartController = Get.find<CartController>();
  final authController = Get.put(AuthController());
  final productDetailsController = Get.put(ProductDetailsController());

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      productDetailsController.resetProductState();
    });

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomSafeArea = MediaQuery.of(context).padding.bottom;
    final isCartTabOpen =
        Get.isRegistered<NavbarController>() &&
        Get.find<NavbarController>().selectedIndex.value == 2;
    final checkoutBottomOffset = isCartTabOpen ? 74.h : bottomSafeArea;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark,
      ),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: AppColor.primaryBackgroundColor,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(48.h),
            child: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: Padding(
                padding: EdgeInsets.only(left: 16.w, top: 8.h, right: 16.w),
                child: Text(
                  "Shopping Cart".tr,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColor.textColor,
                  ),
                ),
              ),
              leadingWidth: double.infinity,
            ),
          ),
          body: Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 16.h, left: 16.w, right: 16.w),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Obx(
                        () => cartController.cartItems.isEmpty
                            ? Padding(
                                padding: EdgeInsets.only(top: 60.h),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        AppImages.emptyIcon,
                                        height: 300.h,
                                        width: 300.w,
                                      ),
                                      SizedBox(height: 16.h),
                                      TextWidget(
                                        text: 'CART_IS_EMPTY'.tr,
                                        textAlign: TextAlign.center,
                                        color: AppColor.textColor,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : ListView.builder(
                                itemCount: cartController.cartItems.length,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  final cartItem =
                                      cartController.cartItems[index];
                                  return Padding(
                                    padding: EdgeInsets.only(top: 16.h),
                                    child: Obx(
                                      () => CartWidget(
                                        productImage:
                                            cartItem.product.data!.image,
                                        title: cartItem.product.data!.name,
                                        finalVariation:
                                            cartItem.finalVariationString,
                                        currentPrice: cartItem
                                            .variationCurrencyPrice
                                            .toString(),
                                        discountPrice: cartItem
                                            .variationOldCurrencyPrice
                                            .toString(),
                                        decrement: () {
                                          cartController.decrementItem(
                                            cartController.cartItems[index],
                                          );
                                        },
                                        isOffer: cartItem.product.data!.isOffer,
                                        decrementIconvalue:
                                            cartController.totalItems,
                                        quantity: cartController
                                            .cartItems[index]
                                            .quantity
                                            .toString(),
                                        increment: () {
                                          cartController.incrementItem(
                                            cartController.cartItems[index],
                                          );
                                        },
                                        remove: () {
                                          cartController.removeFromCart(
                                            cartController.cartItems[index],
                                          );
                                        },
                                        stock: cartItem.stock,
                                        incrementValue: cartItem.quantity.value,
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                      SizedBox(height: isCartTabOpen ? 244.h : 170.h),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: checkoutBottomOffset,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColor.whiteColor.withOpacity(0.9),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.r),
                      topRight: Radius.circular(16.r),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        offset: Offset(0, -4.h),
                        blurRadius: 16.r,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const DeviderWidget(),
                      SizedBox(height: 16.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextWidget(
                              text: 'Subtotal'.tr,
                              color: AppColor.textColor,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                            Obx(
                              () => TextWidgetWithCurrency(
                                text:
                                    '${authController.currency}${cartController.totalPrice.toStringAsFixed(2)}',
                                color: AppColor.textColor,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16.h),
                      InkWell(
                        onTap: () {
                          if (cartController.cartItems.isEmpty) {
                            customSnackbar(
                              "ERROR".tr,
                              "Your cart is empty",
                              AppColor.error,
                            );
                          } else {
                            Get.to(
                              () => box.read("isLogedIn") != false
                                  ? const ShippingInformationScreen()
                                  : const SignInScreen(),
                            );
                          }
                        },
                        child: PrimaryButton(text: 'Proceed to Checkout'.tr),
                      ),
                      SizedBox(height: 12.h),
                      TextWidget(
                        text:
                            'Shipping, Taxes & Discount Calculate at Checkout',
                        color: AppColor.textColor,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      SizedBox(height: 8.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
