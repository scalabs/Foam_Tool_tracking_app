import 'package:alati_app/cubits/carrier_allocation_cubit.dart';
import 'package:alati_app/cubits/planning_cubit.dart';
import 'package:alati_app/cubits/tool_fetcher_cubit.dart';
import 'package:alati_app/cubits/tool_selection_cubit.dart';
import 'package:alati_app/dashboard/dashboard.dart';
import 'package:alati_app/models/week_of_the_year.dart';
import 'package:alati_app/services/carrier_allocation_service.dart';
import 'package:alati_app/services/carrier_service.dart';
import 'package:alati_app/services/planning_service.dart';
import 'package:alati_app/services/table_name_service.dart';
import 'package:alati_app/services/tools_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubits/carrier_fetcher_cubit.dart';
import 'cubits/carrier_selection_cubit.dart';

void main() {
  runApp(const FoamApp());
}

class FoamApp extends StatelessWidget {
  const FoamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (context) => APIToolsService(),
        ),
        RepositoryProvider(
          create: (context) => APICarriersService(),
        ),
        RepositoryProvider(
          create: (context) => APITableNameService(),
        ),
        RepositoryProvider(
          create: (context) => APICarriersAllocationService(),
        ),
        RepositoryProvider(
          //ovo mijenjati kad se planiranje napravi kako treba
          create: (context) => FakePlanningService(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                ToolFetcherCubit(context.read<APIToolsService>()),
          ),
          BlocProvider(
            create: (context) =>
                ToolSelectionCubit(context.read<APIToolsService>()),
          ),
          BlocProvider(
            create: (context) => CarrierFetcherCubit(context.read<
                APICarriersService>()), // Initialize CarrierFetcherCubit with APICarriersService
          ),
          BlocProvider(
            create: (context) => CarrierSelectionCubit(
              context.read<APICarriersService>(),
              context.read<APICarriersAllocationService>(),
            ),
          ),
          BlocProvider(
            create: (context) => CarriersAllocationCubit(
                context.read<APICarriersAllocationService>()),
          ),
          BlocProvider(
            //ovo mijenjati kad se planiranje napravi kako treba
            create: (context) => PlanningCubit(
              selectedWeek: WeekOfTheYear(
                //selfRef: null,
                start: DateTime(2024, 1, 23),
                end: DateTime(2024, 1, 28),
                label: 'CW04',
                number: 4,
              ),
              service: context.read<FakePlanningService>(),
            ),
          )
        ],
        child: MaterialApp(
          home: const DashboardScreen(),
          theme: ThemeData(
            useMaterial3: false,
          ),
        ),
      ),
    );
  }
}
