import 'package:flutter/foundation.dart';
import '../models/designer_team_member_model.dart';
import '../services/designer_team_member_service.dart';

class DesignerTeamMemberEditProvider extends ChangeNotifier {
  final DesignerTeamMemberService _service = DesignerTeamMemberService();

  List<DesignerTeamMember> _members = [];
  DesignerTeamMember? _selectedMember;
  bool _isLoading = false;
  String? _error;

  List<DesignerTeamMember> get members => _members;
  DesignerTeamMember? get selectedMember => _selectedMember;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Načítaj všetkých členov tímu
  Future<void> loadAllMembers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _members = await _service.getAllDesignerTeamMembers();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _members = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Vyčisti zoznam
  void clearList() {
    _members = [];
    _selectedMember = null;
    _error = null;
    notifyListeners();
  }

  /// Vyber člena tímu
  void selectMember(DesignerTeamMember member) {
    _selectedMember = member;
    notifyListeners();
  }

  /// Zruš výber
  void clearSelection() {
    _selectedMember = null;
    notifyListeners();
  }

  /// Vytvor nového člena tímu
  Future<void> createMember(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newMember = await _service.createDesignerTeamMember(data);
      _members.add(newMember);
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Aktualizuj člena tímu
  Future<void> updateMember(int id, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _service.updateDesignerTeamMember(id, data);

      // Aktualizuj v zozname
      final index = _members.indexWhere((m) => m.id == id);
      if (index != -1) {
        _members[index] = updated;
      }

      // Aktualizuj výber
      if (_selectedMember?.id == id) {
        _selectedMember = updated;
      }

      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Zmaž člena tímu
  Future<void> deleteMember(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.deleteDesignerTeamMember(id);

      // Odstráň zo zoznamu
      _members.removeWhere((m) => m.id == id);

      // Vyčisti výber ak bol zmazaný
      if (_selectedMember?.id == id) {
        _selectedMember = null;
      }

      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Vyhľadaj členov tímu
  Future<void> searchMembers({String? name, String? email}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _members = await _service.searchDesignerTeamMembers(
        name: name,
        email: email,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
      _members = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}