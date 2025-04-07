import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medicare/helpers/widgets/my_text_utils.dart';
import 'package:medicare/views/my_controller.dart';

class PharmacyDetailController extends MyController {
  int animatedCarouselSize = 3;
  int selectedAnimatedCarousel = 0;
  int quantity = 1;
  Timer? timerAnimation;
  final PageController animatedPageController = PageController(initialPage: 0);
  List<String> dummyTexts = List.generate(12, (index) => MyTextUtils.getDummyText(60));

  @override
  void onInit() {
    timerAnimation = Timer.periodic(Duration(seconds: 5), (Timer timer) {
      if (selectedAnimatedCarousel < animatedCarouselSize - 1) {
        selectedAnimatedCarousel++;
      } else {
        selectedAnimatedCarousel = 0;
      }

      animatedPageController.animateToPage(
        selectedAnimatedCarousel,
        duration: Duration(milliseconds: 600),
        curve: Curves.ease,
      );
      update();
    });
    super.onInit();
  }

  void onChangeAnimatedCarousel(int value) {
    selectedAnimatedCarousel = value;
    update();
  }

  void incrementQuantity() {
    if (quantity < 10) quantity++;
    update();
  }

  void decrementQuantity() {
    if (quantity > 1) quantity--;
    update();
  }

  List products = [
    {"name": "Medicine Pills", "image": "assets/images/products/medicine_pills.jpg", "price": 30, "rate": 5.0},
    {"name": "Medigrip", "image": "assets/images/products/medigrip.jpg", "price": 40, "rate": 4.4},
    {"name": "Nicotext", "image": "assets/images/products/nicotext.jpg", "price": 10, "rate": 5.0},
    {"name": "Pulse Oximeter", "image": "assets/images/products/pulse_oximeter.jpg", "price": 12, "rate": 4.0},
    {"name": "Sanitizer", "image": "assets/images/products/sanitizer.jpg", "price": 20, "rate": 3.5},
    {"name": "Stethoscope", "image": "assets/images/products/stethoscope.jpg", "price": 50, "rate": 5.0},
  ];

  @override
  void dispose() {
    super.dispose();
    timerAnimation?.cancel();
    animatedPageController.dispose();
  }

  void shopNow() {
    Get.toNamed('/pharmacy_checkout');
  }

  void addToCart() {
    Get.toNamed('/cart');
  }
}
