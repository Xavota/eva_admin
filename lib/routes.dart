import 'package:medicare/helpers/services/auth_services.dart';
import 'package:medicare/views/auth/forgot_password_screen.dart';
import 'package:medicare/views/auth/login_screen.dart';
import 'package:medicare/views/auth/register_account_screen.dart';
import 'package:medicare/views/auth/reset_password_screen.dart';
import 'package:medicare/views/ui/appointment_book_screen.dart';
import 'package:medicare/views/ui/appointment_edit_screen.dart';
import 'package:medicare/views/ui/appointment_list_screen.dart';
import 'package:medicare/views/ui/appointment_scheduling_screen.dart';
import 'package:medicare/views/ui/basic_table_screen.dart';
import 'package:medicare/views/ui/buttons_screen.dart';
import 'package:medicare/views/ui/cards_screen.dart';
import 'package:medicare/views/ui/carousels_screen.dart';
import 'package:medicare/views/ui/chat_screen.dart';
import 'package:medicare/views/ui/dashboard_screen.dart';
import 'package:medicare/views/ui/dialogs_screen.dart';
import 'package:medicare/views/ui/doctor_add_screen.dart';
import 'package:medicare/views/ui/doctor_detail_screen.dart';
import 'package:medicare/views/ui/doctor_edit_screen.dart';
import 'package:medicare/views/ui/doctor_list_screen.dart';
import 'package:medicare/views/ui/drag_n_drop_screen.dart';
import 'package:medicare/views/ui/error_pages/coming_soon_screen.dart';
import 'package:medicare/views/ui/error_pages/error_404_screen.dart';
import 'package:medicare/views/ui/error_pages/error_500_screen.dart';
import 'package:medicare/views/ui/extra_pages/faqs_screen.dart';
import 'package:medicare/views/ui/extra_pages/pricing_screen.dart';
import 'package:medicare/views/ui/extra_pages/time_line_screen.dart';
import 'package:medicare/views/ui/forms/basic_input_screen.dart';
import 'package:medicare/views/ui/forms/custom_option_screen.dart';
//import 'package:medicare/views/ui/forms/editor_screen.dart';
import 'package:medicare/views/ui/forms/file_upload_screen.dart';
import 'package:medicare/views/ui/forms/mask_screen.dart';
import 'package:medicare/views/ui/forms/slider_screen.dart';
import 'package:medicare/views/ui/forms/validation_screen.dart';
import 'package:medicare/views/ui/home_screen.dart';
import 'package:medicare/views/ui/loaders_screen.dart';
import 'package:medicare/views/ui/modal_screen.dart';
import 'package:medicare/views/ui/notification_screen.dart';
import 'package:medicare/views/ui/patient_add_screen.dart';
import 'package:medicare/views/ui/patient_detail_screen.dart';
import 'package:medicare/views/ui/patient_edit_screen.dart';
import 'package:medicare/views/ui/patient_list_screen.dart';
import 'package:medicare/views/ui/pharmacy_cart_screen.dart';
import 'package:medicare/views/ui/pharmacy_checkout_screen.dart';
import 'package:medicare/views/ui/pharmacy_detail_screen.dart';
import 'package:medicare/views/ui/pharmacy_list_screen.dart';
import 'package:medicare/views/ui/setting_screen.dart';
import 'package:medicare/views/ui/tabs_screen.dart';
import 'package:medicare/views/ui/toast_message_screen.dart';
import 'package:medicare/views/ui/wallet_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    return AuthService.isLoggedIn ? null : const RouteSettings(name: '/auth/login');
  }
}

