import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../i18n/strings.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/lang_toggle.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final s = app.s;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE8E4F4), AppColors.canvas],
          stops: [0, 0.4],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(s.profileTitle, style: AppText.serif(size: 26, color: AppColors.text)),
                  const LangToggle(),
                ],
              ),
            ),

            // Avatar
            Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(colors: [AppColors.lavender2, AppColors.pinkLight]),
                    boxShadow: [
                      BoxShadow(color: AppColors.lavender2.withOpacity(0.2), spreadRadius: 4),
                    ],
                  ),
                  child: const Center(child: Text('🌿', style: TextStyle(fontSize: 36))),
                ),
                const SizedBox(height: 12),
                Text(s.profileName, style: AppText.serif(size: 18, color: AppColors.text)),
                Text(s.profileSince, style: AppText.sans(size: 13, color: AppColors.muted)),
              ],
            ),
            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Language selector
                  Text(s.profileLanguage.toUpperCase(),
                      style: AppText.sans(size: 12, color: AppColors.muted, letterSpacing: 0.9)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: Lang.values.map((l) {
                        final active = app.lang == l;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => context.read<AppState>().setLang(l),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                gradient: active
                                    ? const LinearGradient(
                                        colors: [AppColors.lavender, AppColors.lavenderLight])
                                    : null,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(l == Lang.en ? '🇬🇧' : '🇻🇳',
                                      style: const TextStyle(fontSize: 18)),
                                  const SizedBox(width: 8),
                                  Text(l == Lang.en ? 'English' : 'Tiếng Việt',
                                      style: AppText.sans(
                                          size: 14,
                                          weight: active ? FontWeight.w600 : FontWeight.w400,
                                          color: active ? Colors.white : AppColors.muted)),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _section(s.profilePracticeSection, [
                    _Row(Icons.notifications_outlined, s.profileDailyReminder, '8:00 AM', AppColors.lavender),
                    _Row(Icons.nightlight_round, s.profileEveningReflection, s.profileOff, AppColors.lavender2),
                    _Row(Icons.menu_book_outlined, s.profileJournalPrompts, s.profileOn, AppColors.tealSoft),
                  ]),
                  const SizedBox(height: 16),

                  _section(s.profileAboutSection, [
                    _Row(Icons.info_outline, s.profileAboutMap, '', AppColors.lavender),
                    _Row(Icons.favorite_border, s.profileAcknowledgements, '', AppColors.pinkLight),
                    _Row(Icons.shield_outlined, s.profilePrivacy, '', AppColors.tealSoft),
                  ]),
                  const SizedBox(height: 16),

                  // Disclaimer
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.pinkLight.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.pinkLight.withOpacity(0.25), width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('◦ ${s.profileDisclaimerTitle.toUpperCase()}',
                            style: AppText.sans(size: 11, weight: FontWeight.w600, color: AppColors.pink, letterSpacing: 0.9)),
                        const SizedBox(height: 6),
                        Text(s.profileDisclaimerBody,
                            style: AppText.sans(size: 13, color: AppColors.textSoft, height: 1.7)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(s.profileVersion,
                        textAlign: TextAlign.center,
                        style: AppText.sans(size: 12, color: AppColors.muted3)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, List<_Row> rows) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.toUpperCase(),
            style: AppText.sans(size: 12, color: AppColors.muted, letterSpacing: 0.9)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++)
                Container(
                  decoration: BoxDecoration(
                    border: i > 0
                        ? Border(top: BorderSide(color: AppColors.lavender.withOpacity(0.08)))
                        : null,
                  ),
                  child: rows[i],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final String detail;
  final Color color;
  const _Row(this.icon, this.label, this.detail, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.125),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 17, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: AppText.sans(size: 15, color: AppColors.text)),
          ),
          if (detail.isNotEmpty)
            Text(detail, style: AppText.sans(size: 13, color: AppColors.muted2)),
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right, size: 16, color: AppColors.muted3),
        ],
      ),
    );
  }
}
