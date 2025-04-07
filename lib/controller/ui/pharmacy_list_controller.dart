import 'package:get/get.dart';
import 'package:medicare/views/my_controller.dart';

class PharmacyListController extends MyController {
  List products = [
    {"name": "Detol", "image": "assets/images/products/detol.jpg", "price": 40, "rate": 4.5},
    {"name": "Mask", "image": "assets/images/products/mask.jpg", "price": 50, "rate": 4.0},
    {"name": "Medicine Pills", "image": "assets/images/products/medicine_pills.jpg", "price": 30, "rate": 5.0},
    {"name": "Medigrip", "image": "assets/images/products/medigrip.jpg", "price": 40, "rate": 4.4},
    {"name": "Nicotext", "image": "assets/images/products/nicotext.jpg", "price": 10, "rate": 5.0},
    {"name": "Pulse Oximeter", "image": "assets/images/products/pulse_oximeter.jpg", "price": 12, "rate": 4.0},
    {"name": "Sanitizer", "image": "assets/images/products/sanitizer.jpg", "price": 20, "rate": 3.5},
    {"name": "Stethoscope", "image": "assets/images/products/stethoscope.jpg", "price": 50, "rate": 5.0},
    {"name": "Thermometer", "image": "assets/images/products/thermometer.jpg", "price": 40, "rate": 5.0},
  ];

  void goToDetails() {
    Get.toNamed('/detail');
  }
}