getPageRoute() {
  var routes = [
    GetPage(name: '/', page: () => const DashboardScreen(), middlewares: [AuthMiddleware()]),
    GetPage(name: '/auth/login', page: () => const LoginScreen()),
    GetPage(name: '/auth/register_account', page: () => const RegisterAccountScreen()),
    GetPage(name: '/auth/forgot_password', page: () => const ForgotPasswordScreen()),
    GetPage(name: '/auth/reset_password', page: () => const ResetPasswordScreen()),
    GetPage(name: '/home', page: () => const HomeScreen(), middlewares: [AuthMiddleware()]),
    GetPage(name: '/pharmacy_list', page: () => const PharmacyListScreen(), middlewares: [AuthMiddleware()]),
    GetPage(name: '/detail', page: () => const PharmacyDetailScreen(), middlewares: [AuthMiddleware()]),
    GetPage(name: '/cart', page: () => const PharmacyCartScreen(), middlewares: [AuthMiddleware()]),
    GetPage(name: '/pharmacy_checkout', page: () => const PharmacyCheckoutScreen(), middlewares: [AuthMiddleware()]),
    GetPage(name: '/dashboard', page: () => const DashboardScreen(), middlewares: [AuthMiddleware()]),
    GetPage(name: '/admin/setting', page: () => const SettingScreen(), middlewares: [AuthMiddleware()]),
    GetPage(name: '/admin/wallet', page: () => const WalletScreen(), middlewares: [AuthMiddleware()]),
    GetPage(name: '/appointment_book', page: () => const AppointmentBookScreen(), middlewares: [AuthMiddleware()]),
    GetPage(name: '/appointment_edit', page: () => const AppointmentEditScreen(), middlewares: [AuthMiddleware()]),
    GetPage(name: '/admin/appointment_edit', page: () => const AppointmentEditScreen(), middlewares: [AuthMiddleware()]),
    GetPage(name: '/admin/appointment_book', page: () => const AppointmentBookScreen(), middlewares: [AuthMiddleware()]),
    GetPage(name: '/admin/appointment_list', page: () => const AppointmentListScreen(), middlewares: [AuthMiddleware()]),
    GetPage(name: '/admin/appointment_scheduling', page: () => const AppointmentSchedulingScreen(), middlewares: [AuthMiddleware()]),
    GetPage(name: '/admin/doctor/detail/:index', page: () => const DoctorDetailScreen(), middlewares: [AuthMiddleware()]),
    GetPage(name: '/admin/doctor/list', page: () => const DoctorListScreen(), middlewares: [AuthMiddleware()]),
    GetPage(name: '/admin/doctor/add', page: () => const DoctorAddScreen(), middlewares: [AuthMiddleware()]),
    GetPage(name: '/admin/doctor/edit/:index', page: () => const DoctorEditScreen(), middlewares: [AuthMiddleware()]),
    GetPage(name: '/admin/patient/list', page: () => const PatientListScreen(), middlewares: [AuthMiddleware()]),
    GetPage(name: '/admin/patient/add', page: () => const PatientAddScreen(), middlewares: [AuthMiddleware()]),
    GetPage(name: '/admin/patient/edit', page: () => const PatientEditScreen(), middlewares: [AuthMiddleware()]),
    GetPage(name: '/admin/patient/detail', page: () => const PatientDetailScreen(), middlewares: [AuthMiddleware()]),
    GetPage(name: '/chat', page: () => const ChatScreen(), middlewares: [AuthMiddleware()]),
    GetPage(name: '/widget/buttons', page: () => const ButtonsScreen(), middlewares: [AuthMiddleware()]),
    GetPage(name: '/widget/toast', page: () => const ToastMessageScreen(), middlewares: [AuthMiddleware()]),
    GetPage(name: '/widget/modal', page: () => const ModalScreen(), middlewares: [AuthMiddleware()]),
    GetPage(name: '/widget/tabs', page: () => const TabsScreen(), middlewares: [AuthMiddleware()]),
    GetPage(name: '/widget/cards', page: () => const CardsScreen(), middlewares: [AuthMiddleware()]),
    GetPage(name: '/widget/loader', page: () => const LoadersScreen(), middlewares: [AuthMiddleware()]),
    GetPage(name: '/widget/dialog', page: () => const DialogsScreen(), middlewares: [AuthMiddleware()]),
    GetPage(name: '/widget/carousel', page: () => const CarouselsScreen(), middlewares: [AuthMiddleware()]),
    GetPage(name: '/widget/drag_n_drop', page: () => const DragNDropScreen(), middlewares: [AuthMiddleware()]),
    GetPage(name: '/widget/notification', page: () => const NotificationScreen(), middlewares: [AuthMiddleware()]),
    GetPage(name: '/form/basic_input', page: () => const BasicInputScreen(), middlewares: [AuthMiddleware()]),
    GetPage(name: '/form/custom_option', page: () => const CustomOptionScreen(), middlewares: [AuthMiddleware()]),
    //GetPage(name: '/form/editor', page: () => const EditorScreen(), middlewares: [AuthMiddleware()]),
    GetPage(name: '/form/file_upload', page: () => const FileUploadScreen(), middlewares: [AuthMiddleware()]),
    GetPage(name: '/form/slider', page: () => const SliderScreen(), middlewares: [AuthMiddleware()]),
    GetPage(name: '/form/validation', page: () => const ValidationScreen(), middlewares: [AuthMiddleware()]),
    GetPage(name: '/form/mask', page: () => const MaskScreen(), middlewares: [AuthMiddleware()]),
    GetPage(name: '/error/coming_soon', page: () => ComingSoonScreen(), middlewares: [AuthMiddleware()]),
    GetPage(name: '/error/500', page: () => Error500Screen(), middlewares: [AuthMiddleware()]),
    GetPage(name: '/error/404', page: () => Error404Screen(), middlewares: [AuthMiddleware()]),
    GetPage(name: '/extra/time_line', page: () => TimeLineScreen(), middlewares: [AuthMiddleware()]),
    GetPage(name: '/extra/pricing', page: () => PricingScreen(), middlewares: [AuthMiddleware()]),
    GetPage(name: '/extra/faqs', page: () => FaqsScreen(), middlewares: [AuthMiddleware()]),
    GetPage(name: '/other/basic_table', page: () => BasicTableScreen(), middlewares: [AuthMiddleware()]),
  ];
  return routes.map((e) => GetPage(name: e.name, page: e.page, middlewares: e.middlewares, transition: Transition.noTransition)).toList();
}
