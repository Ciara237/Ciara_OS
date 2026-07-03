import 'dart:convert';

import 'package:ciaraos/models/security_activity.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists last-known security API payloads so the screen survives 502/rate limits.
abstract final class SecurityCache {
  static const _htbKey = 'security_htb_profile_json';
  static const _h1Key = 'security_h1_profile_json';

  static Future<HackTheBoxProfile?> loadHackTheBox() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_htbKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      return HackTheBoxProfile.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveHackTheBox(HackTheBoxProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_htbKey, jsonEncode(_htbToJson(profile)));
  }

  static Future<HackerOneProfile?> loadHackerOne() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_h1Key);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      return HackerOneProfile.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveHackerOne(HackerOneProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_h1Key, jsonEncode(_h1ToJson(profile)));
  }

  static Map<String, dynamic> _htbToJson(HackTheBoxProfile profile) {
    return {
      'username': profile.username,
      'avatar_url': profile.avatarUrl,
      'rank': profile.rank,
      'points': profile.points,
      'global_rank': profile.globalRank,
      'machines_owned': profile.machinesOwned,
      'challenges_solved': profile.challengesSolved,
      'streak': profile.streak,
      'skill_coverage': profile.skillCoverage,
      'recent_activity': profile.recentActivity
          .map<Map<String, dynamic>>(
            (item) => {
              'name': item.name,
              'type': item.type,
              'difficulty': item.difficulty,
              'points': item.points,
              'date': item.date.toIso8601String(),
            },
          )
          .toList(),
      'synced_at': profile.syncedAt.toIso8601String(),
    };
  }

  static Map<String, dynamic> _h1ToJson(HackerOneProfile profile) {
    return {
      'username': profile.username,
      'reputation': profile.reputation,
      'signal': profile.signal,
      'impact': profile.impact,
      'reports_submitted': profile.reportsSubmitted,
      'reports_resolved': profile.reportsResolved,
      'thanks_count': profile.thanksCount,
      'recent_reports': profile.recentReports
          .map<Map<String, dynamic>>(
            (report) => {
              'title': report.title,
              'program': report.program,
              'severity': report.severity,
              'status': report.status,
              'date': report.date.toIso8601String(),
              if (report.bounty != null) 'bounty': report.bounty,
            },
          )
          .toList(),
      'bounty_summary': {
        'total_earned': profile.bountySummary.totalEarned,
        'by_severity': profile.bountySummary.bySeverity,
      },
      'synced_at': profile.syncedAt.toIso8601String(),
    };
  }
}
