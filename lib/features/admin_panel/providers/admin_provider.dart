import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/admin_models.dart';

class AdminNotifier extends Notifier<AdminPanelState> {
  @override
  AdminPanelState build() {
    return const AdminPanelState(
      users: [
        AdminUserRecord(id: 'u_1', name: 'Aarav Sharma', email: 'aarav@gmail.com', isActive: true, joinedOn: '12 Sep 2025'),
        AdminUserRecord(id: 'u_2', name: 'Priya Nair', email: 'priya@gmail.com', isActive: true, joinedOn: '10 Sep 2025'),
        AdminUserRecord(id: 'u_3', name: 'Rohit Kumar', email: 'rohit@gmail.com', isActive: false, joinedOn: '08 Sep 2025'),
        AdminUserRecord(id: 'u_4', name: 'Sneha Reddy', email: 'sneha@gmail.com', isActive: true, joinedOn: '05 Sep 2025'),
        AdminUserRecord(id: 'u_5', name: 'Vikram Singh', email: 'vikram@gmail.com', isActive: true, joinedOn: '03 Sep 2025'),
      ],
    );
  }

  void toggleUserStatus(String id) {
    final updated = state.users.map((u) => u.id == id ? u.copyWith(isActive: !u.isActive) : u).toList();
    state = state.copyWith(users: updated);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }
}

final adminProvider = NotifierProvider<AdminNotifier, AdminPanelState>(() {
  return AdminNotifier();
});
