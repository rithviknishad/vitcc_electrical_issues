class UserScope {
  final int value;

  /// Allows a user to create an issue.
  /// This scope is provided to all users by default.
  static const createIssue = 1 << 0;

  /// Allows a user to view active issues.
  static const viewActiveIssues = 1 << 1;

  /// Allows a user to view resolved issues.
  static const viewResolvedIssues = 1 << 2;

  /// Allows a user to perform resolve operation on an active issue.
  static const resolveIssue = 1 << 3;

  /// Allows a user to purge an active issue whether or not the issue is owned
  /// by the user.
  static const purgeAnyIssue = 1 << 4;

  /// Checks whether this instance has permission to the specified [scope].
  bool hasPermissionTo(int scope) => value & scope != 0;

  /// Checks whether this instance has permission only for the specified [scope]
  /// and has no other permissions.
  bool hasPermissionToOnly(int scope) => value == scope;

  /// Whether this user scope allows creating an issue.
  bool get canCreateIssue => hasPermissionTo(createIssue);

  /// Whether this user scope allows viewing active issues.
  bool get canViewActiveIssues =>
      hasPermissionTo(viewActiveIssues) || hasPermissionTo(resolveIssue);

  /// Whether this user scope allows viewing resolved issues.
  bool get canViewResolvedIssues =>
      hasPermissionTo(viewResolvedIssues) || hasPermissionTo(resolveIssue);

  /// Whether this user scope allows resolving an active issue.
  bool get canResolveIssue => hasPermissionTo(resolveIssue);

  /// Whether this user scope allows purging an active issue.
  bool get canPurgeIssue => hasPermissionTo(purgeAnyIssue);

  /// Creates an instance with the specified scopes.
  const UserScope(this.value);

  /// The default user scope of new users.
  static const defaultScope = UserScope(createIssue);

  // NOTE: Do not include code that can manipulate access to other permissions.
  //       Should be handled by Admin Console / Firestore DB directly.

  @override
  String toString() => 'UserScope($value)';
}
