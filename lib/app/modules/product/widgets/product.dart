import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:shopperz/app/modules/cart/controller/cart_controller.dart';
import 'package:shopperz/app/modules/cart/model/product_model.dart';
import 'package:shopperz/widgets/textwidget.dart';

import '../../../../config/theme/app_color.dart';
import '../../../../utils/svg_icon.dart';
import '../../../../widgets/textwidget_with_currency.dart';

class ProductWidget extends StatelessWidget {
  const ProductWidget({
    super.key,
    this.title,
    this.textRating,
    this.discountPrice,
    this.currentPrice,
    this.rating,
    this.productImage,
    this.productId,
    this.productSlug,
    this.onTap,
    this.favTap,
    this.flashSale,
    this.isOffer,
    this.favColor,
    this.wishlist,
    this.reviews,
    this.addToCart,
    this.productKey,
  });
  final String? productImage;
  final int? productId;
  final String? productSlug;
  final String? title;
  final int? textRating;
  final String? reviews;
  final String? discountPrice;
  final String? currentPrice;
  final String? rating;
  final void Function()? onTap;
  final void Function()? favTap;
  final void Function()? addToCart;

  final bool? flashSale;
  final bool? isOffer;
  final String? favColor;
  final bool? wishlist;
  final GlobalKey? productKey;

