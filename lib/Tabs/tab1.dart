import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class Tab1 extends StatefulWidget {
  @override
  _Tab1State createState() => _Tab1State();
}

//lista za drag and drop
class _Tab1State extends State<Tab1> {
  final List<String> lotrItems = [
    'Tools Cleaned',
    'Tools Not Cleaned',
    'Tools Replaced',
    'Tools Old',
    'Tools Checked',
    'Tools Calibrated',
    'Tools In Maintenance',
    'Tools In Use',
    'Tools Idle',
    'Tools Under Repair',
  ];
  String selectedItem = '';
  final List<String> tools = [
    'Foam dispenser nozzle',
    'Mixing chamber',
    'Foam flow regulator',
    'Control panel',
    'Foam density adjuster',
    'Temperature control unit',
    'Pressure gauge',
    'Safety interlock system',
    'Hose and nozzle assembly',
    'Foam material reservoir',
    'Proximity sensors',
    'Foam quality analyzer',
    'Programmable controller',
    'Emergency shut-off switch',
    'Flow rate meter',
    'Pneumatic connections',
    'Foam system diagnostics tool',
    'Filtration unit',
    'Foam chemical supply containers',
    'Operator\'s manual',
  ];
  int numberOfSections = 22;

  List<String> addedTools = [];
  final _controller = TextEditingController(text: 'Table 1');

  @override
  void initState() {
    selectedItem = lotrItems.first;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        // List of Tool Operations with Drag and Drop
        Container(
          width: 250,
          child: ListView.builder(
              itemCount: lotrItems.length,
              itemBuilder: (context, index) {
                return CheckboxListTile(
                  value: selectedItem == lotrItems[index],
                  onChanged: (v) {
                    setState(() {
                      selectedItem = lotrItems[index];
                    });
                  },
                  title: Text(lotrItems[index]),
                );
              }),
        ),
        VerticalDivider(),
        Container(
          width: 250,
          child: ListView.builder(
              itemCount: tools.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(tools[index]),
                  trailing: !addedTools.contains(tools[index])
                      ? Icon(Icons.add_circle_outlined)
                      : Icon(Icons.remove_circle_outline),
                  onTap: () {
                    setState(() {
                      addedTools.add(tools[index]);
                    });
                  },
                );
              }),
        ),
        VerticalDivider(),

        Expanded(
          child: Stack(
            children: [
              Center(
                child: Text(
                  _controller.text,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              Center(
                child: Container(
                  width: 900,
                  height: 900,
                  child: DragTarget<String>(
                    builder: (context, candidateData, rejectedData) {
                      return Container(
                        width: 900,
                        height: 900,
                        child: PieChart(
                          PieChartData(
                            sections: List.generate(
                                numberOfSections, (index) => index).map(
                              (e) {
                                var tool = null;
                                if (addedTools.length > e) {
                                  tool = addedTools[e];
                                }

                                return PieChartSectionData(
                                  color: Colors.blue[300],
                                  value: 1,
                                  title: tool ?? (e + 1).toString(),
                                  radius: 230,
                                  titlePositionPercentageOffset: 0.6,
                                  badgeWidget: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          if (tool != null) {
                                            addedTools.removeLast();
                                          } else {
                                            showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    title: Text('Add a tool'),
                                                    content: SizedBox(
                                                      height: 450,
                                                      width: 250,
                                                      child: ListView.builder(
                                                        itemBuilder: (context,
                                                                index) =>
                                                            ListTile(
                                                                trailing: Icon(
                                                                    Icons.add),
                                                                title: Text(
                                                                  tools[index],
                                                                ),
                                                                onTap: () {
                                                                  setState(() {
                                                                    addedTools.add(
                                                                        tools[
                                                                            index]);
                                                                  });
                                                                }),
                                                        itemCount: tools.length,
                                                      ),
                                                    ),
                                                  );
                                                });
                                          }
                                        });
                                      },
                                      icon: tool == null
                                          ? Icon(
                                              Icons.add_circle_outline_outlined)
                                          : Icon(Icons
                                              .remove_circle_outline_outlined),
                                    ),
                                  ),
                                  badgePositionPercentageOffset: 0.85,
                                );
                              },
                            ).toList(),
                            centerSpaceRadius: 65,
                            sectionsSpace: 6,
                            startDegreeOffset: 180,
                          ),
                        ),
                      );
                    },
                    onWillAccept: (data) {
                      return true;
                    },
                    onAccept: (data) {
                      addToPieChart(data);
                      removeItem(data);
                    },
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  margin: EdgeInsets.all(12),
                  width: 200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _controller,
                        onChanged: (v) {
                          setState(() {});
                        },
                        decoration:
                            InputDecoration(helperText: 'Roundtable name'),
                      ),
                      Slider(
                        value: (numberOfSections / 30),
                        onChanged: (v) {
                          setState(() {
                            numberOfSections = (v * 30).toInt().clamp(1, 30);
                          });
                        },
                      ),
                      Text(
                        'Number of sections: $numberOfSections',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  void addToPieChart(String item) {
    setState(() {
      //pieChartSections.add(
      //  PieChartSectionData(
      //    color: Colors
      //        .primaries[pieChartSections.length % Colors.primaries.length],
      //    value: 1,
      //    title: item,
      //  ),
      //);
    });
  }

  void removeItem(String item) {
    setState(() {
      lotrItems.remove(item);
    });
  }
}
