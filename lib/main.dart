import 'package:alati_app/cubits/carrier_allocation_cubit.dart';
import 'package:alati_app/cubits/planning_cubit.dart';
import 'package:alati_app/cubits/tool_allocation_cubit.dart';
import 'package:alati_app/cubits/tool_fetcher_cubit.dart';
import 'package:alati_app/cubits/tool_selection_cubit.dart';
import 'package:alati_app/dashboard/dashboard.dart';
import 'package:alati_app/models/week_of_the_year.dart';
import 'package:alati_app/services/carrier_allocation_service.dart';
import 'package:alati_app/services/carrier_service.dart';
import 'package:alati_app/services/planning_service.dart';
import 'package:alati_app/services/table_name_service.dart';
import 'package:alati_app/services/tool_allocation_service.dart';
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
        RepositoryProvider<APIToolsService>(
          create: (context) => APIToolsService(),
        ),
        RepositoryProvider<APICarriersService>(
          create: (context) => APICarriersService(),
        ),
        RepositoryProvider<APITableNameService>(
          create: (context) => APITableNameService(),
        ),
        RepositoryProvider<APICarriersAllocationService>(
          create: (context) => APICarriersAllocationService(),
        ),
        RepositoryProvider<FakePlanningService>(
          create: (context) => FakePlanningService(),
        ),
        RepositoryProvider<APIToolsAllocationService>(
          create: (context) => APIToolsAllocationService(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ToolFetcherCubit>(
            create: (context) => ToolFetcherCubit(context.read<APIToolsService>()),
          ),
          BlocProvider<ToolSelectionCubit>(
            create: (context) => ToolSelectionCubit(
              context.read<APIToolsService>(),
              context.read<APIToolsAllocationService>(),
            ),
          ),
          BlocProvider<ToolsAllocationCubit>(
            create: (context) => ToolsAllocationCubit(context.read<APIToolsAllocationService>()),
          ),
          BlocProvider<CarrierFetcherCubit>(
            create: (context) => CarrierFetcherCubit(context.read<APICarriersService>()),
          ),
          BlocProvider<CarrierSelectionCubit>(
            create: (context) => CarrierSelectionCubit(
              context.read<APICarriersService>(),
              context.read<APICarriersAllocationService>(),
            ),
          ),
          BlocProvider<CarriersAllocationCubit>(
            create: (context) => CarriersAllocationCubit(context.read<APICarriersAllocationService>()),
          ),
          BlocProvider<PlanningCubit>(
            create: (context) => PlanningCubit(
              selectedWeek: WeekOfTheYear(
                start: DateTime(2024, 1, 23),
                end: DateTime(2024, 1, 28),
                label: 'CW04',
                number: 4,
              ),
              service: context.read<FakePlanningService>(),
            ),
          ),
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
