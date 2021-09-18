class UserScope {
  final int value;

  /// Allows a user to create an issue.
  /// This scope is provided to all users by default.
  static const CreateIssue = 1 << 0;

  /// Allows a user to view active issues.
  static const ViewActiveIssue = 1 << 1;

  /// Allows a user to view resolved issues.
  static const ViewResolvedIssue = 1 << 2;

  /// Allows a user to perform resolve operation on an active issue.
  static const ResolveIssue = 1 << 3;

  /// Allows a user to purge an active issue whether or not the issue is owned
  /// by the user.
  static const PurgeAnyIssue = 1 << 4;

  /// Checks whether this instance has permission to the specified [scope].
  bool _hasPermissionTo(int scope) => value & scope != 0;

  /// Whether this user scope allows creating an issue.
  bool get canCreateIssue => _hasPermissionTo(CreateIssue);

  /// Whether this user scope allows viewing active issues.
  bool get canViewActiveIssue => _hasPermissionTo(ViewActiveIssue);

  /// Whether this user scope allows viewing resolved issues.
  bool get canViewResolvedIssue => _hasPermissionTo(ViewResolvedIssue);

  /// Whether this user scope allows resolving an active issue.
  bool get canResolveIssue => _hasPermissionTo(ResolveIssue);

  /// Whether this user scope allows purging an active issue.
  bool get canPurgeIssue => _hasPermissionTo(PurgeAnyIssue);

  /// Creates an instance with the specified scopes.
  const UserScope(this.value);

  /// The default user scope of new users.
  static const defaultScope = UserScope(CreateIssue);

  // Do not include code that can manipulate access to other permissions.
  // Should be handled by Admin Console / Firestore DB directly.

  @override
  String toString() => 'UserScope($value)';
}
