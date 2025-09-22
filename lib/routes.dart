import 'package:medicare/helpers/services/auth_services.dart';
import 'package:medicare/views/auth/forgot_password_screen.dart';
import 'package:medicare/views/auth/login_screen.dart';
import 'package:medicare/views/auth/login_admin_screen.dart';
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

import 'package:medicare/views/ui/admin_doctor_add_screen.dart';
import 'package:medicare/views/ui/admin_doctor_detail_screen.dart';
import 'package:medicare/views/ui/admin_doctor_edit_screen.dart';
import 'package:medicare/views/ui/admin_doctor_list_screen.dart';
import 'package:medicare/views/ui/admin_doctor_subs_list_screen.dart';

import 'package:medicare/views/ui/admin_premium_posts_add_screen.dart';
import 'package:medicare/views/ui/admin_premium_posts_list_screen.dart';
import 'package:medicare/views/ui/admin_premium_posts_edit_screen.dart';

import 'package:medicare/views/ui/admin_premium_videos_list_screen.dart';

import 'package:medicare/views/ui/admin_premium_books_list_screen.dart';
import 'package:medicare/views/ui/admin_premium_books_add_screen.dart';
import 'package:medicare/views/ui/admin_premium_books_edit_screen.dart';

import 'package:medicare/views/ui/doctor_secretary_add_screen.dart';
import 'package:medicare/views/ui/doctor_secretary_detail_screen.dart';
import 'package:medicare/views/ui/doctor_secretary_edit_screen.dart';

import 'package:medicare/views/ui/secretary_patient_list_screen.dart';
import 'package:medicare/views/ui/secretary_patient_detail_screen.dart';

import 'package:medicare/views/ui/secretary_dates_add_screen.dart';
import 'package:medicare/views/ui/doctor_dates_list_screen.dart';
import 'package:medicare/views/ui/secretary_dates_list_screen.dart';

import 'package:medicare/views/ui/doctor_patient_add_screen.dart';
import 'package:medicare/views/ui/doctor_patient_detail_screen.dart';
import 'package:medicare/views/ui/doctor_patient_edit_screen.dart';
import 'package:medicare/views/ui/doctor_patient_list_screen.dart';

import 'package:medicare/views/ui/doctor_patient_prescription_list_screen.dart';
import 'package:medicare/views/ui/doctor_patient_prescription_add_screen.dart';
import 'package:medicare/views/ui/doctor_patient_prescription_edit_screen.dart';
import 'package:medicare/views/ui/doctor_patient_prescription_detail_screen.dart';

import 'package:medicare/views/ui/patient_dates_list_screen.dart';
import 'package:medicare/views/ui/patient_prescription_list_screen.dart';
import 'package:medicare/views/ui/patient_prescription_detail_screen.dart';
import 'package:medicare/views/ui/patient_daily_record_screen.dart';
import 'package:medicare/views/ui/patient_record_history_screen.dart';

import 'package:medicare/views/ui/patient_premium_content_list_screen.dart';

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

//import 'package:medicare/test.dart';

import 'package:blix_essentials/blix_essentials.dart';

class AuthMiddleware extends GetMiddleware {
  AuthMiddleware([this.specificLogin, this.reRouteUrl]);

  final LoginType? specificLogin;
  final String? reRouteUrl;

  @override
  RouteSettings? redirect(String? route) {
    //Debug.log("AuthMiddleware.redirect: AuthService.loginType = ${AuthService.loginType.name}", overrideColor: Colors.green);
    //return AuthService.isLoggedIn || AuthService.isLoggedInAdmin ? null : const RouteSettings(name: '/auth/login');
    if (specificLogin != null) {
      return AuthService.loginType == specificLogin ? null : RouteSettings(name: reRouteUrl?? '/auth/login');
    }
    return AuthService.loginType != LoginType.kNone ? null : RouteSettings(name: reRouteUrl?? '/auth/login');
  }

  /*@override
  Future<GetNavConfig?> redirectDelegate(GetNavConfig route) async {
    Debug.log("AuthMiddleware.redirectDelegate: AuthService.loginType = ${AuthService.loginType.name}", overrideColor: Colors.green);

    final isLoggedIn = AuthService.loginType != LoginType.kNone;

    if (!isLoggedIn && route.uri.path != '/auth/login') {
      // Redirect to login
      return GetNavConfig.fromRoute('/panel/auth/login');
      // Imperatively redirect
      /*Future.microtask(() {
        Get.rootDelegate.toNamed('/auth/login');
      });
      return null; // cancel current route processing*/
    }

    // Allow navigation
    return await super.redirectDelegate(route);
  }*/
}

/*class DoctorAuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    //Debug.log("AuthMiddleware.redirect: AuthService.loginType = ${AuthService.loginType.name}", overrideColor: Colors.green);
    //return AuthService.isLoggedIn || AuthService.isLoggedInAdmin ? null : const RouteSettings(name: '/auth/login');
    return AuthService.loginType == LoginType.kDoctor ? null : const RouteSettings(name: '/auth/login');
  }
}*/

class AdminAuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    Debug.log("AdminAuthMiddleware.redirect: AuthService.loginType = ${AuthService.loginType.name}", overrideColor: Colors.green);
    //return AuthService.isLoggedIn ? null : const RouteSettings(name: '/auth/login');
    return AuthService.loginType == LoginType.kAdmin ? null : const RouteSettings(name: '/panel/auth/login');
  }

  /*@override
  Future<GetNavConfig?> redirectDelegate(GetNavConfig route) async {
    Debug.log("AdminAuthMiddleware.redirectDelegate: AuthService.loginType = ${AuthService.loginType.name}", overrideColor: Colors.green);

    final isLoggedIn = AuthService.loginType == LoginType.kAdmin;

    if (!isLoggedIn && route.uri.path != '/panel/auth/login') {
      // Redirect to login
      return GetNavConfig.fromRoute('/panel/auth/login');
      // Imperatively redirect
      /*Future.microtask(() {
        Get.rootDelegate.toNamed('/panel/auth/login');
      });
      return null; // cancel current route processing*/
    }

    // Allow navigation
    return GetNavConfig.fromRoute('/');
  }*/
}

List<GetPage<dynamic>> getPageRoute() {
  var routes = [
    GetPage(name: '/', page: () => const DashboardScreen(), middlewares: [AuthMiddleware()]),

    GetPage(name: '/auth/login', page: () => const LoginScreen()),
    GetPage(name: '/panel/auth/login', page: () => const LoginAdminScreen()),
    GetPage(name: '/auth/register_account', page: () => const RegisterAccountScreen()),
    GetPage(name: '/auth/forgot_password', page: () => const ForgotPasswordScreen()),
    GetPage(name: '/auth/reset_password', page: () => const ResetPasswordScreen()),

    GetPage(name: '/home', page: () => const HomeScreen(), middlewares: [AuthMiddleware()]),
    //GetPage(name: '/home', page: () => const RemotePdfPreview(pdfUrl: "https://blixdev.com/eva/uploads/pdf/upload_68239934e6dc66.22740508_MARA_CASTELLANOS.pdf"), middlewares: [AuthMiddleware()]),
    GetPage(name: '/dashboard', page: () => const DashboardScreen(), middlewares: [AuthMiddleware()]),
    GetPage(name: '/panel', page: () => const DashboardScreen(), middlewares: [AdminAuthMiddleware()]),

    // Admin
    GetPage(name: '/panel/doctor/list', page: () => const AdminDoctorListScreen(), middlewares: [AdminAuthMiddleware()]),
    GetPage(name: '/panel/doctor_subs/list', page: () => const AdminDoctorSubsListScreen(), middlewares: [AdminAuthMiddleware()]),
    GetPage(name: '/panel/doctor/add', page: () => const AdminDoctorAddScreen(), middlewares: [AdminAuthMiddleware()]),
    GetPage(name: '/panel/doctor/edit/:index', page: () => const AdminDoctorEditScreen(), middlewares: [AdminAuthMiddleware()]),
    GetPage(name: '/panel/doctor/detail/:index', page: () => const AdminDoctorDetailScreen(), middlewares: [AdminAuthMiddleware()]),

    GetPage(name: '/panel/premium/posts/:header/:subHeader/list', page: () => const AdminPremiumPostsListScreen(), middlewares: [AdminAuthMiddleware()]),
    GetPage(name: '/panel/premium/posts/:header/:subHeader/add', page: () => const AdminPremiumPostsAddScreen(), middlewares: [AdminAuthMiddleware()]),
    GetPage(name: '/panel/premium/posts/:header/:subHeader/:postIndex/edit', page: () => const AdminPremiumPostsEditScreen(), middlewares: [AdminAuthMiddleware()]),

    GetPage(name: '/panel/premium/videos/:header/:subHeader/list', page: () => const AdminPremiumVideosListScreen(), middlewares: [AdminAuthMiddleware()]),

    GetPage(name: '/panel/premium/books/:header/:subHeader/list', page: () => const AdminPremiumBooksListScreen(), middlewares: [AdminAuthMiddleware()]),
    GetPage(name: '/panel/premium/books/:header/:subHeader/add', page: () => const AdminPremiumBooksAddScreen(), middlewares: [AdminAuthMiddleware()]),
    GetPage(name: '/panel/premium/books/:header/:subHeader/:bookIndex/edit', page: () => const AdminPremiumBooksEditScreen(), middlewares: [AdminAuthMiddleware()]),

    // Doctor
    GetPage(name: '/doctor/patient/list', page: () => const DoctorPatientListScreen(), middlewares: [AuthMiddleware(LoginType.kDoctor)]),
    //GetPage(name: '/doctor/patient_prescription_profile/list', page: () => const PatientPrescriptionProfileListScreen(), middlewares: [AuthMiddleware(LoginType.kDoctor)]),
    GetPage(name: '/doctor/patient/add', page: () => const DoctorPatientAddScreen(), middlewares: [AuthMiddleware(LoginType.kDoctor)]),
    GetPage(name: '/doctor/patient/edit/:index', page: () => const DoctorPatientEditScreen(), middlewares: [AuthMiddleware(LoginType.kDoctor)]),
    GetPage(name: '/doctor/patient/detail/:index', page: () => const DoctorPatientDetailScreen(), middlewares: [AuthMiddleware(LoginType.kDoctor)]),

    GetPage(name: '/doctor/patient/:patientIndex/prescription/list', page: () => const DoctorPatientPrescriptionListScreen(), middlewares: [AuthMiddleware(LoginType.kDoctor)]),
    GetPage(name: '/doctor/patient/:patientIndex/prescription/add', page: () => const DoctorPatientPrescriptionAddScreen(), middlewares: [AuthMiddleware(LoginType.kDoctor)]),
    GetPage(name: '/doctor/patient/:patientIndex/prescription/:index/edit', page: () => const DoctorPatientPrescriptionEditScreen(), middlewares: [AuthMiddleware(LoginType.kDoctor)]),
    GetPage(name: '/doctor/patient/:patientIndex/prescription/:index/detail', page: () => const DoctorPatientPrescriptionDetailScreen(), middlewares: [AuthMiddleware(LoginType.kDoctor)]),

    GetPage(name: '/doctor/secretary/add', page: () => const DoctorSecretaryAddScreen(), middlewares: [AuthMiddleware(LoginType.kDoctor)]),
    GetPage(name: '/doctor/secretary/edit', page: () => const DoctorSecretaryEditScreen(), middlewares: [AuthMiddleware(LoginType.kDoctor)]),
    GetPage(name: '/doctor/secretary/detail', page: () => const DoctorSecretaryDetailScreen(), middlewares: [AuthMiddleware(LoginType.kDoctor)]),

    GetPage(name: '/doctor/dates/list', page: () => const DoctorDatesListScreen(), middlewares: [AuthMiddleware(LoginType.kDoctor)]),

    // Secretary
    GetPage(name: '/secretary/patient/list', page: () => const SecretaryPatientListScreen(), middlewares: [AuthMiddleware(LoginType.kSecretary)]),
    GetPage(name: '/secretary/patient/detail/:index', page: () => const SecretaryPatientDetailScreen(), middlewares: [AuthMiddleware(LoginType.kSecretary)]),

    GetPage(name: '/secretary/dates/add', page: () => const SecretaryDatesAddScreen(), middlewares: [AuthMiddleware(LoginType.kSecretary)]),
    GetPage(name: '/secretary/dates/list', page: () => const SecretaryDatesListScreen(), middlewares: [AuthMiddleware(LoginType.kSecretary)]),

    // Patient
    GetPage(name: '/patient/dates/list', page: () => const PatientDatesListScreen(), middlewares: [AuthMiddleware(LoginType.kPatient)]),
    GetPage(name: '/patient/prescription/list', page: () => const PatientPrescriptionListScreen(), middlewares: [AuthMiddleware(LoginType.kPatient)]),
    GetPage(name: '/patient/prescription/:index/detail', page: () => const PatientPrescriptionDetailScreen(), middlewares: [AuthMiddleware(LoginType.kPatient)]),
    GetPage(name: '/patient/record/daily', page: () => const PatientDalyRecordScreen(), middlewares: [AuthMiddleware(LoginType.kPatient)]),
    GetPage(name: '/patient/record/history', page: () => const PatientRecordHistoryScreen(), middlewares: [AuthMiddleware(LoginType.kPatient)]),

    GetPage(name: '/patient/premium/content/:header/:subHeader/list', page: () => const PatientPremiumPostsListScreen(), middlewares: [AuthMiddleware(LoginType.kPatient)]),

    // Other
    GetPage(name: '/pharmacy_list', page: () => const PharmacyListScreen(), middlewares: [AuthMiddleware()]),
    GetPage(name: '/detail', page: () => const PharmacyDetailScreen(), middlewares: [AuthMiddleware()]),
    GetPage(name: '/cart', page: () => const PharmacyCartScreen(), middlewares: [AuthMiddleware()]),
    GetPage(name: '/pharmacy_checkout', page: () => const PharmacyCheckoutScreen(), middlewares: [AuthMiddleware()]),
    GetPage(name: '/admin/setting', page: () => const SettingScreen(), middlewares: [AuthMiddleware()]),
    GetPage(name: '/admin/wallet', page: () => const WalletScreen(), middlewares: [AuthMiddleware()]),
    GetPage(name: '/appointment_book', page: () => const AppointmentBookScreen(), middlewares: [AuthMiddleware()]),
    GetPage(name: '/appointment_edit', page: () => const AppointmentEditScreen(), middlewares: [AuthMiddleware()]),
    GetPage(name: '/admin/appointment_edit', page: () => const AppointmentEditScreen(), middlewares: [AuthMiddleware()]),
    GetPage(name: '/admin/appointment_book', page: () => const AppointmentBookScreen(), middlewares: [AuthMiddleware()]),
    GetPage(name: '/admin/appointment_list', page: () => const AppointmentListScreen(), middlewares: [AuthMiddleware()]),
    GetPage(name: '/admin/appointment_scheduling', page: () => const AppointmentSchedulingScreen(), middlewares: [AuthMiddleware()]),
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
