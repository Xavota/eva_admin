import 'package:blix_essentials/blix_essentials.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/route_manager.dart';
import 'package:medicare/app_constant.dart';
import 'package:medicare/db_manager.dart';
//import 'package:google_fonts/google_fonts.dart';
import 'package:medicare/helpers/services/url_service.dart';
import 'package:medicare/helpers/theme/admin_theme.dart';
import 'package:medicare/helpers/theme/theme_customizer.dart';
import 'package:medicare/helpers/utils/my_shadow.dart';
import 'package:medicare/helpers/utils/ui_mixins.dart';
import 'package:medicare/helpers/utils/my_input_formaters.dart';
import 'package:medicare/helpers/services/auth_services.dart';
import 'package:medicare/helpers/widgets/my_card.dart';
import 'package:medicare/helpers/widgets/my_container.dart';
import 'package:medicare/helpers/widgets/my_router.dart';
import 'package:medicare/helpers/widgets/my_spacing.dart';
import 'package:medicare/helpers/widgets/my_text.dart';
import 'package:medicare/helpers/widgets/my_text_style.dart';
import 'package:medicare/helpers/widgets/my_button.dart';
import 'package:medicare/images.dart';
import 'package:medicare/model/patient_list_model.dart';
import 'package:medicare/widgets/custom_pop_menu.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import 'package:medicare/db_manager.dart';

typedef LeftbarMenuFunction = void Function(String key);

class LeftbarObserver {
  static Map<String, LeftbarMenuFunction> observers = {};

  static void attachListener(String key, LeftbarMenuFunction fn) {
    observers[key] = fn;
  }

  static void detachListener(String key) {
    observers.remove(key);
  }

  static void notifyAll(String key) {
    for (var fn in observers.values) {
      fn(key);
    }
  }
}

class LeftBar extends StatefulWidget {
  final bool isCondensed;
  
  final bool? premium;
  final DateTime? premiumEnd;

  const LeftBar({super.key, this.isCondensed = false, this.premium, this.premiumEnd});

  @override
  State<LeftBar> createState() => _LeftBarState();
}

class _LeftBarState extends State<LeftBar> with SingleTickerProviderStateMixin, UIMixin {
  final ThemeCustomizer customizer = ThemeCustomizer.instance;

  final manager = DBManager.instance!;

  bool isCondensed = false;
  String path = UrlService.getCurrentUrl();

  Map<PremiumContentTypes, Map<String, List<String>>> contentHeaders = {};
  late AnimationController animationController = AnimationController(vsync: this, duration: Duration(seconds: 20));
  TextEditingController headerTxCtrl = TextEditingController();
  TextEditingController subHeaderTxCtrl = TextEditingController();


  void getContentHeaders() {
    if (!mounted || !context.mounted) return;
    //Debug.log("getContentHeaders");

    manager.getPremiumContent().then((content) {
      if (content == null) return;

      contentHeaders.clear();
      for (final t in content.entries) {
        contentHeaders[t.key] = {};
        for (final h in t.value.entries) {
          contentHeaders[t.key]![h.key] = [];
          for (final sh in h.value.keys) {
            contentHeaders[t.key]![h.key]!.add(sh);
          }
        }
      }

      if (mounted) setState(() {});
    });
  }


  @override
  void initState() {
    super.initState();
    //Debug.log("InitState leftBar", overrideColor: Colors.greenAccent);
    getContentHeaders();
  }

