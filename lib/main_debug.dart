import 'package:alati_app/cubits/tool_fetcher_cubit.dart';
import 'package:alati_app/cubits/tool_selection_cubit.dart';
import 'package:alati_app/dashboard/dashboard.dart';
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
    return RepositoryProvider(
      create: (context) => FakeToolsService(toolsCount: 22),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                ToolFetcherCubit(context.read<FakeToolsService>()),
          ),
          BlocProvider(
            create: (context) => ToolSelectionCubit(),
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
