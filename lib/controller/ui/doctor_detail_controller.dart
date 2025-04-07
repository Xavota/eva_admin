import 'package:medicare/helpers/utils/my_utils.dart';
import 'package:medicare/views/my_controller.dart';

class DoctorDetailController extends MyController{
  List<String> dummyTexts = List.generate(12, (index) => MyTextUtils.getDummyText(60));
}