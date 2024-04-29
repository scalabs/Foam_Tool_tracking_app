import 'dart:convert';

class WeeklyPlanningModel {
  final List<List<bool>> shifts;

  final int adjustedCycleTime;
  final int adjustedUnitsOrdered;
  final int calendarWeek;
  final int calendarYear;
  final int orderedUnits;
  final int targetedCycleTime;
  final int toolsInUsage;
  final int id;

  WeeklyPlanningModel({
    required this.shifts,
    required this.adjustedCycleTime,
    required this.adjustedUnitsOrdered,
    required this.calendarWeek,
    required this.calendarYear,
    required this.orderedUnits,
    required this.targetedCycleTime,
    required this.toolsInUsage,
    required this.id,
  });

  factory WeeklyPlanningModel.fromMap(Map<String, dynamic> data) =>
      WeeklyPlanningModel(
        shifts: (data['JsonData'] as List)
            .map((e) => (e as List).cast<bool>())
            .toList(),
        adjustedCycleTime: data['AdjustedCycleTime'],
        adjustedUnitsOrdered: data['AdjustedUnitsOrdered'],
        calendarWeek: data['CalendarWeek'],
        calendarYear: data['CalendarYear'],
        orderedUnits: data['OrderedUnits'],
        targetedCycleTime: data['TargetedCycleTime'],
        toolsInUsage: data['ToolsInUsage'],
        id: data['id'],
      );

  Map<String, dynamic> toMap() => {
        'AdjustedCycleTime': adjustedCycleTime,
        'AdjustedUnitsOrdered': adjustedUnitsOrdered,
        'CalendarWeek': calendarWeek,
        'CalendarYear': calendarYear,
        'OrderedUnits': orderedUnits,
        'TargetedCycleTime': targetedCycleTime,
        'ToolsInUsage': toolsInUsage,
        'JsonData': jsonEncode(shifts),
      };
}
