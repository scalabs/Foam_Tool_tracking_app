import 'dart:math';
//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '/models/week_of_the_year.dart';

class Tab2 extends StatefulWidget {
  @override
  _Tab2State createState() => _Tab2State();
}

class _Tab2State extends State<Tab2> {
  late final WeekOfTheYear selectedWeek;

  @override
  void initState() {
    selectedWeek = WeekOfTheYear(
      //selfRef: null,
      start: DateTime(2024, 1, 23),
      end: DateTime(2024, 1, 28),
      label: 'CW04',
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WeekEditorView(
      revIndicator: true,
      weekIndicator: true,
      assyLineLabel: 'Your Assay Line Label', // Replace with your actual label
      selectedWeek: selectedWeek,
    );
  }
}

class WeekEditorView extends StatelessWidget {
  final String assyLineLabel;
  final WeekOfTheYear selectedWeek;
  final bool weekIndicator;
  final bool revIndicator;

  const WeekEditorView({
    Key? key,
    required this.selectedWeek,
    required this.weekIndicator,
    required this.revIndicator,
    required this.assyLineLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[400],
        title: Text('Review Orders: $assyLineLabel'),
        actions: [
          // if (revIndicator) RevisionSelectionWidget(),
          // if (weekIndicator) WeekSelectionWidget(onChanged: (state) {})
        ],
      ),
      body: _InnerEditor(
        cycleTime: '250',
        unitsOrdered: (Random().nextDouble() * 1000).toInt(),
      ),
    );
  }
}

class _InnerEditor extends StatefulWidget {
  final int unitsOrdered;
  final String cycleTime;

  const _InnerEditor({
    required this.unitsOrdered,
    required this.cycleTime,
  });

