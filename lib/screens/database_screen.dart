import 'package:flutter/material.dart';
import 'package:vyjadrenia/screens/database_sections/cities_section.dart';
import 'package:vyjadrenia/widgets/processing_animations.dart';
import 'package:vyjadrenia/screens/database_sections/applications_section.dart';
import 'package:vyjadrenia/screens/database_sections/city_offices_section.dart';
import 'package:vyjadrenia/screens/database_sections/designer_team_members_section.dart';
import 'package:vyjadrenia/screens/database_sections/project_designers_section.dart';
import 'package:vyjadrenia/screens/database_sections/office_cities_section.dart';
import 'package:vyjadrenia/screens/database_sections/automation_section.dart';
import 'database_sections/building_purposes_section.dart';
import 'database_sections/text_types_section.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import '../widgets/feature_card.dart';

class DatabaseScreen extends StatefulWidget {
  const DatabaseScreen({Key? key}) : super(key: key);

  @override
  State<DatabaseScreen> createState() => _DatabaseScreenState();
}

class _DatabaseScreenState extends State<DatabaseScreen> {
  String? selectedSubsection;

  final List<DatabaseSection> sections = [
    DatabaseSection(
      id: 'cities',
      title: 'Mestá a obce a dano',
      description: 'Správa miest a obcí v systéme',
      icon: Icons.location_city_rounded,
      color: Colors.blue,
    ),
    DatabaseSection(
      id: 'offices',
      title: 'Úrady a inštitúcie',
      description: 'Zoznam úradov a ich kontaktné údaje',
      icon: Icons.business_rounded,
      color: Colors.green,
    ),
    DatabaseSection(
      id: 'designers',
      title: 'Projektanti s oprávneniami',
      description: 'Správa projektantov a ich údajov',
      icon: Icons.engineering_rounded,
      color: Colors.amber,
    ),
    DatabaseSection(
      id: 'city-offices',
      title: 'Mesto-Úrady',
      description: 'Prepojenie miest s príslušnými úradmi',
      icon: Icons.account_tree_rounded,
      color: Colors.orange,
    ),
    DatabaseSection(
      id: 'office-cities',
      title: 'Úrad-Mestá',
      description: 'Prehľad miest podľa úradov',
      icon: Icons.hub_rounded,
      color: Colors.purple,
    ),
    DatabaseSection(
      id: 'automation-add',
      title: 'Automatizácia',
      description: 'Automatické priradenie uradov a miest',
      icon: Icons.auto_awesome_rounded,
      color: Colors.teal,
    ),
    DatabaseSection(
      id: 'text-editing',
      title: 'Editácia textov',
      description: 'Úprava textových šablón a formulácií',
      icon: Icons.edit_note_rounded,
      color: Colors.pink,
    ),
    DatabaseSection(
      id: 'building-purposes',
      title: 'Účel vyjadrení',
      description: 'Kategórie a typy vyjadrení',
      icon: Icons.category_rounded,
      color: Colors.cyan,
    ),
    DatabaseSection(
      id: 'desigenr-team-members',
      title: 'Projektanti',
      description: 'Projektanti, ktori môžu pracovať na projektoch',
      icon: Icons.category_rounded,
      color: Colors.cyan,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.05, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: selectedSubsection == null
          ? _buildMainView()
          : _buildSubsectionView(selectedSubsection!),
    );
  }

  Widget _buildMainView() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768; // ✅ Pridané

