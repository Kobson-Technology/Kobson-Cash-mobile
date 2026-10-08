import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:ota_update/ota_update.dart';
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
      builder: (ctx) => _InAppUpdateDialog(info: info),
    );
  }
}

class _InAppUpdateDialog extends StatefulWidget {
  final AppVersionInfo info;

  const _InAppUpdateDialog({required this.info});

  @override
  State<_InAppUpdateDialog> createState() => _InAppUpdateDialogState();
}

class _InAppUpdateDialogState extends State<_InAppUpdateDialog> {
  bool _isDownloading = false;
  double _progress = 0.0;
  String _statusText = 'Prêt à télécharger';
  String? _errorMessage;

  void _startOtaUpdate() {
    if (!Platform.isAndroid) {
      _openExternalBrowser();
      return;
    }

    setState(() {
      _isDownloading = true;
      _progress = 0.0;
      _statusText = 'Initialisation du téléchargement...';
      _errorMessage = null;
    });

    try {
      OtaUpdate().execute(
        widget.info.downloadUrl,
        destinationFilename: 'KobsonCash_${widget.info.latestVersion}.apk',
      ).listen(
        (OtaEvent event) {
          if (!mounted) return;
          switch (event.status) {
            case OtaStatus.DOWNLOADING:
              final val = double.tryParse(event.value ?? '') ?? _progress;
              setState(() {
                _progress = val.clamp(0.0, 100.0);
                _statusText = 'Téléchargement de la mise à jour (${_progress.toInt()}%)...';
              });
              break;
            case OtaStatus.INSTALLING:
              setState(() {
                _progress = 100.0;
                _statusText = 'Ouverture de l\'installateur Android...';
              });
              break;
            case OtaStatus.ALREADY_RUNNING_ERROR:
              setState(() {
                _statusText = 'Un téléchargement est déjà en cours...';
              });
              break;
            case OtaStatus.PERMISSION_NOT_GRANTED_ERROR:
              setState(() {
                _isDownloading = false;
                _errorMessage = 'Permission requise pour installer l\'application.';
              });
              break;
            case OtaStatus.INTERNAL_ERROR:
            case OtaStatus.DOWNLOAD_ERROR:
            case OtaStatus.CHECKSUM_ERROR:
            default:
              setState(() {
                _isDownloading = false;
                _errorMessage = 'Le téléchargement direct a échoué. Utilisez le lien ci-dessous.';
              });
              break;
          }
        },
        onError: (err) {
          if (!mounted) return;
          setState(() {
            _isDownloading = false;
            _errorMessage = 'Erreur: $err. Utilisez le lien de secours.';
          });
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isDownloading = false;
        _errorMessage = 'Erreur d\'initialisation: $e';
      });
    }
  }

  Future<void> _openExternalBrowser() async {
    final uri = Uri.parse(widget.info.downloadUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = widget.info;

    return PopScope(
      canPop: !info.forceUpdate && !_isDownloading,
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
              child: const Icon(Icons.system_update_rounded, color: AppColors.primaryBlue, size: 26),
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
            if (!_isDownloading && _errorMessage == null) ...[
              const Text(
                'Une nouvelle version de Kobson Cash est disponible. Mettez à jour directement sans quitter l\'application.',
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
            ],

            // Downloading Progress Section
            if (_isDownloading) ...[
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _statusText,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                  ),
                  Text(
                    '${_progress.toInt()}%',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: _progress > 0 ? _progress / 100 : null,
                  minHeight: 10,
                  backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.15),
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Restez sur cet écran. L\'installateur Android s\'ouvrira automatiquement à 100%.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],

            // Error Display
            if (_errorMessage != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.errorRed.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.errorRed.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.errorRed, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(fontSize: 12, color: AppColors.errorRed),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Main Action Button
            if (!_isDownloading) ...[
              ElevatedButton.icon(
                onPressed: _startOtaUpdate,
                icon: const Icon(Icons.system_update_alt_rounded, color: Colors.white, size: 20),
                label: const Text(
                  'Mettre à jour directement',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 2,
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: _openExternalBrowser,
                  icon: const Icon(Icons.open_in_browser, size: 18),
                  label: const Text('Télécharger via le navigateur'),
                ),
              ],
              if (!info.forceUpdate) ...[
                const SizedBox(height: 6),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Plus tard', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
                ),
              ],
            ] else ...[
              TextButton.icon(
                onPressed: _openExternalBrowser,
                icon: const Icon(Icons.open_in_browser, size: 16),
                label: const Text(
                  'Passer par le navigateur',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
