import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../i18n/strings.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/lang_toggle.dart';
import '../widgets/paper_background.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final s = app.s;
    final vi = s.lang == Lang.vi;

    return PaperBackground(
      tint: const Color(0xFFF4E6D2),
      blob: AppColors.pinkLight,
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
                  child: const Center(child: Icon(Icons.spa_rounded, size: 36, color: Colors.white)),
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
                      color: AppColors.paper.withOpacity(0.85),
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
                    _Row(Icons.notifications_outlined, s.profileDailyReminder, '8:00 AM', AppColors.lavender,
                        onTap: () => _showProfileSheet(context,
                            icon: Icons.notifications_outlined,
                            color: AppColors.lavender,
                            title: s.profileDailyReminder,
                            body: vi
                                ? 'Nhận một lời nhắc nhẹ nhàng mỗi ngày để dừng lại và ghi nhận năng lượng của bạn. Thời gian hiện tại: 8:00 sáng.'
                                : 'Get a gentle daily nudge to pause and check in with your energy. Current time: 8:00 AM.')),
                    _Row(Icons.nightlight_round, s.profileEveningReflection, s.profileOff, AppColors.lavender2,
                        onTap: () => _showProfileSheet(context,
                            icon: Icons.nightlight_round,
                            color: AppColors.lavender2,
                            title: s.profileEveningReflection,
                            body: vi
                                ? 'Một lời mời nhẹ nhàng vào cuối ngày để khép lại và chiêm nghiệm những gì đã trải qua. (Hiện đang tắt.)'
                                : 'A soft end-of-day invitation to close and reflect on your day. (Currently off.)')),
                    _Row(Icons.menu_book_outlined, s.profileJournalPrompts, s.profileOn, AppColors.tealSoft,
                        onTap: () => _showProfileSheet(context,
                            icon: Icons.menu_book_outlined,
                            color: AppColors.teal,
                            title: s.profileJournalPrompts,
                            body: vi
                                ? 'Hiển thị các câu gợi ý khi bạn viết, giúp việc bắt đầu dễ dàng hơn. (Hiện đang bật.)'
                                : 'Show prompts while you write to make starting easier. (Currently on.)')),
                  ]),
                  const SizedBox(height: 16),

                  _section(s.profileAboutSection, [
                    _Row(Icons.info_outline, s.profileAboutMap, '', AppColors.lavender,
                        onTap: () => _showProfileSheet(context,
                            icon: Icons.info_outline,
                            color: AppColors.lavender,
                            title: s.profileAboutMap,
                            body: vi
                                ? 'Bản đồ Ý thức là thang đo do Tiến sĩ David Hawkins phát triển (trong cuốn "Power vs. Force"), mô tả mức năng lượng rung động của ý thức con người từ 20 đến 1000. Mốc 200 (Can đảm) là ranh giới giữa các trạng thái co lại và mở rộng. EnergyUp dùng thang đo này như một lăng kính tượng trưng để bạn quan sát đời sống nội tâm — không phải một phép đo khoa học.'
                                : 'The Map of Consciousness is a scale developed by Dr. David Hawkins (in "Power vs. Force") describing the vibrational energy of human consciousness from 20 to 1000. The 200 mark (Courage) is the boundary between contracting and expanding states. EnergyUp uses it as a symbolic lens for your inner life — not a scientific measurement.')),
                    _Row(Icons.favorite_border, s.profileAcknowledgements, '', AppColors.pinkLight,
                        onTap: () => _showProfileSheet(context,
                            icon: Icons.favorite_border,
                            color: AppColors.pink,
                            title: s.profileAcknowledgements,
                            body: vi
                                ? 'EnergyUp lấy cảm hứng từ công trình của Tiến sĩ David Hawkins. Được xây dựng bằng Flutter, với lòng biết ơn dành cho tất cả những ai đang chăm sóc đời sống nội tâm của mình. ♡'
                                : 'EnergyUp is inspired by the work of Dr. David Hawkins. Built with Flutter, with gratitude for everyone tending to their inner life. ♡')),
                    _Row(Icons.shield_outlined, s.profilePrivacy, '', AppColors.tealSoft,
                        onTap: () => _showProfileSheet(context,
                            icon: Icons.shield_outlined,
                            color: AppColors.teal,
                            title: s.profilePrivacy,
                            body: vi
                                ? 'Toàn bộ ghi nhận và chiêm nghiệm của bạn được lưu ngay trên thiết bị này. EnergyUp không gửi dữ liệu của bạn đến bất kỳ máy chủ nào.'
                                : 'All your check-ins and reflections are stored on this device. EnergyUp never sends your data to any server.')),
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
            color: AppColors.paper.withOpacity(0.85),
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
  final VoidCallback? onTap;
  const _Row(this.icon, this.label, this.detail, this.color, {this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
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
    ),
    );
  }
}

/// Bottom sheet showing details/info for a tapped profile row.
void _showProfileSheet(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String body,
  required Color color,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF4),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: color.withOpacity(0.18)),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF7A5A20).withOpacity(0.14),
              blurRadius: 24,
              offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: AppColors.muted3,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.16),
                  shape: BoxShape.circle,
                  border: Border.all(color: color.withOpacity(0.4), width: 1.4),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(title,
                    style: AppText.serif(size: 21, color: AppColors.text)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(body,
              style: AppText.sans(size: 15, color: AppColors.textSoft, height: 1.7)),
        ],
      ),
    ),
  );
}
