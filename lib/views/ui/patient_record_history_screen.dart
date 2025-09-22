import 'dart:math' as math;

import 'package:blix_essentials/blix_essentials.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
//import 'package:fl_chart/src/extensions/gradient_extension.dart';
//import 'package:fl_chart/src/extensions/color_extension.dart';

import 'package:medicare/helpers/theme/app_themes.dart';

import 'package:medicare/app_constant.dart';

import 'package:medicare/controller/ui/patient_record_history_controller.dart';
import 'package:medicare/helpers/services/auth_services.dart';

import 'package:medicare/helpers/utils/ui_mixins.dart';

import 'package:medicare/helpers/widgets/my_breadcrumb.dart';
import 'package:medicare/helpers/widgets/my_breadcrumb_item.dart';
import 'package:medicare/helpers/widgets/my_button.dart';
import 'package:medicare/helpers/widgets/my_container.dart';
import 'package:medicare/helpers/widgets/my_flex.dart';
import 'package:medicare/helpers/widgets/my_flex_item.dart';
import 'package:medicare/helpers/widgets/my_list_extension.dart';
import 'package:medicare/helpers/widgets/my_spacing.dart';
import 'package:medicare/helpers/widgets/my_text.dart';
import 'package:medicare/helpers/widgets/responsive.dart';
import 'package:medicare/model/daily_record_model.dart';
import 'package:medicare/model/patient_list_model.dart';

import 'package:medicare/views/layout/layout.dart';
import 'package:syncfusion_flutter_core/core.dart';


class _LineDescriptor {
  const _LineDescriptor(this.name, this.values, this.color1, {this.color2, this.splitUpDownData = false, this.barCutOffY});

  final String name;
  final List<double?> values;
  final Color color1;
  final Color? color2;
  final bool splitUpDownData;
  final double? barCutOffY;
}

class _GoalLineDescriptor {
  const _GoalLineDescriptor(this.height, this.label, {this.color = Colors.red, this.alignment = Alignment.topRight});

  final double height;
  final String label;
  final Color color;
  final Alignment alignment;
}


class _BarGroupDescriptor {
  const _BarGroupDescriptor(this.name, this.values, this.color);

  final String name;
  final List<({double? toY, double? fromY})> values;
  final Color color;
}


class _CalendarDayDescriptor {
  const _CalendarDayDescriptor(this.date, {this.emotionalState, this.medication, this.exercise});

  final DateTime date;
  final EmotionalState? emotionalState;
  final bool? medication;
  final bool? exercise;
}


DateTime _getMiddleDateTime(DateTime t1, DateTime t2) {
  return t1.add(t2.difference(t1));
}


class PatientRecordHistoryScreen extends StatefulWidget {
  const PatientRecordHistoryScreen({super.key});

  @override
  State<PatientRecordHistoryScreen> createState() => _PatientRecordHistoryScreenState();
}

class _PatientRecordHistoryScreenState extends State<PatientRecordHistoryScreen> with UIMixin {
  PatientRecordHistoryController controller = Get.put(PatientRecordHistoryController());

