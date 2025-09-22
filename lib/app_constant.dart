import 'package:intl/intl.dart' show DateFormat;

final DateFormat dateFormatter = DateFormat('dd/MM/yyyy');
final DateFormat shortDateFormatter = DateFormat('dd/MM');
final DateFormat timeFormatter = DateFormat('jms');
final DateFormat dateTimeFormatter = DateFormat("yyyy/MM/dd HH:mm");

final DateFormat dbDateFormatter = DateFormat('yyyy-MM-dd');
final DateFormat dbDateTimeFormatter = DateFormat("yyyy-MM-dd'T'HH:mm:ss");

class AppConstant {
  static int androidAppVersion = 2;
  static int iOSAppVersion = 2;
  static String version = "2.0.0";

  static String get appName => 'Medicare';
}
