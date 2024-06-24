import 'package:alati_app/cubits/tool_fetcher_cubit.dart';
import 'package:alati_app/cubits/tool_selection_cubit.dart';
import 'package:alati_app/dashboard/dashboard.dart';
import 'package:alati_app/services/carrier_service.dart';
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
        ), RepositoryProvider(
          create: (context) => APICarriersService(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => ToolFetcherCubit(context.read<APIToolsService>()),
          ),
          BlocProvider(
            create: (context) => ToolSelectionCubit(),
          ),
          BlocProvider(
            create: (context) => CarrierFetcherCubit(context.read<APICarriersService>()), // Initialize CarrierFetcherCubit with APICarriersService
          ),
          BlocProvider(
            create: (context) => CarrierSelectionCubit(),
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