  @override
  void initState() {
    super.initState();

    controller.calendarCurrentMonth = DateTime.now().month;
    controller.calendarCurrentYear = DateTime.now().year;

    controller.updateInfo().then((_) => setState((){}));
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      child: GetBuilder(
        init: controller,
        tag: 'patient_prescription_detail_controller',
        builder: (controller) {
          final dateSteps = List<DateTime>.generate(
            controller.timePeriodDays,
            (i) {
              return controller.minDate.add(Duration(days: i + 1));
            },
          );
          final recordHistory = controller.recordHistory;
          //final recordHistoryPair = controller.recordHistoryPair;
          final leftBorderValues = controller.getLeftBorderValues();

          final recordHistoryPair = dateSteps.mapIndexed<(DateTime, DailyRecordModel)>((i, d) {
            final index = recordHistory.indexWhere((e) => datesAreSameDay(d, e.date));
            return (
            d,
            index == -1 ?
            DailyRecordModel.empty(-1, AuthService.loggedUserData as PatientListModel, d) :
            //(i == 0 ? leftBorderValues : DailyRecordModel.empty(-1, AuthService.loggedUserData as PatientListModel, d)) :
            recordHistory[index],
            );
          }).toList();

          final bmiThresholds = controller.getBMIThresholds();

          final minValues = controller.getMinValues(leftBorderValues);
          final maxValues = controller.getMaxValues(leftBorderValues);
          final firstValues = controller.getFirstValues();
          final lastValues = controller.getLastValues();
          final weekAverageValues = controller.getWeekAverageValues();
          final averageValues = controller.getAverageValues();

          final weightVerticalGraphPadding = 10.0;
          final waistVerticalGraphPadding = 10.0;
          final sleepTimeVerticalGraphPadding = 1.0;
          final bloodPressureGraphPadding = 10.0;
          final sugarLevelVerticalGraphPadding = 10.0;
          
          
          final List<(DateTime, double?)> sleepTimeBars = [];
          final averageCount =
          controller.historyPeriod == TimePeriod.kYear ? 18 :
          (controller.historyPeriod == TimePeriod.k6Months ? 9 :
          (controller.historyPeriod == TimePeriod.k3Months ? 5 :
          (controller.historyPeriod == TimePeriod.kMonth ? 2 : 1)));
          double valueSum = 0.0;
          int sumCount = 0;
          int realSumCount = 0;
          late DateTime firstDate;
          for (final value in recordHistoryPair) {
            if (sumCount == 0) firstDate = value.$1;
            if (value.$2.sleepTime != null) {
              valueSum += value.$2.sleepTime?? 0.0;
              ++realSumCount;
            }
            ++sumCount;
            if (sumCount >= averageCount) {
              if (realSumCount == 0) {
                sleepTimeBars.add((_getMiddleDateTime(firstDate, value.$1), null));
                valueSum = 0;
                sumCount = 0;
                continue;
              }
              sleepTimeBars.add((_getMiddleDateTime(firstDate, value.$1), valueSum == 0.0 ? null : valueSum / realSumCount));
              valueSum = 0;
              sumCount = 0;
              realSumCount = 0;
            }
          }
          if (sumCount > 0) {
            sleepTimeBars.add((_getMiddleDateTime(firstDate, recordHistoryPair.last.$1), valueSum == 0.0 ? null : valueSum / sumCount));
          }


          final weightGoalLines = bmiThresholds.mapIndexed<_GoalLineDescriptor?>(
                (i, e) {
              double realHeight = e.$2;
              final lineColor = multiLerpOklab([Colors.amber, Colors.lightGreen, Colors.redAccent], i / 7);
              //Debug.log("Goal line: ${e.$1}", overrideColor: lineColor);
              return _GoalLineDescriptor(
                realHeight,
                e.$1,
                color: lineColor,
              );
            },
          ).where((e) => e != null)
              .map<_GoalLineDescriptor>((e) => e!)
              .toList();
          double? realMinWeight = minValues.weight;
          double? realMaxWeight = maxValues.weight;
          double? weightGoal = controller.loggedPatient?.weightGoal;
          if (weightGoal != null) {
            weightGoalLines.add(_GoalLineDescriptor(
              weightGoal,
              "Meta de peso",
              color: Colors.purpleAccent,
            ));
            realMinWeight = math.min(realMinWeight?? 999999.9, weightGoal);
            realMaxWeight = math.max(realMaxWeight?? 0.0, weightGoal);
          }

          final waistGoalLines = <_GoalLineDescriptor>[];
          double? realMinWaist = minValues.waist;
          double? realMaxWaist = maxValues.waist;
          double? waistGoal = controller.loggedPatient?.waistGoal;
          if (waistGoal != null) {
            waistGoalLines.add(_GoalLineDescriptor(
              waistGoal,
              "Meta de cintura",
              color: Colors.purpleAccent,
            ));
            realMinWaist = math.min(realMinWaist?? 999999.9, waistGoal);
            realMaxWaist = math.max(realMaxWaist?? 0.0, waistGoal);
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: MySpacing.x(flexSpacing),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MyText.titleMedium(
                      "Mis Mediciones",
                      fontSize: 18,
                      fontWeight: 600,
                    ),
                    MyBreadcrumb(
                      children: [
                        MyBreadcrumbItem(name: 'Tratante'),
                        MyBreadcrumbItem(name: 'Mis mediciones', active: true),
                      ],
                    ),
                  ],
                ),
              ),
              MySpacing.height(flexSpacing),
              Padding(
                padding: MySpacing.x(flexSpacing),
                child: MyContainer(
                  paddingAll: 20,
                  borderRadiusAll: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText.bodyMedium("Mis Mediciones", fontWeight: 600, muted: true),
                      MySpacing.height(20),
                      MyText.labelMedium("Periodo de Tiempo", fontWeight: 600, muted: true),
                      MySpacing.height(15),
                      Wrap(
                        spacing: 16,
                        children: TimePeriod.values.map((period) => InkWell(
                          onTap: () => controller.onPeriodChange(period),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Radio<TimePeriod>(
                                value: period,
                                activeColor: theme.colorScheme.primary,
                                groupValue: controller.historyPeriod,
                                onChanged: (value) => controller.onPeriodChange(value),
                                visualDensity: getCompactDensity,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              MySpacing.width(8),
                              MyText.labelMedium(
                                period.name.capitalize!,
                              ),
                            ],
                          ),
                        ),
                        ).toList(),
                      ),
                      if (controller.recordHistory.isNotEmpty)
                        MyFlex(
                          contentPadding: false,
                          //spacing: 10,
                          runSpacing: 20,
                          children: [
                            MyFlexItem(
                              sizes: 'lg-6',
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(child: MyText.titleLarge("            Peso", fontWeight: 800, muted: true)),
                                  MySpacing.height(10),
                                  if (minValues.weight != null)
                                    Center(
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 55.0, bottom: 10.0),
                                        child: Wrap(
                                          alignment: WrapAlignment.center,
                                          runAlignment: WrapAlignment.center,
                                          spacing: 10.0,
                                          runSpacing: 10.0,
                                          children: [
                                            MyText.bodyLarge("Peso inicial: ${firstValues.weight} Kg", fontWeight: 600,),
                                            MyText.bodyLarge("Peso final: ${lastValues.weight} Kg", fontWeight: 600,),
                                            MyText.bodyLarge("Diferencia: ${((lastValues.weight! - firstValues.weight!) * 100).round() / 100.0} Kg", fontWeight: 600,),
                                          ],
                                        ),
                                      ),
                                    ),
                                  if (realMinWeight != null)
                                    createDataGraph(
                                      height: 400.0,
                                      minY: realMinWeight - weightVerticalGraphPadding,
                                      maxY: realMaxWeight! + weightVerticalGraphPadding,
                                      minX: 0,
                                      maxX: (controller.timePeriodDays - 1).toDouble(),
                                      leftSideUnits: (value) {
                                        return MyText.labelMedium("$value Kg");
                                      },
                                      bottomUnitsInterval: math.max(recordHistoryPair.length / 10.0, 1.0),
                                      bottomSideUnits: (value) {
                                        int i = value.toInt();
                                        if (i >= recordHistoryPair.length) return Text("");
                                        return Transform.rotate(
                                          angle: -0.5,
                                          child: MyText.labelMedium(shortDateFormatter.format(recordHistoryPair[i].$1)),
                                        );
                                      },
                                      lines: [
                                        _LineDescriptor(
                                          "Peso",
                                          recordHistoryPair.mapIndexed<double?>((i, e) {
                                            return (i == 0 && e.$2.weight == null) ? leftBorderValues.weight : e.$2.weight;
                                          }).toList(),//..insert(0, leftBorderValues.weight),
                                          Colors.red,
                                          color2: Colors.green,
                                          splitUpDownData: true,
                                        ),
                                      ],
                                      goalLines: weightGoalLines,
                                      getDate: (i) => shortDateFormatter.format(dateSteps[i]),
                                      showDotInfo: (lineIndex, i) {
                                        if (i >= dateSteps.length) return false;
                                        final index = recordHistory.indexWhere((e) => datesAreSameDay(dateSteps[i], e.date));
                                        return index != -1 && recordHistory[index].weight != null;
                                      },
                                    )
                                  else
                                    Center(
                                      child: MyText.bodyLarge(
                                        "No hay mediciones de peso registrados."
                                            "\nAsegurate de registrar tu progreso diario.",
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  MySpacing.height(20),
                                  Center(child: MyText.titleLarge("            Cintura", fontWeight: 800, muted: true)),
                                  MySpacing.height(10),
                                  if (realMinWaist != null)
                                    createDataGraph(
                                      height: 400.0,
                                      minY: realMinWaist - waistVerticalGraphPadding,
                                      maxY: realMaxWaist! + waistVerticalGraphPadding,
                                      minX: 0,
                                      maxX: (controller.timePeriodDays - 1).toDouble(),
                                      leftSideUnits: (value) {
                                        return MyText.labelMedium("$value cm");
                                      },
                                      bottomUnitsInterval: math.max(recordHistoryPair.length / 10.0, 1.0),
                                      bottomSideUnits: (value) {
                                        int i = value.toInt();
                                        if (i >= recordHistoryPair.length) return Text("");
                                        return Transform.rotate(
                                          angle: -0.5,
                                          child: MyText.labelMedium(shortDateFormatter.format(recordHistoryPair[i].$1)),
                                        );
                                      },
                                      lines: [
                                        _LineDescriptor(
                                          "Cintura",
                                          recordHistoryPair.mapIndexed<double?>((i, e) {
                                            return (i == 0 && e.$2.waist == null) ? leftBorderValues.waist : e.$2.waist;
                                          }).toList(),
                                          Colors.blue,
                                        ),
                                      ],
                                      goalLines: waistGoalLines,
                                      getDate: (i) => shortDateFormatter.format(dateSteps[i]),
                                      showDotInfo: (lineIndex, i) {
                                        if (i >= dateSteps.length) return false;
                                        final index = recordHistory.indexWhere((e) => datesAreSameDay(dateSteps[i], e.date));
                                        return index != -1 && recordHistory[index].waist != null;
                                      },
                                    )
                                  else
                                    Center(
                                      child: MyText.bodyLarge(
                                        "No hay medidas de cintura registradas."
                                            "\nAsegurate de registrar tu progreso diario.",
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  MySpacing.height(20),
                                  Center(child: MyText.titleLarge("            Tiempo de Sueño", fontWeight: 800, muted: true)),
                                  MySpacing.height(10),
                                  if (minValues.sleepTime != null)
                                    Center(
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 55.0, bottom: 10.0),
                                        child: Wrap(
                                          alignment: WrapAlignment.center,
                                          runAlignment: WrapAlignment.center,
                                          spacing: 10.0,
                                          runSpacing: 10.0,
                                          children: [
                                            MyText.bodyLarge("Promedio semanal: ${weekAverageValues.sleepTime}h", fontWeight: 600,),
                                            MyText.bodyLarge("Promedio del periodo: ${averageValues.sleepTime}h", fontWeight: 600,),
                                            MyText.bodyLarge("Días promediados por valor: $averageCount", fontWeight: 600,),
                                          ],
                                        ),
                                      ),
                                    ),
                                  if (minValues.sleepTime != null)
                                    createBarGraph(
                                      height: 400.0,
                                      minY: 0,
                                      maxY: 12,
                                      barGroups: sleepTimeBars.map<_BarGroupDescriptor>((e) {
                                        return _BarGroupDescriptor("Tiempo de Sueño", [(toY: e.$2, fromY: null)], Colors.deepPurpleAccent);
                                      }).toList(),
                                      leftSideUnits: (value) {
                                        return MyText.labelMedium("$value h");
                                      },
                                      bottomUnitsInterval: math.max(recordHistoryPair.length / 10.0, 1.0),
                                      bottomSideUnits: (value) {
                                        int i = value.toInt();
                                        if (i >= recordHistoryPair.length) return Text("");
                                        return Transform.rotate(
                                          angle: -0.8,
                                          child: MyText.labelMedium(shortDateFormatter.format(sleepTimeBars[i].$1)),
                                        );
                                      },
                                      getDate: (i) => shortDateFormatter.format(sleepTimeBars[i].$1),
                                      goalLines: [
                                        _GoalLineDescriptor(8, "Sueño normal", color: Colors.green),
                                      ],

                                      getDotInfoText: (index, fromY, toY) {
                                        final date = shortDateFormatter.format(dateSteps[index]);
                                        //return '📅 $date\n📈 ${toY.toStringAsFixed(2)} h';
                                        return '📈 ${toY.toStringAsFixed(2)} h';
                                      }
                                    )
                                  else
                                    Center(
                                      child: MyText.bodyLarge(
                                        "No hay mediciones del tiempo de sueño registradas."
                                            "\Asegurate de registrar tu progreso diario.",
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            MyFlexItem(
                              sizes: 'lg-6',
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(child: MyText.titleLarge("            Presión Arterial", fontWeight: 800, muted: true)),
                                  MySpacing.height(10),
                                  if (minValues.systolicBloodPressure != null &&
                                      minValues.diastolicBloodPressure != null)
                                    createDataGraph(
                                      showLineNames: true,
                                      height: 400.0,
                                      minY: math.min(minValues.systolicBloodPressure!, minValues.diastolicBloodPressure!) - bloodPressureGraphPadding,
                                      maxY: math.max(maxValues.systolicBloodPressure!, maxValues.diastolicBloodPressure!) + bloodPressureGraphPadding,
                                      minX: 0,
                                      maxX: (controller.timePeriodDays - 1).toDouble(),
                                      leftSideUnits: (value) {
                                        return MyText.labelMedium("$value mmHg");
                                      },
                                      bottomUnitsInterval: math.max(recordHistoryPair.length / 10.0, 1.0),
                                      bottomSideUnits: (value) {
                                        int i = value.toInt();
                                        if (i >= recordHistoryPair.length) return Text("");
                                        return Transform.rotate(
                                          angle: -0.5,
                                          child: MyText.labelMedium(shortDateFormatter.format(recordHistoryPair[i].$1)),
                                        );
                                      },
                                      lines: [
                                        _LineDescriptor(
                                          "Presión sistólica",
                                          recordHistoryPair.mapIndexed<double?>((i, e) {
                                            return (i == 0 && e.$2.systolicBloodPressure == null) ? leftBorderValues.systolicBloodPressure : e.$2.systolicBloodPressure;
                                          }).toList(),
                                          Colors.pink,
                                        ),
                                        _LineDescriptor(
                                          "Presión diastólica",
                                          recordHistoryPair.mapIndexed<double?>((i, e) {
                                            return (i == 0 && e.$2.diastolicBloodPressure == null) ? leftBorderValues.diastolicBloodPressure : e.$2.diastolicBloodPressure;
                                          }).toList(),
                                          Colors.blue,
                                        ),
                                      ],
                                      goalLines: [
                                        _GoalLineDescriptor(180.0, "Hipertensión crítica (Sistólica)", color: Colors.pink.shade900),
                                        _GoalLineDescriptor(140.0, "Presión alta etapa 2 (Sistólica)", color: Colors.pink.shade800),
                                        _GoalLineDescriptor(130.0, "Presión alta etapa 1 (Sistólica)", color: Colors.pink.shade600),
                                        _GoalLineDescriptor(120.0, "Presión elevada (Sistólica)", color: Colors.pink.shade400),

                                        _GoalLineDescriptor(120.0, "Hipertensión crítica (Diastólica)", color: Colors.blue.shade900, alignment: Alignment.bottomRight),
                                        _GoalLineDescriptor(90.0, "Presión alta etapa 2 (Diastólica)", color: Colors.blue.shade800),
                                        _GoalLineDescriptor(80.0, "Presión alta etapa 1 (Diastólica)", color: Colors.blue.shade600),
                                      ],
                                      getDate: (i) => shortDateFormatter.format(dateSteps[i]),
                                      showDotInfo: (lineIndex, i) {
                                        if (i >= dateSteps.length) return false;
                                        final index = recordHistory.indexWhere((e) => datesAreSameDay(dateSteps[i], e.date));
                                        return index != -1 && (lineIndex == 0 ? recordHistory[index].systolicBloodPressure : recordHistory[index].diastolicBloodPressure) != null;
                                      },
                                    )
                                  else
                                    Center(
                                      child: MyText.bodyLarge(
                                        "No hay mediciones de presión arterial registradas."
                                            "\nAsegurate de registrar tu progreso diario.",
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  MySpacing.height(20),
                                  Center(child: MyText.titleLarge("            Azuca en Sangre", fontWeight: 800, muted: true)),
                                  MySpacing.height(10),
                                  if (minValues.sugarLevel != null)
                                    createDataGraph(
                                      height: 400.0,
                                      minY: minValues.sugarLevel! - sugarLevelVerticalGraphPadding,
                                      maxY: maxValues.sugarLevel! + sugarLevelVerticalGraphPadding,
                                      minX: 0,
                                      maxX: (controller.timePeriodDays - 1).toDouble(),
                                      leftSideUnits: (value) {
                                        return MyText.labelMedium("$value\nmg/dL");
                                      },
                                      bottomUnitsInterval: math.max(recordHistoryPair.length / 10.0, 1.0),
                                      bottomSideUnits: (value) {
                                        int i = value.toInt();
                                        if (i >= recordHistoryPair.length) return Text("");
                                        return Transform.rotate(
                                          angle: -0.5,
                                          child: MyText.labelMedium(shortDateFormatter.format(recordHistoryPair[i].$1)),
                                        );
                                      },
                                      lines: [
                                        _LineDescriptor(
                                          "Nivel de azucar",
                                          recordHistoryPair.mapIndexed<double?>((i, e) {
                                            return (i == 0 && e.$2.sugarLevel == null) ? leftBorderValues.sugarLevel : e.$2.sugarLevel;
                                          }).toList(),
                                          Colors.blue,
                                        ),
                                      ],
                                      goalLines: [
                                        _GoalLineDescriptor(70, "Bajo Azucar", color: Colors.redAccent),
                                        _GoalLineDescriptor(100, "Alto Azucar (Ayunas)", color: Colors.deepOrangeAccent),
                                        _GoalLineDescriptor(140, "Alto Azucar (Después de comer)", color: Colors.red),
                                      ],
                                      getDate: (i) => shortDateFormatter.format(dateSteps[i]),
                                      showDotInfo: (lineIndex, i) {
                                        if (i >= dateSteps.length) return false;
                                        final index = recordHistory.indexWhere((e) => datesAreSameDay(dateSteps[i], e.date));
                                        return index != -1 && recordHistory[index].sugarLevel != null;
                                      },
                                    )
                                  else
                                    Center(
                                      child: MyText.bodyLarge(
                                        "No hay mediciones del azucar en sangre registradas."
                                            "\nAsegurate de registrar tu progreso diario.",
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  MySpacing.height(20),
                                  Center(child: MyText.titleLarge("Otras mediciones", fontWeight: 800, muted: true)),
                                  MySpacing.height(10),
                                  if (minValues.sugarLevel != null)
                                    createCalendarGraph(
                                      height: 400.0,
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime.now(),
                                      daysData: controller.completeRecordHistory.map<_CalendarDayDescriptor>((e) =>
                                          _CalendarDayDescriptor(
                                            e.date,
                                            emotionalState: e.emotionalState,
                                            medication: e.medications,
                                            exercise: e.exercise,
                                          )
                                      ).toList(),
                                      medicationColor: Colors.deepOrangeAccent,
                                      exerciseColor: Colors.lightBlue,
                                      emotionalColor1: Color.fromARGB(255, 30, 255, 30),
                                      emotionalColor2: Color.fromARGB(255, 255, 30, 30),
                                      showDataNames: true,
                                      showNumStatistics: true,
                                    )
                                  else
                                    Center(
                                      child: MyText.bodyLarge(
                                        "No hay mediciones del azucar en sangre registradas."
                                            "\nAsegurate de registrar tu progreso diario.",
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        )
                      else
                        MyText.bodySmall("Aún no has registrado datos. Comienza hoy para ver tu progreso aquí."),
                      MySpacing.height(20),
                    ],
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }


  Widget createDataGraph({
    required double height,
    double minX = 0, double maxX = 6, double minY = 0, double maxY = 100,
    required List<_LineDescriptor> lines, Widget Function(double)? leftSideUnits,
    Widget Function(double)? bottomSideUnits,
    double? leftUnitsInterval, double? bottomUnitsInterval,
    List<_GoalLineDescriptor> goalLines = const [],
    String Function(int)? getDate, bool Function(int, int)? showDotInfo,
    bool showLineNames = false,
  }) {
    return Column(
      children: [
        if (showLineNames && lines.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 55.0),
            child: Wrap(
              spacing: 10.0,
              runSpacing: 5.0,
              children: lines.map<Widget>((e) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 15.0,
                      height: 15.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: e.color1,
                      ),
                    ),
                    MySpacing.width(5.0),
                    MyText.labelMedium(e.name, muted: true,),
                  ],
                );
              }).toList(),
            ),
          ),
        if (showLineNames && lines.isNotEmpty)
          MySpacing.height(15.0),
        SizedBox(
          height: height,
          child: LineChart(
            LineChartData(
              lineTouchData: LineTouchData(
                touchSpotThreshold: 15.0,
                enabled: true,
                touchTooltipData: LineTouchTooltipData(
                  //tooltipBgColor: Colors.black.withOpacity(0.7),
                  getTooltipColor: (LineBarSpot spot) {
                    return Colors.black.withAlpha(180);
                  },
                  getTooltipItems: (List<LineBarSpot> touchedSpots) {
                    return touchedSpots.map((spot) {
                      final index = spot.x.toInt();
                      if (!(showDotInfo?.call(0, index)?? true)) return null;

                      final value = spot.y;
                      final date = getDate?.call(index);// (index >= 0 && index < dates.length) ? dates[index] : 'Unknown';

                      return LineTooltipItem(
                        '${date != null ? '📅 $date\n' : ''}📈 ${value.toStringAsFixed(2)}',
                        TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                      );
                    }).toList();
                  },
                ),
                /*getTouchedSpotIndicator: (barData, indicators) {
                  return indicators.map((int index) {
                    /// Indicator Line
                    var lineColor = barData.gradient?.colors.first ?? barData.color;
                    if (barData.dotData.show) {
                      lineColor = _defaultGetDotColor(barData.spots[index], 0, barData);
                    }
                    const lineStrokeWidth = 4.0;
                    final flLine = FlLine(color: lineColor, strokeWidth: lineStrokeWidth);

                    var dotSize = 10.0;
                    if (barData.dotData.show) {
                      dotSize = 4.0 * 1.8;
                    }

                    final dotData = FlDotData(
                      show: false,
                      checkToShowDot: (_, __) => false,
                      getDotPainter: (spot, percent, bar, index) =>
                          _defaultGetDotPainter(spot, percent, bar, index, size: dotSize),
                    );

                    return TouchedSpotIndicatorData(flLine, dotData);
                  }).toList();
                },*/
              ),
              minX: minX,
              maxX: maxX,
              minY: minY,
              maxY: maxY,
              gridData: FlGridData(show: true),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true, reservedSize: 55,
                    minIncluded: false, maxIncluded: false,
                    interval: leftUnitsInterval,
                    getTitlesWidget: leftSideUnits == null ? defaultGetTitle :
                    (value, meta) {
                      return SideTitleWidget(
                        meta: meta,
                        child: leftSideUnits(value),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: bottomUnitsInterval,
                    getTitlesWidget: bottomSideUnits == null ? defaultGetTitle :
                    (value, meta) {
                      return SideTitleWidget(
                        meta: meta,
                        child: bottomSideUnits(value),
                      );
                    },
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              lineBarsData: lines.mapIndexed<List<LineChartBarData>>((i, e) => _buildLine(i, e, showDotInfo: showDotInfo)).mapMany<LineChartBarData>((e) => e).toList(),
              extraLinesData: ExtraLinesData(
                horizontalLines: goalLines.map<HorizontalLine>((e) => _goalLine(e)).toList(),
              ),
            ),
            curve: Curves.ease,
          ),
        ),
      ],
    );
  }

  List<LineChartBarData> _buildLine(
      int i, _LineDescriptor desc,
      {bool Function(int, int)? showDotInfo,}) {
    if (desc.values.isEmpty || !desc.values.any((e) => e != null)) return [];

    /// TODO: ESTO ES PARA SEPARACIÓN DE LÍNEAS POR COLORES, YA QUE NO LO HAY
    /// NATIVAMENTE EN LA HERRAMIENTA. DESGRACIADAMENTE, SI LO HAGO ASÍ COMO LO
    /// ESTOY HACIENDO, ESTARÍA PONIENDO PUNTOS DOBLES EN CADA EXTREMO DE LAS
    /// LÍNEAS, EN DONDE CAMBIAN DE COLOR, Y ESO HARÍA QUE AL PONER EL MOUSE
    /// ENCIMA DE ELLAS, SE VEAN 2 VALORES EN VEZ DE 1
    List<LineChartBarData> r = [];
    if (desc.splitUpDownData && desc.color2 != null) {
      List<(bool, List<int>)> splitData = [];
      int? lastIndex;
      double? lastValue;
      bool? currentDirection;
      bool? lastCurrentDirection;
      List<int> currentList = [];
      for (int i = 0; i < desc.values.length; ++i) {
        if (desc.values[i] == null) continue;

        lastCurrentDirection = currentDirection;
        if (lastValue != null) {
          currentDirection = (desc.values[i]! - lastValue) >= 0.0;
        }

        if (lastCurrentDirection != null && currentDirection != lastCurrentDirection) {
          //Debug.log("Adding to line [ ${currentList.join(", ")}]");
          splitData.add((lastCurrentDirection, currentList));
          //Debug.log("Current lines [${splitData.map<String>((e) => "${e.$1 ? "up" : "down"} [${e.$2.join(", ")}]").join(", ")}]");
          currentList = [];
          currentList.add(lastIndex!);
        }

        currentList.add(i);
        lastIndex = i;
        lastValue = desc.values[i]!;
      }
      //Debug.log("Adding to line [${currentList.join(", ")}]");
      splitData.add((currentDirection?? true, currentList));

      //Debug.log("Final lines [${splitData.map<String>((e) => "${e.$1 ? "up" : "down"} [${e.$2.join(", ")}]").join(", ")}]");
      for (final split in splitData) {
        r.add(LineChartBarData(
          isCurved: true,
          color: split.$1 ? desc.color1 : desc.color2,
          curveSmoothness: 0.35,
          preventCurveOverShooting: true,
          barWidth: 3,
          dotData: FlDotData(
            show: true,
            checkToShowDot: (spot, data) {
              final index = spot.x.toInt();
              return showDotInfo?.call(i, index)?? true;
            },
          ),
          belowBarData: BarAreaData(show: desc.barCutOffY != null, cutOffY: desc.barCutOffY?? 0.0, applyCutOffY: desc.barCutOffY != null),
          aboveBarData: BarAreaData(show: desc.barCutOffY != null, cutOffY: desc.barCutOffY?? 0.0, applyCutOffY: desc.barCutOffY != null),
          spots: split.$2.map<FlSpot>((i) => FlSpot(i.toDouble(), desc.values[i]!))
              .toList(),
          //List.generate(desc.values.length, (index) => FlSpot(index.toDouble(), desc.values[index])),
        ));
      }

      return r;
    }

    r.add(LineChartBarData(
      isCurved: true,
      color: desc.color1,
      curveSmoothness: 0.35,
      preventCurveOverShooting: true,
      barWidth: 3,
      dotData: FlDotData(
        show: true,
        checkToShowDot: (spot, data) {
          final index = spot.x.toInt();
          /*if (showDotInfo != null) {
            Debug.log("asking to show dot: $index");
          }*/
          return showDotInfo?.call(i, index)?? true;
        },
      ),
      belowBarData: BarAreaData(show: desc.barCutOffY != null, cutOffY: desc.barCutOffY?? 0.0, applyCutOffY: desc.barCutOffY != null),
      aboveBarData: BarAreaData(show: desc.barCutOffY != null, cutOffY: desc.barCutOffY?? 0.0, applyCutOffY: desc.barCutOffY != null),
      spots: List<int?>.generate(desc.values.length, (i) => desc.values[i] == null ? null : i)
          .where((i) => i != null)
          .map<FlSpot>((i) => FlSpot(i!.toDouble(), desc.values[i]!))
          .toList(),
      //List.generate(desc.values.length, (index) => FlSpot(index.toDouble(), desc.values[index])),
    ));
    return r;
  }

  HorizontalLine _goalLine(_GoalLineDescriptor desc) {
    return HorizontalLine(
      y: desc.height,
      color: desc.color,
      strokeWidth: 2,
      dashArray: [8, 4],
      label: HorizontalLineLabel(
        show: true,
        alignment: desc.alignment,
        style: TextStyle(color: desc.color, fontWeight: FontWeight.bold),
        labelResolver: (_) => desc.label,
      ),
    );
  }


  Widget createBarGraph({
    required double height, double minY = 0, double maxY = 100,
    required List<_BarGroupDescriptor> barGroups, Widget Function(double)? leftSideUnits,
    Widget Function(double)? bottomSideUnits,
    double? leftUnitsInterval, double? bottomUnitsInterval,
    List<_GoalLineDescriptor> goalLines = const [],
    String Function(int)? getDate, bool Function(int, int)? showDotInfo,
    String Function(int index, double fromY, double toY)? getDotInfoText,
    bool showBarNames = false,}) {
    return Column(
      children: [
        if (showBarNames && barGroups.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 55.0),
            child: Wrap(
              spacing: 10.0,
              runSpacing: 5.0,
              children: barGroups.map<Widget>((e) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 15.0,
                      height: 15.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: e.color,
                      ),
                    ),
                    MySpacing.width(5.0),
                    MyText.labelMedium(e.name, muted: true,),
                  ],
                );
              }).toList(),
            ),
          ),
        if (showBarNames && barGroups.isNotEmpty)
          MySpacing.height(15.0),
        SizedBox(
          height: height,
          child: BarChart(
            BarChartData(
              minY: minY,
              maxY: maxY,
              barGroups: barGroups.mapIndexed<BarChartGroupData>((i, e) => _buildBar(i, e.values)).toList(),
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  //tooltipBgColor: Colors.black.withOpacity(0.7),
                  getTooltipColor: (group) {
                    return Colors.black.withAlpha(180);
                  },
                  getTooltipItem: (BarChartGroupData group, int groupIndex, BarChartRodData rod, int rodIndex) {
                    final index = group.x;
                    if (!(showDotInfo?.call(0, index)?? true)) return null;

                    if (getDotInfoText != null) {
                      return BarTooltipItem(
                        getDotInfoText(index, rod.fromY, rod.toY),
                        TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                      );
                    }

                    final value = rod.toY;
                    //final value2 = rod.fromY;
                    final date = getDate?.call(index);// (index >= 0 && index < dates.length) ? dates[index] : 'Unknown';

                    return BarTooltipItem(
                      //'${date != null ? '📅 $date\n' : ''}📈 ${value.toStringAsFixed(2)}',
                      '📈 ${value.toStringAsFixed(2)}',
                      TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                    );
                  },
                ),
              ),
              gridData: FlGridData(show: true),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true, reservedSize: 55,
                    minIncluded: false, maxIncluded: false,
                    interval: leftUnitsInterval,
                    getTitlesWidget: leftSideUnits == null ? defaultGetTitle :
                        (value, meta) {
                      return SideTitleWidget(
                        meta: meta,
                        child: leftSideUnits(value),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: bottomUnitsInterval,
                    getTitlesWidget: bottomSideUnits == null ? defaultGetTitle :
                        (value, meta) {
                      return SideTitleWidget(
                        meta: meta,
                        child: bottomSideUnits(value),
                      );
                    },
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              extraLinesData: ExtraLinesData(
                horizontalLines: goalLines.map<HorizontalLine>((e) => _goalLine(e)).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  BarChartGroupData _buildBar(int x, List<({double? toY, double? fromY})> rodsData) {
    return BarChartGroupData(
      x: x,
      barRods: rodsData.map<BarChartRodData>(
        (e) => BarChartRodData(
          fromY: e.fromY,
          toY: e.toY?? 0.0,
        ),
      ).toList(),
    );
  }


  String _getMonthName(int month) {
    return switch(month) {
      DateTime.january => "Enero",
      DateTime.february => "Febrero",
      DateTime.march => "Marzo",
      DateTime.april => "Abril",
      DateTime.may => "Mayo",
      DateTime.june => "Junio",
      DateTime.july => "Julio",
      DateTime.august => "Agosto",
      DateTime.september => "Septiembre",
      DateTime.october => "Octubre",
      DateTime.november => "Noviembre",
      DateTime.december => "Diciembre",
      int() => "",
    };
  }
  int _getMonthDays(int month, int currentYear) {
    return switch(month) {
      DateTime.january => 31,
      DateTime.february => currentYear % 4 == 0 && (currentYear % 100 != 0 || currentYear % 400 == 0) ? 29 : 28,
      DateTime.march => 31,
      DateTime.april => 30,
      DateTime.may => 31,
      DateTime.june => 30,
      DateTime.july => 31,
      DateTime.august => 31,
      DateTime.september => 30,
      DateTime.october => 31,
      DateTime.november => 30,
      DateTime.december => 31,
      int() => 0,
    };
  }
  String _getWeekDayShortName(int day) {
    return switch(day) {
      DateTime.sunday => "Do",
      DateTime.monday => "Lu",
      DateTime.tuesday => "Ma",
      DateTime.wednesday => "Mi",
      DateTime.thursday => "Ju",
      DateTime.friday => "Vi",
      DateTime.saturday => "Sa",
      int() => "",
    };
  }

  int? _getDayNumber(int r, int w, int firstWeekDay, int maxMonthDays, [bool getExcess = false]) {
    int currentDay = r * 7 + w - firstWeekDay;
    if (!getExcess && (currentDay < 0 || currentDay >= maxMonthDays)) return null;
    return currentDay + 1;
  }

  _CalendarDayDescriptor? _getDay(List<_CalendarDayDescriptor> daysData,
      int currentYear, int currentMonth, int r, int w, int firstWeekDay, int maxMonthDays) {
    final day = _getDayNumber(r, w, firstWeekDay, maxMonthDays);
    if (day == null) return null;

    final checkDate = DateTime(currentYear, currentMonth, day);
    final data = daysData.firstWhere((e) => datesAreSameDay(checkDate, e.date), orElse: () => _CalendarDayDescriptor(checkDate));
    return data;
  }


  Widget createCalendarGraph({
    required double height,
    required DateTime firstDate, required DateTime lastDate,
    required List<_CalendarDayDescriptor> daysData,
    required Color medicationColor, required Color exerciseColor,
    required Color emotionalColor1, required Color emotionalColor2,
    bool showDataNames = false, bool showNumStatistics = false}) {
    if (daysData.isEmpty) return Placeholder(color: Colors.transparent,);

    final firstMonth = daysData.first.date.month;
    final firstDay = daysData.first.date.day;
    final lastMonth = daysData.last.date.month;
    final lastDay = daysData.last.date.day;

    int currentYear = controller.calendarCurrentYear;
    final String year = currentYear.toString();

    int currentMonth = controller.calendarCurrentMonth;
    final String month = _getMonthName(currentMonth);
    final int monthDays = _getMonthDays(currentMonth, currentYear);
    final int firstWeekDay = DateTime(currentYear, currentMonth, 1).weekday - 1;

    final prevMonth = (currentMonth + 10) % 12 + 1;
    final nextMonth = currentMonth % 12 + 1;
    final yearOfThePrevMonth = currentYear - (currentMonth == 1 ? 1 : 0);
    final yearOfTheNextMonth = currentYear + (currentMonth == 12 ? 1 : 0);
    final firstDayOfTheMonth = DateTime(yearOfThePrevMonth, prevMonth, _getMonthDays(prevMonth, yearOfThePrevMonth));
    final lastDayOfTheMonth = DateTime(yearOfTheNextMonth, nextMonth, 1);
    final firstDayOfTheYear = DateTime(currentYear - 1, 12, 31);
    final lastDayOfTheYear = DateTime(currentYear + 1, 1, 1);

    int emotionalMonthSum = 0;
    int emotionalMonthValues = 0;
    int emotionalYearSum = 0;
    int emotionalYearValues = 0;
    for (final e in daysData) {
      if (e.emotionalState == null) continue;
      if (e.date.isAfter(firstDayOfTheMonth) && e.date.isBefore(lastDayOfTheMonth)) {
        emotionalMonthSum += e.emotionalState!.index;
        emotionalMonthValues += 1;
      }
      if (e.date.isAfter(firstDayOfTheYear) && e.date.isBefore(lastDayOfTheYear)) {
        emotionalYearSum += e.emotionalState!.index;
        emotionalYearValues += 1;
      }
    }
    final emotionalMonthAverage = emotionalMonthValues == 0 ? 0.0 : emotionalMonthSum / emotionalMonthValues;
    final Color emotionalMonthColor = emotionalMonthValues == 0 ? Colors.green :
    lerpOklab(emotionalColor1, emotionalColor2, emotionalMonthAverage / (EmotionalState.values.length - 1));
    final emotionalYearAverage = emotionalYearValues == 0 ? 0.0 : emotionalYearSum / emotionalYearValues;
    Color emotionalYearColor = emotionalYearValues == 0 ? Colors.greenAccent :
    lerpOklab(emotionalColor1, emotionalColor2, emotionalYearAverage / (EmotionalState.values.length - 1));
    emotionalYearColor = lerpOklab(emotionalYearColor, Colors.white, 0.25);

    final Color firstColor = Color.fromARGB(255, 250, 250, 250);
    final Color secondColor = Color.fromARGB(255, 235, 235, 235);

    final Color firstWeekColor = lerpOklab(secondColor, Colors.black, 0.25);
    final Color secondWeekColor = lerpOklab(firstColor, Colors.black, 0.25);

    final Color changeMonthLeftColor = currentMonth <= firstMonth ? Color.fromARGB(255, 200, 200, 200) : Colors.white;
    final Color changeMonthRightColor = currentMonth >= lastMonth ? Color.fromARGB(255, 200, 200, 200) : Colors.white;


    int medicationCount = 0;
    int exerciseCount = 0;
    for (final e in daysData) {
      if (e.date.isAfter(firstDayOfTheMonth) && e.date.isBefore(lastDayOfTheMonth)) {
        medicationCount += (e.medication?? false) ? 1 : 0;
        exerciseCount += (e.exercise?? false) ? 1 : 0;
      }
    }
    final monthWeeks = monthDays / 7;
    final medicationWeekAverage = ((medicationCount / monthWeeks) * 100).round() / 100;
    final exerciseWeekAverage = ((exerciseCount / monthWeeks) * 100).round() / 100;


    return Column(
      children: [
        if (showDataNames)
          Column(
            children: [
              Wrap(
                spacing: 10.0,
                runSpacing: 5.0,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 15.0,
                        height: 15.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: medicationColor,
                        ),
                      ),
                      MySpacing.width(5.0),
                      MyText.labelMedium("Medicación", muted: true,),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 15.0,
                        height: 15.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: exerciseColor,
                        ),
                      ),
                      MySpacing.width(5.0),
                      MyText.labelMedium("Ejercicio", muted: true,),
                    ],
                  ),
                ]
              ),
              MySpacing.height(5.0),
              MyText.labelLarge("Estado de ánimo"),
              MySpacing.height(5.0),
              Wrap(
                spacing: 10.0,
                runSpacing: 5.0,
                children: EmotionalState.values.map((e) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 15.0,
                      height: 15.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: lerpOklab(emotionalColor1, emotionalColor2, e.index / (EmotionalState.values.length - 1)),
                      ),
                    ),
                    MySpacing.width(5.0),
                    MyText.labelMedium(e.name, muted: true,),
                  ],
                )).toList(),
              ),
              MySpacing.height(15.0),
            ],
          ),
        Container(
          height: height,
          decoration: BoxDecoration(
            color: emotionalYearColor,
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
                      child: Center(child: MyText.titleLarge(year, fontWeight: 700,)),
                    ),
                  ),
                ],
              ),
              Container(
                color: emotionalMonthColor,
                child: Padding(
                  padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      MySpacing.width(5.0),
                      BlixCircleButton(
                        radius: 20.0,
                        onTap: () {
                          if (currentMonth <= firstMonth) return;
                          controller.onChangeMonth(-1);
                        },
                        color: Colors.transparent,
                        shadow: false,
                        child: Center(child: Icon(Icons.arrow_left, color: changeMonthLeftColor,),),
                      ),
                      Expanded(
                        child: Center(child: MyText.titleMedium(month, fontWeight: 700,)),
                      ),
                      BlixCircleButton(
                        radius: 20.0,
                        onTap: () {
                          if (currentMonth >= lastMonth) return;
                          controller.onChangeMonth(1);
                        },
                        color: Colors.transparent,
                        shadow: false,
                        child: Center(child: Icon(Icons.arrow_right, color: changeMonthRightColor,),),
                      ),
                      MySpacing.width(5.0),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        for (int w = 0; w < 7; ++w)
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: w % 2 == 0 ? firstWeekColor : secondWeekColor,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
                                child: Center(
                                  child: MyText.labelLarge(_getWeekDayShortName(w + 1), fontWeight: 600,),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    for (int r = 0; r < 6; ++r)
                      Expanded(
                        child: Row(
                          children: [
                            for (int w = 0; w < 7; ++w)
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: r % 2 == w % 2 ? firstColor : secondColor,
                                    borderRadius: r != 5 || (w != 0 && w != 6) ? null :
                                    BorderRadius.only(
                                      bottomLeft: Radius.circular(w == 0 ? 20.0 : 0.0),
                                      bottomRight: Radius.circular(w == 6 ? 20.0 : 0.0),
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: Padding(
                                          padding: const EdgeInsets.only(bottom: 4.0, right: 4.0),
                                          child: MyText.labelSmall(_getDayNumber(r, w, firstWeekDay, monthDays)?.toString()?? ""),
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          Expanded(
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Container(
                                                    margin: EdgeInsets.all(3.0),
                                                    decoration: BoxDecoration(
                                                      color: switch(_getDay(daysData, currentYear, currentMonth, r, w, firstWeekDay, monthDays)?.medication) {
                                                        null => Colors.transparent,
                                                        true => medicationColor,
                                                        false => Colors.transparent,
                                                      },
                                                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Container(
                                                    margin: EdgeInsets.all(3.0),
                                                    decoration: BoxDecoration(
                                                      color: switch(_getDay(daysData, currentYear, currentMonth, r, w, firstWeekDay, monthDays)?.exercise) {
                                                        null => Colors.transparent,
                                                        true => exerciseColor,
                                                        false => Colors.transparent,
                                                      },
                                                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Container(
                                                    margin: EdgeInsets.fromLTRB(3.0, 3.0, 22.0, 3.0),
                                                    decoration: BoxDecoration(
                                                      color: switch(_getDay(daysData, currentYear, currentMonth, r, w, firstWeekDay, monthDays)?.emotionalState) {
                                                        null => Colors.transparent,
                                                        EmotionalState.veryGood => emotionalColor1,
                                                        EmotionalState.good => lerpOklab(emotionalColor1, emotionalColor2, 0.25),
                                                        EmotionalState.neutral => lerpOklab(emotionalColor1, emotionalColor2, 0.5),
                                                        EmotionalState.bad => lerpOklab(emotionalColor1, emotionalColor2, 0.75),
                                                        EmotionalState.veryBad => emotionalColor2,
                                                      },
                                                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (currentMonth <= firstMonth && _getDayNumber(r, w, firstWeekDay, monthDays, true)! < firstDay ||
                                          currentMonth >= lastMonth && _getDayNumber(r, w, firstWeekDay, monthDays, true)! > lastDay)
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Color.fromARGB(120, 150, 150, 150),
                                            borderRadius: r != 5 || (w != 0 && w != 6) ? null :
                                            BorderRadius.only(
                                              bottomLeft: Radius.circular(w == 0 ? 20.0 : 0.0),
                                              bottomRight: Radius.circular(w == 6 ? 20.0 : 0.0),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showNumStatistics)
          Column(
            children: [
              MySpacing.height(10.0),
              Wrap(
                spacing: 10.0,
                runSpacing: 5.0,
                alignment: WrapAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MyText.labelLarge("Total Medicación: ", fontWeight: 600,),
                      MyText.labelLarge("$medicationCount,", fontWeight: 800,),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MyText.labelLarge("Medicación Promedio Semanal: ", fontWeight: 600,),
                      MyText.labelLarge("$medicationWeekAverage,", fontWeight: 800,),
                    ],
                  ),
                ],
              ),
              MySpacing.height(5.0),
              Wrap(
                spacing: 10.0,
                runSpacing: 5.0,
                alignment: WrapAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MyText.labelLarge("Total Ejercicio: ", fontWeight: 600,),
                      MyText.labelLarge("$exerciseCount,", fontWeight: 800,),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MyText.labelLarge("Ejercicio Promedio Semanal: ", fontWeight: 600,),
                      MyText.labelLarge("$exerciseWeekAverage,", fontWeight: 800,),
                    ],
                  ),
                ],
              ),
            ],
          ),
      ],
    );
  }
}
