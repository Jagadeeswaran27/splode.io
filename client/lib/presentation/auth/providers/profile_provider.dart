import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:client/presentation/auth/providers/auth_provider.dart';

class UserProfile {
  final String id;
  final String username;
  final String? avatarUrl;
  final bool isGuest;
  final int totalWins;
  final int totalLosses;
  final int blastPoints;

  UserProfile({
    required this.id,
    required this.username,
    this.avatarUrl,
    required this.isGuest,
    required this.totalWins,
    required this.totalLosses,
    required this.blastPoints,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json, {User? user}) {
    // Attempt to get name from DB, fallback to Google Metadata, fallback to default
    String username = (json['username'] as String?) ?? '';
    if (username.isEmpty && user != null) {
      username =
          (user.userMetadata?['full_name'] as String?) ??
          (user.userMetadata?['name'] as String?) ??
          'Player';
    } else if (username.isEmpty) {
      username = 'Player';
    }

    // Attempt to get avatar from DB, fallback to Google Metadata
    String? avatarUrl = json['avatar_url'] as String?;
    if ((avatarUrl == null || avatarUrl.isEmpty) && user != null) {
      avatarUrl =
          (user.userMetadata?['avatar_url'] as String?) ??
          (user.userMetadata?['picture'] as String?);
    }

    return UserProfile(
      id: json['id'] as String,
      username: username,
      avatarUrl: avatarUrl,
      isGuest: json['is_guest'] as bool? ?? false,
      totalWins: json['total_wins'] as int? ?? 0,
      totalLosses: json['total_losses'] as int? ?? 0,
      blastPoints: json['blast_points'] as int? ?? 1200,
    );
  }
}

/// A provider that fetches and caches the current user's profile from the database.
final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  try {
    final data = await Supabase.instance.client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single();

    return UserProfile.fromJson(data, user: user);
  } catch (e) {
    // If the profile doesn't exist yet (e.g. trigger delay) or fetch fails,
    // return a local fallback using user metadata so the UI doesn't break.
    return UserProfile.fromJson({
      'id': user.id,
      'is_guest': user.isAnonymous,
    }, user: user);
  }
});