    return SingleChildScrollView(
      key: const ValueKey('main'),
      padding: EdgeInsets.all(isMobile ? 16 : AppConstants.largePadding), // ✅ Responsívny padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(isMobile), // ✅ Pridaný parameter
          SizedBox(height: isMobile ? 20 : 32), // ✅
          _buildFeaturesGrid(isMobile), // ✅ Pridaný parameter
        ],
      ),
    );
  }

  Widget _buildSectionHeader(bool isMobile) { // ✅ Pridaný parameter
    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 28), // ✅ Menší padding
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade600, Colors.blue.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16), // ✅
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: isMobile ? 15 : 20, // ✅
            offset: Offset(0, isMobile ? 4 : 8), // ✅
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Databázy',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: AppTheme.white,
                    fontSize: isMobile ? 24 : null, // ✅ Menší text
                  ),
                ),
                SizedBox(height: isMobile ? 6 : 8),
                Text(
                  'Centralizovaná správa všetkých dát v systéme',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.white.withOpacity(0.95),
                    fontSize: isMobile ? 14 : null, // ✅ Menší text
                  ),
                ),
              ],
            ),
          ),
          if (!isMobile) ...[ // ✅ Skryť ikonu na mobile
            const SizedBox(width: 24),
            SizedBox(
              width: 100,
              height: 100,
              child: IsometricDocumentAnimation(
                size: 100,
                accentColor: Colors.blue.shade400,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFeaturesGrid(bool isMobile) { // ✅ Pridaný parameter
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded( // ✅ Pridané pre overflow
              child: Text(
                'Dostupné sekcie',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: isDark ? Colors.white : null,
                  fontSize: isMobile ? 18 : null, // ✅ Menší text
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 8 : 10, // ✅
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppTheme.primaryRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${sections.length}',
                style: TextStyle(
                  fontSize: isMobile ? 12 : 13, // ✅
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryRed,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: isMobile ? 16 : 20), // ✅
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isMobile ? 1 : 3, // ✅ 1 stĺpec na mobile, 3 na desktop
            crossAxisSpacing: isMobile ? 12 : 20, // ✅
            mainAxisSpacing: isMobile ? 12 : 20, // ✅
            childAspectRatio: isMobile ? 2.5 : 1.35, // ✅ Širší pomer na mobile
          ),
          itemCount: sections.length,
          itemBuilder: (context, index) {
            final section = sections[index];
            return _buildDatabaseFeatureCard(section);
          },
        ),
      ],
    );
  }

  Widget _buildDatabaseFeatureCard(DatabaseSection section) {
    return FeatureCard(
      title: section.title,
      description: section.description,
      icon: section.icon,
      onTap: () {
        if (section.id == 'cities') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CitiesSection()),
          );
        } else if (section.id == 'offices') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ApplicationsSection()),
          );
        } else if (section.id == 'designers') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProjectDesignersSection()),
          );
        } else if (section.id == 'building-purposes') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BuildingPurposesSection()),
          );
        } else if (section.id == 'city-offices') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CityOfficesSection()),
          );
        } else if (section.id == 'office-cities') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const OfficeCitiesSection()),
          );
        } else if (section.id == 'automation-add') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AutomationSection()),
          );
        } else if (section.id == 'text-editing') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TextTypesSection()),
          );
        } else if (section.id == 'desigenr-team-members') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DesignerTeamMembersSection()),
          );
        } else {
          setState(() {
            selectedSubsection = section.id;
          });
        }
      },
    );
  }

  Widget _buildSubsectionView(String subsectionId) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768; // ✅ Pridané

    final section = sections.firstWhere((s) => s.id == subsectionId);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final placeholderBg = isDark ? AppTheme.darkCard : AppTheme.white;
    final placeholderBorder = isDark ? Colors.white.withOpacity(0.1) : AppTheme.borderColor;
    final breadcrumbBg = isDark ? Colors.white.withOpacity(0.1) : AppTheme.white;
    final breadcrumbBorder = isDark ? Colors.white.withOpacity(0.1) : AppTheme.borderColor;
    final breadcrumbIconColor = isDark ? Colors.white : AppTheme.textDark;
    final infoBoxBg = isDark ? AppTheme.darkSurface : AppTheme.lightGray;

    return SingleChildScrollView(
      key: ValueKey(subsectionId),
      padding: EdgeInsets.all(isMobile ? 16 : AppConstants.largePadding), // ✅ Responsívny padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumb
          Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    selectedSubsection = null;
                  });
                },
                icon: Icon(
                  Icons.arrow_back_rounded,
                  color: breadcrumbIconColor,
                  size: isMobile ? 20 : 24, // ✅
                ),
                tooltip: 'Späť na prehľad',
                style: IconButton.styleFrom(
                  backgroundColor: breadcrumbBg,
                  side: BorderSide(color: breadcrumbBorder),
                  padding: EdgeInsets.all(isMobile ? 8 : 12), // ✅
                ),
              ),
              SizedBox(width: isMobile ? 8 : 16), // ✅
              if (!isMobile) ...[ // ✅ Skryť breadcrumb text na mobile
                Text(
                  'Databázy',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : AppTheme.textMedium,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 16,
                  color: isDark ? Colors.white30 : AppTheme.textLight,
                ),
                const SizedBox(width: 8),
              ],
              Expanded( // ✅ Pridané pre overflow
                child: Text(
                  section.title,
                  style: TextStyle(
                    fontSize: isMobile ? 13 : 14, // ✅
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppTheme.textDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 16 : 24), // ✅

          // Obsah subsekcie
          Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: isMobile ? double.infinity : 600), // ✅
              padding: EdgeInsets.all(isMobile ? 24 : 48), // ✅ Menší padding
              decoration: BoxDecoration(
                color: placeholderBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: placeholderBorder, width: 1),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: isMobile ? 80 : 100, // ✅ Menšia ikona
                    height: isMobile ? 80 : 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          section.color.withOpacity(0.15),
                          section.color.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(
                      section.icon,
                      size: isMobile ? 40 : 50, // ✅ Menšia ikona
                      color: section.color,
                    ),
                  ),
                  SizedBox(height: isMobile ? 20 : 32), // ✅
                  Text(
                    section.title,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: isDark ? Colors.white : null,
                      fontSize: isMobile ? 20 : null, // ✅ Menší text
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: isMobile ? 8 : 12), // ✅
                  Text(
                    section.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.white70 : null,
                      fontSize: isMobile ? 14 : null, // ✅
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: isMobile ? 20 : 32), // ✅
                  Container(
                    padding: EdgeInsets.all(isMobile ? 16 : 20), // ✅
                    decoration: BoxDecoration(
                      color: infoBoxBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.construction_rounded,
                          size: isMobile ? 32 : 40, // ✅
                          color: isDark ? Colors.white54 : AppTheme.textLight,
                        ),
                        SizedBox(height: isMobile ? 8 : 12), // ✅
                        Text(
                          'Sekcia je v príprave',
                          style: TextStyle(
                            fontSize: isMobile ? 14 : 15, // ✅
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : AppTheme.textMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: isMobile ? 20 : 24), // ✅
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        selectedSubsection = null;
                      });
                    },
                    icon: Icon(
                      Icons.arrow_back_rounded,
                      size: isMobile ? 16 : 18, // ✅
                    ),
                    label: Text(
                      'Späť na prehľad',
                      style: TextStyle(fontSize: isMobile ? 14 : null), // ✅
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? Colors.white : null,
                      side: isDark ? BorderSide(color: Colors.white.withOpacity(0.2)) : null,
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 16 : 20, // ✅
                        vertical: isMobile ? 12 : 14, // ✅
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DatabaseSection {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  DatabaseSection({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
