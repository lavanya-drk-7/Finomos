class AdminUserRecord {
  final String id;
  final String name;
  final String email;
  final bool isActive;
  final String joinedOn;

  const AdminUserRecord({
    required this.id,
    required this.name,
    required this.email,
    required this.isActive,
    required this.joinedOn,
  });

  AdminUserRecord copyWith({
    String? id,
    String? name,
    String? email,
    bool? isActive,
    String? joinedOn,
  }) {
    return AdminUserRecord(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      isActive: isActive ?? this.isActive,
      joinedOn: joinedOn ?? this.joinedOn,
    );
  }
}

class AdminPanelState {
  final int totalUsers;
  final int kycCompleted;
  final int connectedAccounts;
  final int totalTransactions;
  final int pendingKyc;
  final List<AdminUserRecord> users;
  final String searchQuery;

  const AdminPanelState({
    this.totalUsers = 2458,
    this.kycCompleted = 1892,
    this.connectedAccounts = 1756,
    this.totalTransactions = 48902,
    this.pendingKyc = 566,
    required this.users,
    this.searchQuery = '',
  });

  AdminPanelState copyWith({
    int? totalUsers,
    int? kycCompleted,
    int? connectedAccounts,
    int? totalTransactions,
    int? pendingKyc,
    List<AdminUserRecord>? users,
    String? searchQuery,
  }) {
    return AdminPanelState(
      totalUsers: totalUsers ?? this.totalUsers,
      kycCompleted: kycCompleted ?? this.kycCompleted,
      connectedAccounts: connectedAccounts ?? this.connectedAccounts,
      totalTransactions: totalTransactions ?? this.totalTransactions,
      pendingKyc: pendingKyc ?? this.pendingKyc,
      users: users ?? this.users,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}
