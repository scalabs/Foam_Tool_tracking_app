import 'package:alati_app/cubits/carrier_allocation_cubit.dart';
import 'package:alati_app/cubits/carrier_fetcher_cubit.dart';
import 'package:alati_app/cubits/carrier_selection_cubit.dart';
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

void main() {
  runApp(const DebugFoamApp());
}

class DebugFoamApp extends StatelessWidget {
  const DebugFoamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (context) => FakeToolsService(toolsCount: 22),
        ),
        RepositoryProvider(
          create: (context) => FakeCarrierService(carrierCount: 22),
        ),
        RepositoryProvider(
          create: (context) => FakeTableNameService(),
        ),
        RepositoryProvider(
          create: (context) => FakeCarrierAllocationService(carrierCount: 22),
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
                ToolFetcherCubit(context.read<FakeToolsService>()),
          ),
          BlocProvider(
            create: (context) =>
                ToolSelectionCubit(context.read<FakeToolsService>()),
          ),
          BlocProvider(
            create: (context) => CarrierFetcherCubit(context.read<
                FakeCarrierService>()), // Initialize CarrierFetcherCubit with APICarriersService
          ),
          BlocProvider(
            create: (context) => CarrierSelectionCubit(
              context.read<FakeCarrierService>(),
              context.read<FakeCarrierAllocationService>(),
            ),
          ),
          BlocProvider(
            create: (context) => CarriersAllocationCubit(
                context.read<FakeCarrierAllocationService>()),
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