  @override
  State<_InnerEditor> createState() => _InnerEditorState();
}
class _InnerEditorState extends State<_InnerEditor> {
  int unitsOrdered = 1200;
  int adjustedUnitsOrdered = 1200;
  late int targetedCycleTime;
  late int adjustedCycleTime;
  late int totalProductionMinutesNeeded;
  int _shiftCounter = 0;
  late TextEditingController controller;
  late TextEditingController unitsController;
  late List<bool> mornings;
  late List<bool> afternoons;
  late List<bool> nights;
  _onAdd() {
    setState(() {
      _shiftCounter++;
    });
  }
  _onDelete() {
    setState(() {
      _shiftCounter--;
    });
  }
  @override
  void initState() {
    mornings = List.generate(7, (index) => false);
    afternoons = List.generate(7, (index) => false);
    nights = List.generate(7, (index) => false);
    targetedCycleTime = int.tryParse(widget.cycleTime) ?? 140;
    adjustedCycleTime = int.tryParse(widget.cycleTime) ?? 140;
    unitsOrdered = widget.unitsOrdered;
    adjustedUnitsOrdered = widget.unitsOrdered;
    controller = TextEditingController(text: '$targetedCycleTime');
    unitsController = TextEditingController(text: '$adjustedUnitsOrdered');
    totalProductionMinutesNeeded =
        (adjustedUnitsOrdered * (targetedCycleTime / 60)).toInt();
    super.initState();
  }
  _refreshProdMinuted() {
    totalProductionMinutesNeeded =
        (adjustedUnitsOrdered * (adjustedCycleTime / 60)).toInt();
    debugPrint('$totalProductionMinutesNeeded');
  }
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 450,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Text(
                              'Production Details',
                              style: TextStyle(
                                  color: Colors.blue[400],
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          ListTile(
                            title: Text(
                              'Tools in usage [num]',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text('Parallelization of production '),
                            trailing: Text('22'),
                          ),
                          Divider(),
                          ListTile(
                            title: Text('Total ordered units [pcs]'),
                            trailing: Text('$unitsOrdered'),
                          ),
                          ListTile(
                            title: Text('Adjusted ordered units [pcs]'),
                            trailing: SizedBox(
                              child: TextField(
                                textAlign: TextAlign.right,
                                controller: unitsController,
                                keyboardType: TextInputType.numberWithOptions(
                                  decimal: false,
                                  signed: false,
                                ),
                                onChanged: (text) {
                                  setState(() {
                                    adjustedUnitsOrdered =
                                        int.tryParse(text) ?? unitsOrdered;
                                    debugPrint('');
                                    _refreshProdMinuted();
                                  });
                                },
                              ),
                              width: 100,
                            ),
                          ),
                          ListTile(
                            title: Text('Targeted cycle time [sec]'),
                            trailing: Text('$targetedCycleTime'),
                          ),
                          ListTile(
                            title: Text('Adjusted cycle time [sec]'),
                            trailing: SizedBox(
                              child: TextField(
                                textAlign: TextAlign.right,
                                controller: controller,
                                keyboardType: TextInputType.numberWithOptions(
                                  decimal: false,
                                  signed: false,
                                ),
                                onChanged: (text) {
                                  setState(() {
                                    adjustedCycleTime =
                                        int.tryParse(text) ?? targetedCycleTime;
                                    debugPrint('');
                                    _refreshProdMinuted();
                                  });
                                },
                              ),
                              width: 100,
                            ),
                          ),
                          ListTile(
                            title: Text('Total time needed (target) [mins]'),
                            trailing: Text(
                                '${(adjustedUnitsOrdered * (targetedCycleTime / 60)).toInt()}'),
                          ),
                          ListTile(
                            title: Text(
                              'Total time needed (actual) [mins]',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            trailing: Text('$totalProductionMinutesNeeded'),
                          ),
                          Divider(),
                          ListTile(
                            leading: (_shiftCounter * 420 >=
                                    (totalProductionMinutesNeeded - 60))
                                ? Icon(
                                    Icons.check,
                                    color: Colors.green,
                                  )
                                : Icon(Icons.warning, color: Colors.orange),
                            title: Text(
                              'Planned time [mins]',
                              style: TextStyle(color: Colors.green),
                            ),
                            trailing: Text('${_shiftCounter * 420}'),
                          ),
                          ListTile(
                            leading: ((totalProductionMinutesNeeded -
                                        _shiftCounter * 420) <=
                                    60)
                                ? Icon(
                                    Icons.check,
                                    color: Colors.green,
                                  )
                                : Icon(Icons.warning, color: Colors.orange),
                            title: Text(
                              'Remaining time [mins]',
                              style: TextStyle(color: Colors.red),
                            ),
                            trailing: Text(
                                '${totalProductionMinutesNeeded - _shiftCounter * 420}'),
                          ),
                          Divider(),
                          ListTile(
                            title: Text('Update in database'),
                            leading: Icon(Icons.done),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _DayLegend(label: 'Mon'),
                        _DayLegend(label: 'Tue'),
                        _DayLegend(label: 'Wed'),
                        _DayLegend(label: 'Thu'),
                        _DayLegend(label: 'Fri'),
                        _DayLegend(label: 'Sat'),
                        _DayLegend(label: 'Sun'),
                      ],
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (int i = 0; i < mornings.length; i++)
                        _ShiftWidget(
                          initialValue: mornings[i],
                          label: 'Morning\n(06:00 - 14:00)',
                          onAdd: () {
                            mornings[i] = true;
                            _onAdd();
                          },
                          onDelete: () {
                            mornings[i] = false;
                            _onDelete();
                          },
                        ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (int i = 0; i < afternoons.length; i++)
                        _ShiftWidget(
                          initialValue: afternoons[i],
                          label: 'Afternoon\n(14:00 - 22:00)',
                          onAdd: () {
                            afternoons[i] = true;
                            _onAdd();
                          },
                          onDelete: () {
                            afternoons[i] = false;
                            _onDelete();
                          },
                        ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (int i = 0; i < nights.length; i++)
                        _ShiftWidget(
                          initialValue: nights[i],
                          label: 'Night\n(22:00 - 06:00)',
                          onAdd: () {
                            nights[i] = true;
                            _onAdd();
                          },
                          onDelete: () {
                            nights[i] = false;
                            _onDelete();
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
      crossAxisAlignment: CrossAxisAlignment.center,
    ));
  }
}
class _DayLegend extends StatelessWidget {
  final String label;
  const _DayLegend({
    Key? key,
    required this.label,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
      child: Center(
        child: Container(
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.white,
              ),
            ),
          ),
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: Colors.blue,
          ),
        ),
      ),
    );
  }
}
class _ShiftWidget extends StatefulWidget {
  final bool initialValue;
  final Function onAdd;
  final Function onDelete;
  final String label;
  const _ShiftWidget({
    Key? key,
    required this.label,
    required this.onAdd,
    required this.onDelete,
    required this.initialValue,
  }) : super(key: key);
  @override
  State<_ShiftWidget> createState() => _ShiftWidgetState();
}
class _ShiftWidgetState extends State<_ShiftWidget> {
  bool selected = false;
  final toolsInUsage = Random().nextInt(9).clamp(1, 10);
  @override
  void initState() {
    selected = widget.initialValue;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selected = !selected;
        });
        if (selected) {
          widget.onAdd();
        } else {
          widget.onDelete();
        }
      },
      child: SizedBox(
        width: 130,
        child: Card(
          color: selected ? Colors.green[200] : Colors.white,
          child: SizedBox(
            height: 200,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.label,
                        style: TextStyle(fontSize: 10, color: Colors.grey[700]),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          '7h:30min shift,\n30min break',
                          style:
                              TextStyle(fontSize: 10, color: Colors.grey[700]),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text('- ${420 * toolsInUsage} min'),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text('${toolsInUsage} tools used'),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Icon(
                      selected ? Icons.check : Icons.add_circle,
                      size: 48,
                      color: selected ? Colors.black : Colors.green[200],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}



