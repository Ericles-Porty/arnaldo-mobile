import 'package:arnaldo/features/relatorio/relatorio_controller.dart';
import 'package:arnaldo/features/relatorio/widgets/anual_tab.dart';
import 'package:arnaldo/features/relatorio/widgets/mensal_tab.dart';
import 'package:arnaldo/features/relatorio/widgets/periodo_tab.dart';
import 'package:arnaldo/models/pessoa.dart';
import 'package:flutter/material.dart';

class RelatorioPeriodoPage extends StatefulWidget {
  const RelatorioPeriodoPage({super.key, required this.pessoa});

  final Pessoa pessoa;

  @override
  State<RelatorioPeriodoPage> createState() => _RelatorioPeriodoPageState();
}

class _RelatorioPeriodoPageState extends State<RelatorioPeriodoPage> {
  late RelatorioController _controller;

  @override
  void initState() {
    super.initState();
    _controller = RelatorioController();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          title: Padding(
            padding: const EdgeInsets.only(right: 16),
            child:
                FittedBox(child: Text("Relatório de ${widget.pessoa.tipo} ${widget.pessoa.nome}", style: const TextStyle(color: Colors.white, fontSize: 36))),
          ),
          titleSpacing: NavigationToolbar.kMiddleSpacing,
          elevation: 0,
          backgroundColor: Theme.of(context).colorScheme.primary,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorWeight: 5,
            automaticIndicatorColorAdjustment: true,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'Período', icon: Icon(Icons.date_range)),
              Tab(text: 'Mensal', icon: Icon(Icons.calendar_view_month)),
              Tab(text: 'Anual', icon: Icon(Icons.calendar_month)),
              // Tab(text: 'Geral'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            PeriodoTab(pessoa: widget.pessoa),
            MensalTab(pessoa: widget.pessoa),
            AnualTab(pessoa: widget.pessoa),
            // Center(child: Text('Geral')),
          ],
        ),
      ),
    );
  }
}
