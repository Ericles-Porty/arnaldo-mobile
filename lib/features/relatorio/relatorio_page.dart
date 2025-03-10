import 'package:arnaldo/core/enums/pessoa_type.dart';
import 'package:arnaldo/features/relatorio/relatorio_controller.dart';
import 'package:arnaldo/widgets/my_app_bar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class RelatorioPage extends StatefulWidget {
  const RelatorioPage({super.key});

  @override
  State<RelatorioPage> createState() => _RelatorioPageState();
}

class AppColors {
  static const Color contentColorGreen = Color(0xFF26AC2E);
  static const Color contentColorTeal = Color(0xFF40AF93);
}

class _RelatorioPageState extends State<RelatorioPage> {
  late RelatorioController _controller;

  @override
  void initState() {
    super.initState();
    _controller = RelatorioController();
  }

  List<BarChartGroupData> get barGroups => [
        BarChartGroupData(
          x: 0,
          barRods: [
            BarChartRodData(
              toY: 8,
              gradient: _barsGradient,
            )
          ],
          showingTooltipIndicators: [0],
        ),
        BarChartGroupData(
          x: 1,
          barRods: [
            BarChartRodData(
              toY: 10,
              gradient: _barsGradient,
            )
          ],
          showingTooltipIndicators: [0],
        ),
        BarChartGroupData(
          x: 2,
          barRods: [
            BarChartRodData(
              toY: 14,
              gradient: _barsGradient,
            )
          ],
          showingTooltipIndicators: [0],
        ),
        BarChartGroupData(
          x: 3,
          barRods: [
            BarChartRodData(
              toY: 15,
              gradient: _barsGradient,
            )
          ],
          showingTooltipIndicators: [0],
        ),
        BarChartGroupData(
          x: 4,
          barRods: [
            BarChartRodData(
              toY: 13,
              gradient: _barsGradient,
            )
          ],
          showingTooltipIndicators: [0],
        ),
        BarChartGroupData(
          x: 5,
          barRods: [
            BarChartRodData(
              toY: 10,
              gradient: _barsGradient,
            )
          ],
          showingTooltipIndicators: [0],
        ),
        BarChartGroupData(
          x: 6,
          barRods: [
            BarChartRodData(
              toY: 16,
              gradient: _barsGradient,
            )
          ],
          showingTooltipIndicators: [0],
        ),
      ];

  FlTitlesData get titlesData => FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: getTitles,
          ),
        ),
        leftTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      );

  FlBorderData get borderData => FlBorderData(
        show: false,
      );

  LinearGradient get _barsGradient => const LinearGradient(
        colors: [
          AppColors.contentColorGreen,
          AppColors.contentColorTeal,
        ],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      );

  Widget getTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: AppColors.contentColorGreen,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    String text;
    switch (value.toInt()) {
      case 0:
        text = 'Seg';
        break;
      case 1:
        text = 'Ter';
        break;
      case 2:
        text = 'Qua';
        break;
      case 3:
        text = 'Qui';
        break;
      case 4:
        text = 'Sex';
        break;
      case 5:
        text = 'Sáb';
        break;
      case 6:
        text = 'Dom';
        break;
      default:
        text = '';
        break;
    }
    return SideTitleWidget(
      meta: meta,
      space: 4,
      child: Text(text, style: style),
    );
  }

  BarTouchData get barTouchData => BarTouchData(
        enabled: false,
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (group) => Colors.transparent,
          tooltipPadding: EdgeInsets.zero,
          tooltipMargin: 8,
          getTooltipItem: (
            BarChartGroupData group,
            int groupIndex,
            BarChartRodData rod,
            int rodIndex,
          ) {
            return BarTooltipItem(
              rod.toY.round().toString(),
              const TextStyle(
                color: AppColors.contentColorTeal,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
      );

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: myAppBar(
        context: context,
        title: 'Relatório',
        hasLeading: true,
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      Modular.to.pushNamed(
                        '/relatorio/pessoas',
                        arguments: PessoaType.cliente,
                      );
                    },
                    child: Text(
                      PessoaType.cliente.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 24),
                  TextButton(
                    onPressed: () {
                      Modular.to.pushNamed(
                        '/relatorio/pessoas',
                        arguments: PessoaType.fornecedor,
                      );
                    },
                    child: Text(
                      PessoaType.fornecedor.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/*
Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "Gráfico de Vendas por Semana",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: size.width / 2.5,
            height: size.height / 2.5,
            child: BarChart(
              BarChartData(
                barTouchData: barTouchData,
                titlesData: titlesData,
                borderData: borderData,
                barGroups: barGroups,
                gridData: const FlGridData(show: false),
                alignment: BarChartAlignment.spaceAround,
              ),
            ),
          ),
        ],
      ),
 */