  @override
  Widget build(BuildContext context) {
    final GlobalKey productCardKey = productKey ?? GlobalKey();
    final GlobalKey productImageKey = GlobalKey();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        key: productCardKey,
        width: 156.w,
        decoration: BoxDecoration(
          color: AppColor.whiteColor,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              offset: const Offset(0, 0),
              blurRadius: 7.r,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(8.r),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  CachedNetworkImage(
                    key: productImageKey,
                    imageUrl: productImage.toString(),
                    imageBuilder: (context, imageProvider) => Container(
                      height: 160.h,
                      width: 140.w,
                      decoration: BoxDecoration(
                        color: AppColor.whiteColor,
                        borderRadius: BorderRadius.circular(8.r),
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 6.w,
                    right: 6.w,
                    top: 6.h,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        flashSale == true
                            ? Container(
                                height: 18.h,
                                width: 57.w,
                                decoration: BoxDecoration(
                                  color: AppColor.blueColor,
                                  borderRadius: BorderRadius.circular(9.r),
                                ),
                                child: Center(
                                  child: TextWidget(
                                    text: 'Flash Sale'.tr,
                                    color: AppColor.whiteColor,
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                            : const SizedBox(),
                        wishlist == false
                            ? InkWell(
                                onTap: favTap,
                                child: Container(
                                  height: 18.r,
                                  width: 18.r,
                                  decoration: BoxDecoration(
                                    color: AppColor.whiteColor,
                                    borderRadius: BorderRadius.circular(18.r),
                                  ),
                                  child: Center(
                                    child: SvgPicture.asset(
                                      SvgIcon.heart,
                                      height: 12.h,
                                      width: 12.w,
                                    ),
                                  ),
                                ),
                              )
                            : InkWell(
                                onTap: favTap,
                                child: Container(
                                  height: 18.r,
                                  width: 18.r,
                                  decoration: BoxDecoration(
                                    color: AppColor.whiteColor,
                                    borderRadius: BorderRadius.circular(18.r),
                                  ),
                                  child: Center(
                                    child: SvgPicture.asset(
                                      SvgIcon.filledHeart,
                                      height: 12.h,
                                      width: 12.w,
                                    ),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              SizedBox(
                child: TextWidget(
                  text: title ?? '',
                  color: AppColor.textColor,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  maxLines: 2,
                  overflow: TextOverflow.fade,
                ),
              ),
              SizedBox(height: 4.h),
              RatingBarIndicator(
                rating: double.parse(
                  rating.toString() == 'null'
                      ? '0'
                      : (double.parse(rating.toString()) / textRating!.toInt())
                            .toString(),
                ),
                itemSize: 10.h,
                unratedColor: AppColor.inactiveColor,
                itemBuilder: (context, index) => Container(
                  margin: EdgeInsets.symmetric(horizontal: 1.w),
                  child: SvgPicture.asset(
                    SvgIcon.star,
                    colorFilter: const ColorFilter.mode(
                      AppColor.yellowColor,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 4.h),
              TextWidget(
                text:
                    "${rating.toString() == 'null' ? '0' : (double.parse(rating.toString()) / textRating!.toInt()).toStringAsFixed(1)} (${textRating ?? 0} ${' Reviews'.tr})",
                color: AppColor.textColor1,
                fontSize: 9.sp,
                fontWeight: FontWeight.w500,
              ),
              SizedBox(height: 8.h),
              InkWell(
                onTap: () => _handleAddToCart(context, productImageKey),
                child: Container(
                  height: 32.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColor.primaryColor,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Center(
                    child: TextWidget(
                      text: 'Add to Cart'.tr,
                      color: AppColor.whiteColor,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              FittedBox(
                child: Row(
                  children: [
                    isOffer == false
                        ? TextWidgetWithCurrency(
                            text: currentPrice ?? '0',
                            color: AppColor.textColor,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                          )
                        : SizedBox(),
                    SizedBox(width: isOffer == false ? 8.w : 0),
                    isOffer == true
                        ? Row(
                            children: [
                              TextWidgetWithCurrency(
                                text: discountPrice ?? '0',
                                color: AppColor.textColor,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                              ),
                              SizedBox(width: 8.w),
                              TextWidgetWithCurrency(
                                text: currentPrice ?? '0',
                                color: AppColor.redColor,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ],
                          )
                        : const SizedBox(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleAddToCart(BuildContext context, GlobalKey productImageKey) {
    if (addToCart != null) {
      addToCart!();
    } else {
      _addDisplayedProductToCart();
    }

    _flyToCart(context, productImageKey);
  }

  void _addDisplayedProductToCart() {
    if (productId == null) {
      return;
    }

    final cartController = Get.find<CartController>();
    final price = _priceValue(isOffer == true ? discountPrice : currentPrice);
    final oldPrice = _priceValue(currentPrice);

    cartController.addItem(
      product: ProductModel(
        data: Data(
          id: productId,
          name: title,
          slug: productSlug,
          currencyPrice: currentPrice,
          oldCurrencyPrice: discountPrice,
          flashSale: flashSale,
          isOffer: isOffer,
          ratingStar: rating,
          ratingStarCount: textRating,
          image: productImage,
          stock: 1000000,
          maximumPurchaseQuantity: 1000000,
        ),
      ),
      productVariationPrice: price,
      productVariationOldPrice: oldPrice,
      productVariationCurrencyPrice: isOffer == true
          ? discountPrice
          : currentPrice,
      productVariationOldCurrencyPrice: currentPrice,
      stock: 1000000,
      variationStock: 1000000,
      totalTax: 0,
      flatShippingCost: "0",
    );
  }

  void _flyToCart(BuildContext context, GlobalKey productImageKey) {
    if (productImage == null || productImage!.isEmpty) {
      return;
    }

    final productContext = productImageKey.currentContext;
    if (productContext == null) {
      return;
    }

    final productBox = productContext.findRenderObject() as RenderBox?;
    final overlay = Overlay.of(context);
    final overlayBox = overlay.context.findRenderObject() as RenderBox?;
    if (productBox == null || overlayBox == null) {
      return;
    }

    final startPosition = overlayBox.globalToLocal(
      productBox.localToGlobal(Offset.zero),
    );
    Offset endPosition = Offset(
      (overlayBox.size.width - 56.r) / 2,
      overlayBox.size.height - 88.h,
    );
    Size endSize = Size(56.r, 56.r);

    try {
      final cartKey = Get.find<GlobalKey>(tag: 'cartKey');
      final cartContext = cartKey.currentContext;
      final cartBox = cartContext?.findRenderObject() as RenderBox?;
      if (cartBox != null) {
        endPosition = overlayBox.globalToLocal(
          cartBox.localToGlobal(Offset.zero),
        );
        endSize = Size(cartBox.size.width, cartBox.size.height);
      }
    } catch (_) {}

    final startSize = productBox.size;
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (_) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
        onEnd: overlayEntry.remove,
        builder: (context, value, child) {
          final currentPosition = Offset.lerp(
            startPosition,
            endPosition,
            value,
          )!;
          final currentSize = Size.lerp(startSize, endSize, value)!;

          return Positioned(
            left: currentPosition.dx,
            top: currentPosition.dy,
            child: IgnorePointer(
              child: Opacity(
                opacity: 1 - (value * 0.2),
                child: Transform.scale(
                  scale: 1 - (value * 0.1),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: SizedBox(
                      width: currentSize.width,
                      height: currentSize.height,
                      child: CachedNetworkImage(
                        imageUrl: productImage!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );

    overlay.insert(overlayEntry);
  }

  double _priceValue(String? value) {
    final sanitizedValue = value?.replaceAll(RegExp(r'[^0-9.]'), '') ?? '';
    return double.tryParse(sanitizedValue) ?? 0;
  }
}
