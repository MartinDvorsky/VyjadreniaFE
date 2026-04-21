import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/designer_team_member_model.dart';
import '../services/designer_team_member_service.dart';
import '../providers/step2_data_provider.dart';
import '../utils/app_theme.dart'; // Uisti sa, že cesta k téme je správna

class TeamMemberSelector extends StatefulWidget {
  const TeamMemberSelector({Key? key}) : super(key: key);

  @override
  State<TeamMemberSelector> createState() => _TeamMemberSelectorState();
}

class _TeamMemberSelectorState extends State<TeamMemberSelector> {
  final DesignerTeamMemberService _service = DesignerTeamMemberService();
  List<DesignerTeamMember> _teamMembers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTeamMembers();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<Step2DataProvider>();
      if (provider.selectedTeamMember == null) {
        provider.tryAutoFillTeamMember();
      }
    });
  }

  Future<void> _loadTeamMembers() async {
    setState(() => _isLoading = true);
    try {
      final members = await _service.getAllDesignerTeamMembers();
      setState(() {
        _teamMembers = members;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Chyba pri načítaní: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final step2Provider = context.watch<Step2DataProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Zjednodušený nadpis s ikonou, asteriskkou a refreshom v jednom riadku
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: RichText(
                text: TextSpan(
                  text: 'Vyberte projektanta, ktorý projekt vypracoval',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  children: [
                    TextSpan(
                      text: ' *',
                      style: TextStyle(
                        color: isDark ? Colors.red[400] : Colors.red[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_isLoading)
              const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
            else
              IconButton(
                icon: const Icon(Icons.refresh, size: 18),
                onPressed: _loadTeamMembers,
                tooltip: 'Obnoviť zoznam',
              ),
          ],
        ),
        const SizedBox(height: 8),

        // Čistý Dropdown bez zbytočného Card obalu
        DropdownButtonFormField<DesignerTeamMember>(
          value: _teamMembers.any((m) => m.id == step2Provider.selectedTeamMember?.id)
              ? _teamMembers.firstWhere((m) => m.id == step2Provider.selectedTeamMember?.id)
              : null,
          isExpanded: true,
          validator: (value) {
            if (value == null) {
              return 'Vyberte člena tímu, ktorý projekt vypracoval';
            }
            return null;
          },
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.person_outline,
                color: isDark ? Colors.white70 : AppTheme.primaryRed),
            hintText: '-- Vybrať projektanta --',
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
          ),
          items: [
            const DropdownMenuItem<DesignerTeamMember>(
              value: null,
              child: Text('Nepriradený'),
            ),
            ..._teamMembers.map((member) => DropdownMenuItem(
              value: member,
              child: Text(member.name), // Používame len meno pre čistotu
            )),
          ],
          onChanged: (newValue) => step2Provider.setSelectedTeamMember(newValue),
        ),

        // Decentné zobrazenie detailov pod dropdownom (len ak je vybraný)
        if (step2Provider.selectedTeamMember != null)
          Padding(
            padding: const EdgeInsets.only(top: 12, left: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(Icons.email_outlined, step2Provider.selectedTeamMember!.email),
                if (step2Provider.selectedTeamMember!.phone != null)
                  _buildInfoRow(Icons.phone_outlined, step2Provider.selectedTeamMember!.phone!),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}