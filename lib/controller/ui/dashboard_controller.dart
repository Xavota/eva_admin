import 'package:medicare/helpers/utils/ui_mixins.dart';
import 'package:medicare/views/my_controller.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DashboardController extends MyController with UIMixin {
  List<ChartSampleData>? chartData;
  List<ChartSampleData>? patientByAge;
  TooltipBehavior? tooltipBehavior;

  @override
  void onInit() {
    chartData = <ChartSampleData>[
      ChartSampleData(x: 'Jan', y: 43, secondSeriesYValue: 37, thirdSeriesYValue: 41),
      ChartSampleData(x: 'Feb', y: 45, secondSeriesYValue: 37, thirdSeriesYValue: 45),
      ChartSampleData(x: 'Mar', y: 50, secondSeriesYValue: 39, thirdSeriesYValue: 48),
      ChartSampleData(x: 'Apr', y: 55, secondSeriesYValue: 43, thirdSeriesYValue: 52),
      ChartSampleData(x: 'May', y: 63, secondSeriesYValue: 48, thirdSeriesYValue: 57),
      ChartSampleData(x: 'Jun', y: 68, secondSeriesYValue: 54, thirdSeriesYValue: 61),
      ChartSampleData(x: 'Jul', y: 72, secondSeriesYValue: 57, thirdSeriesYValue: 66),
      ChartSampleData(x: 'Aug', y: 70, secondSeriesYValue: 57, thirdSeriesYValue: 66),
      ChartSampleData(x: 'Sep', y: 66, secondSeriesYValue: 54, thirdSeriesYValue: 63),
      ChartSampleData(x: 'Oct', y: 57, secondSeriesYValue: 48, thirdSeriesYValue: 55),
      ChartSampleData(x: 'Nov', y: 50, secondSeriesYValue: 43, thirdSeriesYValue: 50),
      ChartSampleData(x: 'Dec', y: 45, secondSeriesYValue: 37, thirdSeriesYValue: 45)
    ];

    patientByAge = <ChartSampleData>[
      ChartSampleData(x: 'Jan', y: 16, secondSeriesYValue: 15, thirdSeriesYValue: 14),
      ChartSampleData(x: 'Feb', y: 15, secondSeriesYValue: 14, thirdSeriesYValue: 12),
      ChartSampleData(x: 'Mar', y: 14, secondSeriesYValue: 13, thirdSeriesYValue: 11),
      ChartSampleData(x: 'Apr', y: 16, secondSeriesYValue: 12, thirdSeriesYValue: 10),
      ChartSampleData(x: 'May', y: 15, secondSeriesYValue: 13, thirdSeriesYValue: 12),
      ChartSampleData(x: 'Jun', y: 16, secondSeriesYValue: 14, thirdSeriesYValue: 11),
      ChartSampleData(x: 'Jul', y: 14, secondSeriesYValue: 13, thirdSeriesYValue: 10),
      ChartSampleData(x: 'Aug', y: 15, secondSeriesYValue: 12, thirdSeriesYValue: 11),
      ChartSampleData(x: 'Sep', y: 16, secondSeriesYValue: 15, thirdSeriesYValue: 14),
      ChartSampleData(x: 'Oct', y: 14, secondSeriesYValue: 13, thirdSeriesYValue: 12),
      ChartSampleData(x: 'Nov', y: 15, secondSeriesYValue: 14, thirdSeriesYValue: 10),
      ChartSampleData(x: 'Dec', y: 16, secondSeriesYValue: 15, thirdSeriesYValue: 13),
    ];
    super.onInit();
  }

  List<SplineSeries<ChartSampleData, String>> treatmentTypeChart() {
    return <SplineSeries<ChartSampleData, String>>[
      SplineSeries<ChartSampleData, String>(
        dataSource: chartData,
        color: contentTheme.success,
        xValueMapper: (ChartSampleData sales, _) => sales.x as String,
        yValueMapper: (ChartSampleData sales, _) => sales.y,
        markerSettings: const MarkerSettings(isVisible: true),
        name: 'General',
      ),
      SplineSeries<ChartSampleData, String>(
        dataSource: chartData,
        name: 'ICU',
        color: contentTheme.purple,
        markerSettings: const MarkerSettings(isVisible: true),
        xValueMapper: (ChartSampleData sales, _) => sales.x as String,
        yValueMapper: (ChartSampleData sales, _) => sales.secondSeriesYValue,
      )
    ];
  }

  List<ColumnSeries<ChartSampleData, String>> patientByAgeChart() {
    return <ColumnSeries<ChartSampleData, String>>[
      ColumnSeries<ChartSampleData, String>(
          width: 0.8,
          spacing: 0.2,
          dataSource: patientByAge,
          color: contentTheme.primary,
          xValueMapper: (ChartSampleData sales, _) => sales.x as String,
          yValueMapper: (ChartSampleData sales, _) => sales.y,
          name: 'Male'),
      ColumnSeries<ChartSampleData, String>(
          dataSource: patientByAge,
          width: 0.8,
          spacing: 0.2,
          color: contentTheme.secondary,
          xValueMapper: (ChartSampleData sales, _) => sales.x as String,
          yValueMapper: (ChartSampleData sales, _) => sales.secondSeriesYValue,
          name: 'Female'),
    ];
  }

  List appointment = [
    {"id": 1, "patient_name": "Candie", "gender": "Female", "appointment_for": "Candie Son", "date": DateTime.parse("2023-12-25T21:52:12Z"), "time": DateTime.parse("2024-07-07T12:34:11Z")},
    {
      "id": 2,
      "patient_name": "Katherina",
      "gender": "Female",
      "appointment_for": "Katherina Elverstone",
      "date": DateTime.parse("2024-06-15T01:32:05Z"),
      "time": DateTime.parse("2023-12-01T15:43:33Z")
    },
    {"id": 3, "patient_name": "See", "gender": "Male", "appointment_for": "See Orritt", "date": DateTime.parse("2023-11-18T03:02:57Z"), "time": DateTime.parse("2024-05-08T08:24:15Z")},
    {"id": 4, "patient_name": "Salaidh", "gender": "Female", "appointment_for": "Salaidh Blune", "date": DateTime.parse("2024-04-03T10:49:37Z"), "time": DateTime.parse("2024-03-27T17:45:08Z")},
    {"id": 5, "patient_name": "Raffaello", "gender": "Male", "appointment_for": "Raffaello Blas", "date": DateTime.parse("2024-02-21T14:47:26Z"), "time": DateTime.parse("2024-09-03T18:44:14Z")}
  ];
}

class ChartSampleData {
  ChartSampleData(
      {this.x, this.y, this.xValue, this.yValue, this.secondSeriesYValue, this.thirdSeriesYValue, this.pointColor, this.size, this.text, this.open, this.close, this.low, this.high, this.volume});

  final dynamic x;
  final num? y;
  final dynamic xValue;
  final num? yValue;
  final num? secondSeriesYValue;
  final num? thirdSeriesYValue;
  final Color? pointColor;
  final num? size;
  final String? text;
  final num? open;
  final num? close;
  final num? low;
  final num? high;
  final num? volume;
}