  @override
  Widget build(BuildContext context) {
    isCondensed = widget.isCondensed;
    
    final showPremiumContent = contentHeaders.isNotEmpty && (AuthService.loginType == LoginType.kAdmin || AuthService.loginType == LoginType.kPatient);
    
    return ExcludeFocusTraversal(
      child: MyCard(
        paddingAll: 0,
        borderRadiusAll: 12,
        shadow: MyShadow(position: MyShadowPosition.centerRight, elevation: 1),
        child: AnimatedContainer(
          width: isCondensed ? 70 : 270,
          curve: Curves.easeInOut,
          decoration: BoxDecoration(color: leftBarTheme.background, borderRadius: BorderRadius.circular(12)),
          duration: const Duration(milliseconds: 200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: MySpacing.all(12),
                child: InkWell(
                  //onTap: () => Get.toNamed('/home'),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.isCondensed) Image.asset(Images.logoSmall, height: 44, fit: BoxFit.cover),
                      if (!widget.isCondensed)
                        Flexible(
                          fit: FlexFit.loose,
                          child: Image.asset(Images.logoMedium, height: 110, fit: BoxFit.cover),
                          /*MyText.displayMedium(
                            "Medicars",
                            style: GoogleFonts.raleway(fontSize: 24, fontWeight: FontWeight.w800, color: contentTheme.primary, letterSpacing: .5),
                            maxLines: 1,
                          ),*/
                        )
                    ],
                  ),
                ),
              ),
              Expanded(
                  child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MySpacing.height(12),
                      if (AuthService.loginType == LoginType.kNone)
                        LabelWidget(isCondensed: isCondensed, label: "Client App"),
                      if (AuthService.loginType == LoginType.kNone)
                        NavigationItem(iconData: LucideIcons.house, title: "Home", isCondensed: isCondensed, route: '/home'),
                      if (AuthService.loginType == LoginType.kNone)
                        MenuWidget(
                          iconData: LucideIcons.notepad_text,
                          isCondensed: isCondensed,
                          title: "Appointment",
                          children: [
                            MenuItem(title: "Book", isCondensed: isCondensed, route: '/appointment_book'),
                            MenuItem(title: "Edit", isCondensed: isCondensed, route: '/appointment_edit'),
                          ],
                        ),
                      if (AuthService.loginType == LoginType.kNone)
                        MenuWidget(
                          iconData: LucideIcons.tablets,
                          isCondensed: isCondensed,
                          title: "Pharmacy",
                          children: [
                            MenuItem(title: "List", isCondensed: isCondensed, route: '/pharmacy_list'),
                            MenuItem(title: "Detail", isCondensed: isCondensed, route: '/detail'),
                            MenuItem(title: "Cart", isCondensed: isCondensed, route: '/cart'),
                            MenuItem(title: "Checkout", isCondensed: isCondensed, route: '/pharmacy_checkout'),
                          ],
                        ),
                      if (AuthService.loginType == LoginType.kNone)
                        NavigationItem(iconData: LucideIcons.messages_square, title: "Chat", isCondensed: isCondensed, route: '/chat'),
                      if (AuthService.loginType == LoginType.kNone)
                        MySpacing.height(16),
                      if (AuthService.loginType == LoginType.kAdmin || AuthService.loginType == LoginType.kDoctor)
                        LabelWidget(isCondensed: isCondensed, label: "Admin Panel"),
                      if (AuthService.loginType == LoginType.kNone)
                        NavigationItem(iconData: LucideIcons.layout_dashboard, title: "Dashboard", isCondensed: isCondensed, route: '/dashboard'),
                      if (AuthService.loginType == LoginType.kDoctor)
                        MenuWidget(
                          iconData: LucideIcons.user_plus,
                          isCondensed: isCondensed,
                          title: "Tratantes",
                          children: [
                            MenuItem(title: "Listado", isCondensed: isCondensed, route: '/doctor/patient/list'),
                            MenuItem(title: "Registrar", isCondensed: isCondensed, route: '/doctor/patient/add'),
                          ],
                        ),
                      if (AuthService.loginType == LoginType.kDoctor)
                        MenuWidget(
                          iconData: LucideIcons.user_plus,
                          isCondensed: isCondensed,
                          title: "Secretari@",
                          children: [
                            MenuItem(title: "Registrar", isCondensed: isCondensed, route: '/doctor/secretary/add'),
                            MenuItem(title: "Editar", isCondensed: isCondensed, route: '/doctor/secretary/edit'),
                            MenuItem(title: "Detalles", isCondensed: isCondensed, route: '/doctor/secretary/detail'),
                          ],
                        ),
                      if (AuthService.loginType == LoginType.kDoctor)
                        MenuWidget(
                          iconData: LucideIcons.calendar,
                          isCondensed: isCondensed,
                          title: "Citas",
                          children: [
                            MenuItem(title: "Listado", isCondensed: isCondensed, route: '/doctor/dates/list'),
                          ],
                        ),
                      if (AuthService.loginType == LoginType.kSecretary)
                        MenuWidget(
                          iconData: LucideIcons.user_plus,
                          isCondensed: isCondensed,
                          title: "Tratantes",
                          children: [
                            MenuItem(title: "Listado", isCondensed: isCondensed, route: '/secretary/patient/list'),
                          ],
                        ),
                      if (AuthService.loginType == LoginType.kSecretary)
                        MenuWidget(
                          iconData: LucideIcons.calendar,
                          isCondensed: isCondensed,
                          title: "Citas",
                          children: [
                            MenuItem(title: "Registrar", isCondensed: isCondensed, route: '/secretary/dates/add'),
                            MenuItem(title: "Listado", isCondensed: isCondensed, route: '/secretary/dates/list'),
                          ],
                        ),
                      if (AuthService.loginType == LoginType.kAdmin)
                        MenuWidget(
                          iconData: LucideIcons.briefcase_medical,
                          isCondensed: isCondensed,
                          title: "Médicos",
                          children: [
                            MenuItem(title: "Listado", isCondensed: isCondensed, route: '/panel/doctor/list'),
                            MenuItem(title: "Suscripciones", isCondensed: isCondensed, route: '/panel/doctor_subs/list'),
                            MenuItem(title: "Registrar", isCondensed: isCondensed, route: '/panel/doctor/add'),
                          ],
                        ),
                      if (AuthService.loginType == LoginType.kPatient)
                        MenuWidget(
                          iconData: LucideIcons.calendar,
                          isCondensed: isCondensed,
                          title: "Citas",
                          children: [
                            MenuItem(title: "Próximas citas", isCondensed: isCondensed, route: '/patient/dates/list'),
                          ],
                        ),
                      if (AuthService.loginType == LoginType.kPatient)
                        MenuWidget(
                          iconData: LucideIcons.pill_bottle,
                          isCondensed: isCondensed,
                          title: "Mis Recetas",
                          children: [
                            MenuItem(title: "Médico ${(AuthService.loggedUserData as PatientListModel).owner.fullName}", isCondensed: isCondensed, route: '/patient/prescription/list'),
                          ],
                        ),
                      if (AuthService.loginType == LoginType.kPatient)
                        MenuWidget(
                          iconData: LucideIcons.heart_pulse,
                          isCondensed: isCondensed,
                          title: "Salud",
                          children: [
                            MenuItem(title: "Registro Diario", isCondensed: isCondensed, route: '/patient/record/daily'),
                            MenuItem(title: "Mis Mediciones", isCondensed: isCondensed, route: '/patient/record/history'),
                          ],
                        ),

                      if (showPremiumContent && !isCondensed)
                        Padding(
                          padding: MySpacing.fromLTRB(20, 20, 20, 0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    Container(height: 1.5, color: Colors.orange,),
                                    MySpacing.height(3.0),
                                    Container(height: 1.5, color: Colors.orange,),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: MySpacing.horizontal(10),
                                child: MyText.titleSmall("Contenido Premium", textAlign: TextAlign.center, fontWeight: 800, color: Colors.orange,),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    Container(height: 1.5, color: Colors.orange,),
                                    MySpacing.height(3.0),
                                    Container(height: 1.5, color: Colors.orange,),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (showPremiumContent && isCondensed)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(5.0, 20.0, 5.0, 0.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    Container(height: 1.0, color: Colors.black,),
                                    MySpacing.height(3.0),
                                    Container(height: 1.0, color: Colors.black,),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: MySpacing.horizontal(5),
                                child: Icon(LucideIcons.crown, color: (widget.premium?? false) ? Colors.amber : Colors.black45,),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    Container(height: 1.0, color: Colors.black,),
                                    MySpacing.height(3.0),
                                    Container(height: 1.0, color: Colors.black,),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (showPremiumContent && !isCondensed && widget.premium != null)
                        Padding(
                          padding: MySpacing.fromLTRB(20, 10, 20, 0),
                          child: Center(
                            child: MyText.bodyMedium(
                              widget.premium! ?
                              "Premium Activo  ${dateFormatter.format(widget.premiumEnd!)}" :
                              "Premium Inactivo", textAlign: TextAlign.center,
                              fontWeight: 700,
                              color: widget.premium! ?
                              Colors.deepOrangeAccent : Colors.black45,
                            ),
                          ),
                        ),
                      if (showPremiumContent && !isCondensed)
                        Padding(
                          padding: MySpacing.fromLTRB(20, 10, 20, 0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: List.generate(
                                    8, (i) =>
                                      MyContainer(
                                        width: 3.0, height: 3.0,
                                        shape: BoxShape.circle,
                                        color: Colors.black,
                                      ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: MySpacing.horizontal(15),
                                child: MyText.titleSmall("Posts", textAlign: TextAlign.center, fontWeight: 700,),
                              ),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: List.generate(
                                    8, (i) =>
                                      MyContainer(
                                        width: 3.0, height: 3.0,
                                        shape: BoxShape.circle,
                                        color: Colors.black,
                                      ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (showPremiumContent && isCondensed)
                        Padding(
                          padding: MySpacing.fromLTRB(6, 10, 6, 0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: List.generate(
                                    2, (i) =>
                                      MyContainer(
                                        width: 3.0, height: 3.0,
                                        shape: BoxShape.circle,
                                        color: Colors.black,
                                      ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: MySpacing.horizontal(6),
                                child: Icon(LucideIcons.images),
                              ),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: List.generate(
                                    2, (i) =>
                                      MyContainer(
                                        width: 3.0, height: 3.0,
                                        shape: BoxShape.circle,
                                        color: Colors.black,
                                      ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (showPremiumContent)
                        for (final header in (contentHeaders[PremiumContentTypes.kPosts]?.entries?? <MapEntry<String, List<String>>>[]))
                          MenuWidget(
                            iconData: LucideIcons.crown,
                            isCondensed: isCondensed,
                            title: header.key,
                            endingButtons: [
                              if (AuthService.loginType == LoginType.kAdmin)
                                MenuButton(title: "Añadir", isCondensed: isCondensed, iconData: LucideIcons.badge_plus, onTap: () {
                                  _showAddContentSubHeaderDialog(PremiumContentTypes.kPosts, header.key);
                                },),
                            ],
                            children: [
                              for (final subHeader in header.value)
                                MenuItem(
                                  title: subHeader, isCondensed: isCondensed,
                                  route: '/${AuthService.loginType == LoginType.kAdmin ? "panel" : "patient"}'
                                      '/premium/posts/'
                                      '${Uri.encodeComponent(header.key)}/'
                                      '${Uri.encodeComponent(subHeader)}/list',
                                ),
                            ],
                          ),
                      if (showPremiumContent && !isCondensed)
                        Padding(
                          padding: MySpacing.fromLTRB(20, 20, 20, 0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: List.generate(
                                    8, (i) =>
                                      MyContainer(
                                        width: 3.0, height: 3.0,
                                        shape: BoxShape.circle,
                                        color: Colors.black,
                                      ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: MySpacing.horizontal(15),
                                child: MyText.titleSmall("Videos", textAlign: TextAlign.center, fontWeight: 700,),
                              ),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: List.generate(
                                    8, (i) =>
                                      MyContainer(
                                        width: 3.0, height: 3.0,
                                        shape: BoxShape.circle,
                                        color: Colors.black,
                                      ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (showPremiumContent && isCondensed)
                        Padding(
                          padding: MySpacing.fromLTRB(6, 10, 6, 0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: List.generate(
                                    2, (i) =>
                                      MyContainer(
                                        width: 3.0, height: 3.0,
                                        shape: BoxShape.circle,
                                        color: Colors.black,
                                      ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: MySpacing.horizontal(6),
                                child: Icon(LucideIcons.video),
                              ),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: List.generate(
                                    2, (i) =>
                                      MyContainer(
                                        width: 3.0, height: 3.0,
                                        shape: BoxShape.circle,
                                        color: Colors.black,
                                      ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (showPremiumContent)
                        for (final header in (contentHeaders[PremiumContentTypes.kVideos]?.entries?? <MapEntry<String, List<String>>>[]))
                          MenuWidget(
                            iconData: LucideIcons.crown,
                            isCondensed: isCondensed,
                            title: header.key,
                            endingButtons: [
                              if (AuthService.loginType == LoginType.kAdmin)
                                MenuButton(title: "Añadir", isCondensed: isCondensed, iconData: LucideIcons.badge_plus, onTap: () {
                                  _showAddContentSubHeaderDialog(PremiumContentTypes.kVideos, header.key);
                                },),
                            ],
                            children: [
                              for (final subHeader in header.value)
                                MenuItem(
                                  title: subHeader, isCondensed: isCondensed,
                                  route: '/${AuthService.loginType == LoginType.kAdmin ? "panel" : "patient"}'
                                      '/premium/videos/'
                                      '${Uri.encodeComponent(header.key)}/'
                                      '${Uri.encodeComponent(subHeader)}/list',
                                ),
                            ],
                          ),
                      if (showPremiumContent && !isCondensed)
                        Padding(
                          padding: MySpacing.fromLTRB(20, 20, 20, 0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: List.generate(
                                    8, (i) =>
                                      MyContainer(
                                        width: 3.0, height: 3.0,
                                        shape: BoxShape.circle,
                                        color: Colors.black,
                                      ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: MySpacing.horizontal(15),
                                child: MyText.titleSmall("Libros", textAlign: TextAlign.center, fontWeight: 700,),
                              ),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: List.generate(
                                    8, (i) =>
                                      MyContainer(
                                        width: 3.0, height: 3.0,
                                        shape: BoxShape.circle,
                                        color: Colors.black,
                                      ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (showPremiumContent && isCondensed)
                        Padding(
                          padding: MySpacing.fromLTRB(6, 10, 6, 0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: List.generate(
                                    2, (i) =>
                                      MyContainer(
                                        width: 3.0, height: 3.0,
                                        shape: BoxShape.circle,
                                        color: Colors.black,
                                      ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: MySpacing.horizontal(6),
                                child: Icon(LucideIcons.book),
                              ),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: List.generate(
                                    2, (i) =>
                                      MyContainer(
                                        width: 3.0, height: 3.0,
                                        shape: BoxShape.circle,
                                        color: Colors.black,
                                      ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (showPremiumContent)
                        for (final header in (contentHeaders[PremiumContentTypes.kBooks]?.entries?? <MapEntry<String, List<String>>>[]))
                          MenuWidget(
                            iconData: LucideIcons.crown,
                            isCondensed: isCondensed,
                            title: header.key,
                            endingButtons: [
                              if (AuthService.loginType == LoginType.kAdmin)
                                MenuButton(title: "Añadir", isCondensed: isCondensed, iconData: LucideIcons.badge_plus, onTap: () {
                                  _showAddContentSubHeaderDialog(PremiumContentTypes.kBooks, header.key);
                                },),
                            ],
                            children: [
                              for (final subHeader in header.value)
                                MenuItem(
                                  title: subHeader, isCondensed: isCondensed,
                                  route: '/${AuthService.loginType == LoginType.kAdmin ? "panel" : "patient"}'
                                      '/premium/books/'
                                      '${Uri.encodeComponent(header.key)}/'
                                      '${Uri.encodeComponent(subHeader)}/list',
                                ),
                            ],
                          ),

                      if (AuthService.loginType == LoginType.kNone)
                        MenuWidget(
                          iconData: LucideIcons.notepad_text,
                          isCondensed: isCondensed,
                          title: "Appointment",
                          children: [
                            MenuItem(title: "List", isCondensed: isCondensed, route: '/admin/appointment_list'),
                            MenuItem(title: "Schedule", isCondensed: isCondensed, route: '/admin/appointment_scheduling'),
                            MenuItem(title: "Book", isCondensed: isCondensed, route: '/admin/appointment_book'),
                            MenuItem(title: "Edit", isCondensed: isCondensed, route: '/admin/appointment_edit'),
                          ],
                        ),
                      if (AuthService.loginType == LoginType.kNone)
                        NavigationItem(iconData: LucideIcons.wallet, title: "Wallet", isCondensed: isCondensed, route: '/admin/wallet'),
                      if (AuthService.loginType == LoginType.kNone)
                        NavigationItem(iconData: LucideIcons.settings, title: "Setting", isCondensed: isCondensed, route: '/admin/setting'),
                      if (AuthService.loginType == LoginType.kNone)
                        labelWidget("UI"),
                      if (AuthService.loginType == LoginType.kNone)
                        MenuWidget(
                          iconData: LucideIcons.key_round,
                          isCondensed: isCondensed,
                          title: "Auth",
                          children: [
                            MenuItem(title: 'Login', route: '/auth/login', isCondensed: widget.isCondensed),
                            MenuItem(title: 'Register Password', route: '/auth/register_account', isCondensed: widget.isCondensed),
                            MenuItem(title: 'Forgot Password', route: '/auth/forgot_password', isCondensed: widget.isCondensed),
                            MenuItem(title: 'Reset Password', route: '/auth/reset_password', isCondensed: widget.isCondensed),
                          ],
                        ),
                      if (AuthService.loginType == LoginType.kNone)
                        MenuWidget(
                          iconData: LucideIcons.component,
                          isCondensed: isCondensed,
                          title: "Widgets",
                          children: [
                            MenuItem(title: "Buttons", route: '/widget/buttons', isCondensed: widget.isCondensed),
                            MenuItem(title: "Toast", route: '/widget/toast', isCondensed: widget.isCondensed),
                            MenuItem(title: "Modal", route: '/widget/modal', isCondensed: widget.isCondensed),
                            MenuItem(title: "Tabs", route: '/widget/tabs', isCondensed: widget.isCondensed),
                            MenuItem(title: "Cards", route: '/widget/cards', isCondensed: widget.isCondensed),
                            MenuItem(title: "Loaders", route: '/widget/loader', isCondensed: widget.isCondensed),
                            MenuItem(title: "Dialog", route: '/widget/dialog', isCondensed: widget.isCondensed),
                            MenuItem(title: "Carousels", route: '/widget/carousel', isCondensed: widget.isCondensed),
                            MenuItem(title: "Drag & Drop", route: '/widget/drag_n_drop', isCondensed: widget.isCondensed),
                            MenuItem(title: "Notifications", route: '/widget/notification', isCondensed: widget.isCondensed),
                          ],
                        ),
                      if (AuthService.loginType == LoginType.kNone)
                        MenuWidget(
                          iconData: LucideIcons.book_open_check,
                          title: "Form",
                          isCondensed: isCondensed,
                          children: [
                            MenuItem(title: "Basic Input", route: '/form/basic_input', isCondensed: widget.isCondensed),
                            MenuItem(title: "Custom Option", route: '/form/custom_option', isCondensed: widget.isCondensed),
                            //MenuItem(title: "Editor", route: '/form/editor', isCondensed: widget.isCondensed),
                            MenuItem(title: "File Upload", route: '/form/file_upload', isCondensed: widget.isCondensed),
                            MenuItem(title: "Slider", route: '/form/slider', isCondensed: widget.isCondensed),
                            MenuItem(title: "Validation", route: '/form/validation', isCondensed: widget.isCondensed),
                            MenuItem(title: "Mask", route: '/form/mask', isCondensed: widget.isCondensed),
                          ],
                        ),
                      if (AuthService.loginType == LoginType.kNone)
                        MenuWidget(
                          iconData: LucideIcons.shield_alert,
                          isCondensed: isCondensed,
                          title: "Error",
                          children: [
                            MenuItem(title: 'Error 404', route: '/error/404', isCondensed: widget.isCondensed),
                            MenuItem(title: 'Error 500', route: '/error/500', isCondensed: widget.isCondensed),
                            MenuItem(title: 'Coming Soon', route: '/error/coming_soon', isCondensed: widget.isCondensed),
                          ],
                        ),
                      if (AuthService.loginType == LoginType.kNone)
                        MenuWidget(
                          iconData: LucideIcons.book_open,
                          isCondensed: isCondensed,
                          title: "Extra Pages",
                          children: [
                            MenuItem(title: 'FAQs', route: '/extra/faqs', isCondensed: widget.isCondensed),
                            MenuItem(title: 'Pricing', route: '/extra/pricing', isCondensed: widget.isCondensed),
                            MenuItem(title: 'Time Line', route: '/extra/time_line', isCondensed: widget.isCondensed),
                          ],
                        ),
                      if (AuthService.loginType == LoginType.kNone)
                        NavigationItem(
                          iconData: LucideIcons.table,
                          title: "Basic Table",
                          isCondensed: isCondensed,
                          route: '/other/basic_table',
                        ),
                      MySpacing.height(20),
                      /*if (!isCondensed)
                        InkWell(
                          onTap: () => UrlService.goToPagger(),
                          child: Padding(
                              padding: MySpacing.x(16),
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8), // color: contentTheme.primary.withAlpha(40),
                                    gradient: LinearGradient(
                                        colors: const [Colors.deepPurple, Colors.lightBlue], begin: Alignment.topLeft, end: Alignment.bottomRight)),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.white.withAlpha(32),
                                      ),
                                      child: Icon(LucideIcons.layout_dashboard, color: Colors.white),
                                    ),
                                    SizedBox(height: 16),
                                    MyText.bodyLarge("Ready to use page for any Flutter Project", color: Colors.white, textAlign: TextAlign.center),
                                    SizedBox(height: 16),
                                    Container(
                                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: Colors.white),
                                      child: MyText.bodyMedium("Free Download", color: Colors.black, fontWeight: 600),
                                    )
                                  ],
                                ),
                              )),
                        ),*/
                      /*if (isCondensed)
                        InkWell(
                          onTap: () => UrlService.goToPagger(),
                          child: Padding(
                              padding: MySpacing.x(16),
                              child: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4), // color: contentTheme.primary.withAlpha(40),
                                    gradient: LinearGradient(
                                        colors: const [Colors.deepPurple, Colors.lightBlue], begin: Alignment.topLeft, end: Alignment.bottomRight)),
                                child: Icon(LucideIcons.download, color: Colors.white, size: 20),
                              )),
                        ),*/
                      MySpacing.height(20),
                    ],
                  ),
                ),
              ))
            ],
          ),
        ),
      ),
    );
  }

  Widget labelWidget(String label) {
    return isCondensed
        ? MySpacing.empty()
        : Container(
            padding: MySpacing.xy(24, 8),
            child: MyText.labelSmall(label.toUpperCase(),
                color: leftBarTheme.labelColor, muted: true, maxLines: 1, overflow: TextOverflow.clip, fontWeight: 700),
          );
  }


  void _showAddContentSubHeaderDialog(PremiumContentTypes type, String header) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          shape: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          child: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: MySpacing.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: MyText.labelLarge(
                          'Añadir categoría a $header',
                          fontWeight: 600,
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        child: Icon(
                          LucideIcons.x,
                          size: 20,
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 0, thickness: 1),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: commonTextField(
                    title: "Nombre", hintText: "Nombre de la Categoría",
                    teController: subHeaderTxCtrl, length: 64
                  ),
                ),

                Divider(height: 0, thickness: 1),
                Padding(
                  padding: MySpacing.only(right: 20, bottom: 12, top: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      MyButton(
                        onPressed: () => Get.back(),
                        elevation: 0,
                        borderRadiusAll: 8,
                        padding: MySpacing.xy(20, 16),
                        backgroundColor: colorScheme.secondaryContainer,
                        child: MyText.labelMedium(
                          "Cancelar",
                          fontWeight: 600,
                          color: colorScheme.onSecondaryContainer,
                        ),
                      ),
                      MySpacing.width(16),
                      MyButton(
                        onPressed: () async {
                          if (subHeaderTxCtrl.text.isNotEmpty) {
                            final errors = await manager.registerPremiumContentHeader(type, subHeaderTxCtrl.text, header);
                            if (errors != null) {
                              for (final e in errors.entries) {
                                if (e.key == "server") {
                                  showSnackBar(e.value, ContentThemeColor.danger.color, ContentThemeColor.danger.onColor);
                                }
                              }
                            }
                            else {
                              showSnackBar("Categoría añadida con éxito", ContentThemeColor.success.color, ContentThemeColor.success.onColor);
                            }
                            Debug.log("AddHeader leftBar", overrideColor: Colors.greenAccent);
                            getContentHeaders();
                            Get.back();
                          }
                          else {
                            showSnackBar("Falta nombre de categoría", ContentThemeColor.danger.color, ContentThemeColor.danger.onColor);
                          }
                        },
                        elevation: 0,
                        borderRadiusAll: 8,
                        padding: MySpacing.xy(20, 16),
                        backgroundColor: colorScheme.primary,
                        child: MyText.labelMedium(
                          "Guardar",
                          fontWeight: 600,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showSnackBar(String text, Color backgroundColor, Color color) {
    Duration duration = Duration(seconds: 3);

    SnackBar snackBar = SnackBar(
      width: null,
      behavior: SnackBarBehavior.fixed,
      duration: duration,
      showCloseIcon: true,
      closeIconColor: color,
      animation: Tween<double>(begin: 0, end: 300).animate(animationController),
      content: MyText.labelLarge(
        text,
        color: color,
      ),
      backgroundColor: backgroundColor,
    );
    ScaffoldMessenger.of(Get.context!).hideCurrentSnackBar();
    ScaffoldMessenger.of(Get.context!).showSnackBar(snackBar);
  }



  Widget commonTextField({
    String? title, String? hintText, bool readOnly = false,
    String? Function(String?)? validator, Widget? prefixIcon,
    void Function()? onTap, TextEditingController? teController,
    bool integer = false, bool floatingPoint = false, int? length}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText.labelMedium(title ?? "", fontWeight: 600, muted: true),
        MySpacing.height(8),
        TextFormField(
          validator: validator,
          readOnly: readOnly,
          onTap: onTap ?? () {},
          controller: teController,
          keyboardType: integer ? TextInputType.phone : null,
          maxLength: length != null ? (length + (!integer && floatingPoint ? 3 : 0)) : null,
          inputFormatters: integer ? <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))]
              : (floatingPoint ? <TextInputFormatter>[FloatingPointTextInputFormatter(maxDigitsBeforeDecimal: length, maxDigitsAfterDecimal: 2)] : null),
          style: MyTextStyle.bodySmall(),
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            hintText: hintText,
            counterText: "",
            hintStyle: MyTextStyle.bodySmall(fontWeight: 600, muted: true),
            isCollapsed: true,
            isDense: true,
            prefixIcon: prefixIcon,
            contentPadding: MySpacing.all(16),
          ),
        ),
      ],
    );
  }
}

class LabelWidget extends StatefulWidget {
  final bool isCondensed;
  final String label;

  const LabelWidget({super.key, required this.isCondensed, required this.label});

  @override
  State<LabelWidget> createState() => _LabelWidgetState();
}

class _LabelWidgetState extends State<LabelWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.isCondensed) {
      return SizedBox();
    }
    return Container(margin: MySpacing.fromLTRB(16, 0, 16, 8), child: MyText.bodySmall(widget.label, muted: true, fontWeight: 600));
  }
}

class MenuWidget extends StatefulWidget {
  final IconData iconData;
  final String title;
  final bool isCondensed;
  final bool active;
  final List<MenuItem> children;
  final List<MenuButton> endingButtons;

  const MenuWidget({super.key, required this.iconData, required this.title, this.isCondensed = false, this.active = false, this.children = const [], this.endingButtons = const []});

  @override
  State<MenuWidget> createState() => _MenuWidgetState();
}

class _MenuWidgetState extends State<MenuWidget> with UIMixin, SingleTickerProviderStateMixin {
  bool isHover = false;
  bool isActive = false;
  late Animation<double> _iconTurns;
  late AnimationController _controller;
  bool popupShowing = true;
  Function? hideFn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _iconTurns = _controller.drive(Tween<double>(begin: 0.0, end: 0.5).chain(CurveTween(curve: Curves.easeIn)));
    LeftbarObserver.attachListener(widget.title, onChangeMenuActive);
  }

  void onChangeMenuActive(String key) {
    if (key != widget.title) {
      onChangeExpansion(false);
    }
  }

  void onChangeExpansion(bool value) {
    isActive = value;
    if (isActive) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    var route = UrlService.getCurrentUrl();
    isActive = widget.children.any((element) => element.route == route);
    onChangeExpansion(isActive);
    if (hideFn != null) {
      hideFn!();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isCondensed) {
      return CustomPopupMenu(
        backdrop: true,
        show: popupShowing,
        hideFn: (hide) => hideFn = hide,
        onChange: (value) => popupShowing = value,
        placement: CustomPopupMenuPlacement.right,
        menu: MouseRegion(
          cursor: SystemMouseCursors.click,
          onHover: (event) => setState(() {
            isHover = true;
          }),
          onExit: (event) => setState(() {
            isHover = false;
          }),
          child: MyContainer.transparent(
            margin: MySpacing.fromLTRB(16, 0, 16, 8),
            color: isActive || isHover ? leftBarTheme.activeItemBackground : Colors.transparent,
            padding: MySpacing.all(8),
            borderRadiusAll: 12,
            child: Center(
              child: Icon(widget.iconData, color: (isHover || isActive) ? leftBarTheme.activeItemColor : leftBarTheme.onBackground, size: 20),
            ),
          ),
        ),
        menuBuilder: (_) => MyContainer(
          paddingAll: 8,
          borderRadiusAll: 12,
          width: 250,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: widget.children.map<Widget>((e) => e).toList()..addAll(widget.endingButtons)),
        ),
      );
    } else {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        onHover: (event) => setState(() {
          isHover = true;
        }),
        onExit: (event) => setState(() {
          isHover = false;
        }),
        child: MyContainer.transparent(
          margin: MySpacing.fromLTRB(24, 0, 16, 0),
          paddingAll: 0,
          child: ListTileTheme(
            enableFeedback: false,
            contentPadding: const EdgeInsets.all(0),
            dense: true,
            horizontalTitleGap: 0.0,
            child: ExpansionTile(
                tilePadding: MySpacing.zero,
                initiallyExpanded: isActive,
                maintainState: true,
                onExpansionChanged: (value) {
                  LeftbarObserver.notifyAll(widget.title);
                  onChangeExpansion(value);
                },
                trailing: RotationTransition(
                  turns: _iconTurns,
                  child: Icon(LucideIcons.chevron_down, size: 18, color: leftBarTheme.onBackground),
                ),
                iconColor: leftBarTheme.activeItemColor,
                childrenPadding: MySpacing.x(12),
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(widget.iconData, size: 20, color: isHover || isActive ? leftBarTheme.activeItemColor : leftBarTheme.onBackground),
                    MySpacing.width(18),
                    Expanded(
                      child: MyText.labelLarge(widget.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.start,
                          color: isHover || isActive ? leftBarTheme.activeItemColor : leftBarTheme.onBackground),
                    ),
                  ],
                ),
                collapsedBackgroundColor: Colors.transparent,
                shape: const RoundedRectangleBorder(side: BorderSide(color: Colors.transparent)),
                backgroundColor: Colors.transparent,
                children: widget.children.map<Widget>((e) => e).toList()..addAll(widget.endingButtons)),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
    LeftbarObserver.detachListener(widget.title);
  }
}

class MenuItem extends StatefulWidget {
  final IconData? iconData;
  final String title;
  final bool isCondensed;
  final String? route;

  const MenuItem({
    super.key,
    this.iconData,
    required this.title,
    this.isCondensed = false,
    this.route,
  });

  @override
  State<MenuItem> createState() => _MenuItemState();
}

class _MenuItemState extends State<MenuItem> with UIMixin {
  bool isHover = false;

  @override
  Widget build(BuildContext context) {
    bool isActive = UrlService.getCurrentUrl() == widget.route;
    return GestureDetector(
      onTap: () {
        if (widget.route != null) {
          print(widget.route!);
          Get.toNamed(widget.route!);
        }
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onHover: (event) => setState(() {
          isHover = true;
        }),
        onExit: (event) => setState(() {
          isHover = false;
        }),
        child: MyContainer.transparent(
          margin: MySpacing.fromLTRB(4, 0, 8, 4),
          color: isActive || isHover ? leftBarTheme.activeItemBackground : Colors.transparent,
          width: MediaQuery.of(context).size.width,
          padding: MySpacing.xy(18, 7),
          borderRadiusAll: 12,
          child: Row(
            children: [
              if (widget.iconData != null)
                Icon(widget.iconData, size: 15.0)
              else
                MyText.bodySmall(
                  widget.isCondensed ? " -" : " - ",
                  overflow: TextOverflow.clip,
                  maxLines: 2,
                  textAlign: TextAlign.left,
                  fontSize: 12.5,
                  color: isActive || isHover ? leftBarTheme.activeItemColor : leftBarTheme.onBackground,
                  fontWeight: isActive || isHover ? 600 : 500,
                ),
              MySpacing.width(4.0),
              SizedBox(
                width: 135.0,
                child: MyText.bodySmall(
                  widget.title,
                  overflow: TextOverflow.clip,
                  maxLines: 2,
                  textAlign: TextAlign.left,
                  fontSize: 12.5,
                  color: isActive || isHover ? leftBarTheme.activeItemColor : leftBarTheme.onBackground,
                  fontWeight: isActive || isHover ? 600 : 500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MenuButton extends StatefulWidget {
  final IconData? iconData;
  final String title;
  final bool isCondensed;
  final void Function()? onTap;

  const MenuButton({
    super.key,
    this.iconData,
    required this.title,
    this.isCondensed = false,
    this.onTap,
  });

  @override
  State<MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<MenuButton> with UIMixin {
  bool isHover = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.onTap != null) {
          widget.onTap!();
        }
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onHover: (event) => setState(() {
          isHover = true;
        }),
        onExit: (event) => setState(() {
          isHover = false;
        }),
        child: MyContainer.transparent(
          margin: MySpacing.fromLTRB(4, 0, 8, 4),
          color: isHover ? leftBarTheme.activeItemBackground : Colors.transparent,
          width: MediaQuery.of(context).size.width,
          padding: MySpacing.xy(18, 7),
          borderRadiusAll: 12,
          child: Row(
            children: [
              if (widget.iconData != null)
                Icon(widget.iconData, size: 15.0)
              else
                MyText.bodySmall(
                  widget.isCondensed ? " -" : " - ",
                  overflow: TextOverflow.clip,
                  maxLines: 2,
                  textAlign: TextAlign.left,
                  fontSize: 12.5,
                  color: isHover ? leftBarTheme.activeItemColor : leftBarTheme.onBackground,
                  fontWeight: isHover ? 600 : 500,
                  muted: true,
                ),
              MySpacing.width(4.0),
              MyText.bodySmall(
                widget.title,
                overflow: TextOverflow.clip,
                maxLines: 2,
                textAlign: TextAlign.left,
                fontSize: 12.5,
                color: isHover ? leftBarTheme.activeItemColor : leftBarTheme.onBackground,
                fontWeight: isHover ? 600 : 500,
                muted: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NavigationItem extends StatefulWidget {
  final IconData? iconData;
  final String title;
  final bool isCondensed;
  final String? route;

  const NavigationItem({super.key, this.iconData, required this.title, this.isCondensed = false, this.route});

  @override
  State<NavigationItem> createState() => _NavigationItemState();
}

class _NavigationItemState extends State<NavigationItem> with UIMixin {
  bool isHover = false;

  @override
  Widget build(BuildContext context) {
    bool isActive = UrlService.getCurrentUrl() == widget.route;
    return GestureDetector(
      onTap: () {
        if (widget.route != null) {
          Get.toNamed(widget.route!);
          MyRouter.pushReplacementNamed(context, widget.route!, arguments: 1);
        }
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onHover: (event) => setState(() {
          isHover = true;
        }),
        onExit: (event) => setState(() {
          isHover = false;
        }),
        child: MyContainer(
          margin: MySpacing.fromLTRB(16, 0, 16, 8),
          color: isActive || isHover ? leftBarTheme.activeItemBackground : Colors.transparent,
          paddingAll: 8,
          borderRadiusAll: 12,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (widget.iconData != null)
                Center(
                  child: Icon(widget.iconData, color: (isHover || isActive) ? leftBarTheme.activeItemColor : leftBarTheme.onBackground, size: 20),
                ),
              if (!widget.isCondensed)
                Flexible(
                  fit: FlexFit.loose,
                  child: MySpacing.width(16),
                ),
              if (!widget.isCondensed)
                Expanded(
                  flex: 3,
                  child: MyText.labelLarge(
                    widget.title,
                    overflow: TextOverflow.clip,
                    maxLines: 1,
                    color: isActive || isHover ? leftBarTheme.activeItemColor : leftBarTheme.onBackground,
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
