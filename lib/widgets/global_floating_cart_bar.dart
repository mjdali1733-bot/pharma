import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:shopperz/app/modules/cart/controller/cart_controller.dart';
import 'package:shopperz/app/modules/navbar/controller/navbar_controller.dart';
import 'package:shopperz/app/modules/navbar/views/navbar_view.dart';
import 'package:shopperz/config/theme/app_color.dart';
import 'package:shopperz/utils/svg_icon.dart';

class GlobalFloatingCartBar extends StatelessWidget {
  const GlobalFloatingCartBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();
    final mediaQuery = MediaQuery.of(context);

    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.none,
      children: [
        child,
        Obx(() {
          final currentRoute = Get.currentRoute.toLowerCase();
          final navSelectedIndex = Get.isRegistered<NavbarController>()
              ? Get.find<NavbarController>().selectedIndex.value
              : null;
          final isBlockedNavbarTab =
              navSelectedIndex == 2 || navSelectedIndex == 4;
          final isBlockedRoute =
              currentRoute.contains('cart') ||
              currentRoute.contains('profile') ||
              currentRoute.contains('setting') ||
              currentRoute.contains('checkout') ||
              currentRoute.contains('order') ||
              currentRoute.contains('payment');
          final hasCartItems =
              cartController.totalItems > 0 &&
              !isBlockedNavbarTab &&
              !isBlockedRoute;
          final keyboardInset = mediaQuery.viewInsets.bottom;
          final bottomInset = keyboardInset > 0
              ? keyboardInset + 16.h
              : mediaQuery.padding.bottom + 72.h;

          return Positioned(
            left: 16.w,
            right: 16.w,
            bottom: bottomInset,
            child: IgnorePointer(
              ignoring: !hasCartItems,
              child: AnimatedSlide(
                offset: hasCartItems ? Offset.zero : const Offset(0, 1.2),
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                child: AnimatedOpacity(
                  opacity: hasCartItems ? 1 : 0,
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  child: _FloatingCartSummaryBar(
                    totalPrice: cartController.totalPrice,
                    totalItems: cartController.totalItems,
                    onTap: _openMainCartTab,
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  void _openMainCartTab() {
    if (Get.isRegistered<NavbarController>()) {
      Get.find<NavbarController>().selectPage(2);
      Get.until((route) => route.isFirst);
      return;
    }

    final navController = Get.put(NavbarController());
    navController.selectPage(2);
    Get.offAll(() => const NavBarView());
  }
}

class _FloatingCartSummaryBar extends StatelessWidget {
  const _FloatingCartSummaryBar({
    required this.totalPrice,
    required this.totalItems,
    required this.onTap,
  });

  final double totalPrice;
  final int totalItems;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(28.r),
        onTap: onTap,
        child: Container(
          height: 58.h,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: AppColor.whiteColor,
            borderRadius: BorderRadius.circular(28.r),
            border: Border.all(
              color: AppColor.primaryColor.withValues(alpha: 0.12),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColor.blackColor.withValues(alpha: 0.14),
                offset: Offset(0, 8.h),
                blurRadius: 24.r,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                height: 38.r,
                width: 38.r,
                decoration: BoxDecoration(
                  color: AppColor.primaryColor,
                  borderRadius: BorderRadius.circular(19.r),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    SvgIcon.bag,
                    height: 18.h,
                    width: 18.w,
                    colorFilter: const ColorFilter.mode(
                      AppColor.whiteColor,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'View Cart'.tr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColor.textColor,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Flexible(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${totalPrice.toStringAsFixed(0)} IQD',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColor.primaryColor,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      '$totalItems ${totalItems == 1 ? 'item'.tr : 'items'.tr}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColor.textColor1,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
