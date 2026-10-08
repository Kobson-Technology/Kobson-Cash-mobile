import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../config/app_config.dart';
import '../network/api_client.dart';
import '../theme/app_theme.dart';
import '../../features/auth/providers/auth_provider.dart';

class AppVersionInfo {
  final String latestVersion;
  final int latestBuildNumber;
  final String minRequiredVersion;
  final String downloadUrl;
  final String releaseNotes;
  final bool forceUpdate;

  AppVersionInfo({
    required this.latestVersion,
    required this.latestBuildNumber,
    required this.minRequiredVersion,
    required this.downloadUrl,
    required this.releaseNotes,
    required this.forceUpdate,
  });

  factory AppVersionInfo.fromJson(Map<String, dynamic> json) {
    return AppVersionInfo(
      latestVersion: json['latestVersion']?.toString() ?? '1.0.0',
      latestBuildNumber: (json['latestBuildNumber'] as num?)?.toInt() ?? 1,
      minRequiredVersion: json['minRequiredVersion']?.toString() ?? '1.0.0',
      downloadUrl: json['downloadUrl']?.toString() ?? AppConfig.fallbackDownloadUrl,
      releaseNotes: json['releaseNotes']?.toString() ?? 'Mise à jour disponible avec améliorations et corrections.',
      forceUpdate: json['forceUpdate'] == true,
    );
  }

  factory AppVersionInfo.fromGitHubRelease(Map<String, dynamic> json) {
    final tagName = json['tag_name']?.toString() ?? 'v1.0.0';
    final cleanVersion = tagName.replaceAll(RegExp(r'^[vV]'), '');
    final body = json['body']?.toString() ?? 'Nouvelle version disponible.';

    String downloadUrl = AppConfig.fallbackDownloadUrl;
    final assets = json['assets'] as List<dynamic>?;
    if (assets != null && assets.isNotEmpty) {
      final apkAsset = assets.firstWhere(
        (a) => a['name']?.toString().endsWith('.apk') == true,
        orElse: () => assets.first,
      );
      if (apkAsset != null && apkAsset['browser_download_url'] != null) {
        downloadUrl = apkAsset['browser_download_url'];
      }
    }

    return AppVersionInfo(
      latestVersion: cleanVersion,
      latestBuildNumber: 1,
      minRequiredVersion: cleanVersion,
      downloadUrl: downloadUrl,
      releaseNotes: body,
      forceUpdate: false,
    );
  }
}

class AppUpdateService {
  /// Checks whether a remote version is higher than local version
  static bool isUpdateAvailable(AppVersionInfo remote) {
    if (remote.latestBuildNumber > AppConfig.appBuildNumber) {
      return true;
    }

    // Compare semantic version (e.g. 1.0.1 > 1.0.0)
    final localParts = AppConfig.appVersion.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final remoteParts = remote.latestVersion.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    for (int i = 0; i < 3; i++) {
      final local = i < localParts.length ? localParts[i] : 0;
      final rem = i < remoteParts.length ? remoteParts[i] : 0;
      if (rem > local) return true;
      if (rem < local) return false;
    }

    return false;
  }

  /// Fetches latest version from Backend API with GitHub fallback
  static Future<AppVersionInfo?> fetchLatestVersion(ApiClient apiClient) async {
    // 1. Try backend version endpoint
    try {
      final res = await apiClient.get('/api/v1/config/version', requiresAuth: false);
      return AppVersionInfo.fromJson(res);
    } catch (_) {
      // Backend endpoint might be unreachable or loading fallback
    }

    // 2. Direct GitHub Release API fallback
    try {
      final url = Uri.parse('https://api.github.com/repos/Kobson-Technology/Kobson-Cash-Versionnage/releases/latest');
      final res = await http.get(url, headers: {'Accept': 'application/vnd.github.v3+json'});
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return AppVersionInfo.fromGitHubRelease(data);
      }
    } catch (_) {
      // Offline or network error
    }

    return null;
  }

  /// Automatically checks for updates on startup/dashboard
  static Future<void> checkSilently(BuildContext context, WidgetRef ref) async {
    final apiClient = ref.read(apiClientProvider);
    final versionInfo = await fetchLatestVersion(apiClient);

    if (versionInfo != null && isUpdateAvailable(versionInfo) && context.mounted) {
      showUpdateDialog(context, versionInfo);
    }
  }

  /// Manually checks for updates from the Profile screen
  static Future<void> checkManually(BuildContext context, WidgetRef ref) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: AppColors.primaryBlue),
      ),
    );

    final apiClient = ref.read(apiClientProvider);
    final versionInfo = await fetchLatestVersion(apiClient);

    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop(); // Dismiss loading

      if (versionInfo != null && isUpdateAvailable(versionInfo)) {
        showUpdateDialog(context, versionInfo);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.successGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Votre application est à jour (${AppConfig.appVersion})',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }
  }

  /// Displays the official update dialog
  static void showUpdateDialog(BuildContext context, AppVersionInfo info) {
    showDialog(
      context: context,
      barrierDismissible: !info.forceUpdate,
      builder: (ctx) => PopScope(
        canPop: !info.forceUpdate,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          contentPadding: const EdgeInsets.all(24),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.system_update, color: AppColors.primaryBlue, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mise à jour disponible',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Version v${info.latestVersion}',
                      style: const TextStyle(fontSize: 13, color: AppColors.primaryBlue, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Une nouvelle version de Kobson Cash est disponible. Mettez à jour pour profiter des dernières fonctionnalités et correctifs.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
              ),
              if (info.releaseNotes.isNotEmpty) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Nouveautés :',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        info.releaseNotes,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () async {
                  final uri = Uri.parse(info.downloadUrl);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                icon: const Icon(Icons.download_rounded, color: Colors.white, size: 20),
                label: const Text(
                  'Télécharger & Installer',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 2,
                ),
              ),
              if (!info.forceUpdate) ...[
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Plus tard', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
