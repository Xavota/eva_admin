import 'package:medicare/helpers/widgets/my_text_utils.dart';
import 'package:medicare/model/drag_n_drop.dart';
import 'package:medicare/views/my_controller.dart';

class TimeLineController extends MyController {
  List<DragNDropModel> timeline = [];
  List<String> dummyTexts = List.generate(12, (index) => MyTextUtils.getDummyText(60));

  @override
  void onInit() {
    DragNDropModel.dummyList.then((value) {
      timeline = value.sublist(0, 6);
      update();
    });
    super.onInit();
  }
}
