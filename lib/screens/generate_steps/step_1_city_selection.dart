import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/city_provider.dart';
import '../../providers/generate_provider.dart';
import '../../providers/metrics_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/city_search_widget.dart';

class Step1CitySelection extends StatefulWidget {
  const Step1CitySelection({Key? key}) : super(key: key);

  @override
  State<Step1CitySelection> createState() => _Step1CitySelectionState();
}

class _Step1CitySelectionState extends State<Step1CitySelection> {
  @override
  void initState() {
    super.initState();
    // Spusti meranie času ak ešte nebeží
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final metricsProvider = context.read<MetricsProvider>();
      if (!metricsProvider.isStarted) {
        metricsProvider.startTimer();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final generateProvider = context.read<GenerateProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ CitySearchWidget v Expanded (zaberie zvyšný priestor)
        Expanded(
          child: ChangeNotifierProvider.value(
            value: generateProvider.cityProvider,
            child: CitySearchWidget(
              onCitySelected: (city) {
                // City je už vybraté v provideri
              },
            ),
          ),
        ),

        // ✅ Zoznam s vybranými mestami (Wrap pre viac miest)
        Consumer<GenerateProvider>(
          builder: (context, provider, child) {
            if (provider.selectedCities.isNotEmpty) {
               return Container(
                 width: double.infinity,
                 margin: EdgeInsets.only(top: isMobile ? 12 : 16),
                 padding: EdgeInsets.all(isMobile ? 12 : 16),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Text(
                       'Vybrané mestá: ${provider.selectedCities.length}',
                       style: TextStyle(
                         fontWeight: FontWeight.w600,
                         fontSize: isMobile ? 15 : 16,
                         color: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppTheme.textDark,
                       ),
                     ),
                     const SizedBox(height: 12),
                     Wrap(
                       spacing: 8.0,
                       runSpacing: 8.0,
                       children: provider.selectedCities.map((city) {
                         final isDark = Theme.of(context).brightness == Brightness.dark;
                         final containerBg = isDark ? const Color(0xFF1B3320) : Colors.green.shade50;
                         final borderColor = isDark ? Colors.green.shade900 : Colors.green.shade200;
                         final iconColor = isDark ? Colors.green.shade400 : Colors.green;
                         final textColor = isDark ? Colors.white : AppTheme.textDark;

                         return Container(
                           padding: EdgeInsets.symmetric(
                             horizontal: isMobile ? 10 : 12,
                             vertical: isMobile ? 8 : 10,
                           ),
                           decoration: BoxDecoration(
                             color: containerBg,
                             borderRadius: BorderRadius.circular(12),
                             border: Border.all(color: borderColor),
                           ),
                           child: Row(
                             mainAxisSize: MainAxisSize.min,
                             children: [
                               Icon(
                                 Icons.check_circle,
                                 color: iconColor,
                                 size: isMobile ? 18 : 20,
                               ),
                               const SizedBox(width: 8),
                               Text(
                                 city.name,
                                 style: TextStyle(
                                   fontWeight: FontWeight.w600,
                                   fontSize: isMobile ? 13 : 14,
                                   color: textColor,
                                 ),
                               ),
                               const SizedBox(width: 8),
                               InkWell(
                                 onTap: () {
                                   provider.cityProvider.removeCity(city);
                                 },
                                 child: Container(
                                   padding: const EdgeInsets.all(4),
                                   decoration: BoxDecoration(
                                     color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
                                     shape: BoxShape.circle,
                                   ),
                                   child: Icon(Icons.close, size: isMobile ? 14 : 16, color: textColor),
                                 ),
                               ),
                             ],
                           ),
                         );
                       }).toList(),
                     ),
                   ],
                 ),
               );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}
