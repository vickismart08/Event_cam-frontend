/// Lightweight host identity for UI (backed by Firebase Auth).
class HostUser {
  const HostUser({required this.email, this.displayName});

  final String email;
  final String? displayName;
}
