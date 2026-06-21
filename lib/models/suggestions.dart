import '../i18n/strings.dart';

/// A short, actionable suggestion for each Hawkins level — what to do to gently
/// *raise* energy when below courage (200), or to *sustain & deepen* it when at
/// or above it. Keyed by the level's English [name].
class LevelSuggestion {
  final String vi;
  final String en;
  const LevelSuggestion(this.vi, this.en);
}

const Map<String, LevelSuggestion> levelSuggestions = {
  'Shame': LevelSuggestion(
    'Đặt một tay lên ngực và thì thầm "Tôi xứng đáng được dịu dàng." Bạn không phải là lỗi lầm của mình.',
    'Place a hand on your heart and whisper "I deserve gentleness." You are not your mistakes.',
  ),
  'Guilt': LevelSuggestion(
    'Viết ra điều khiến bạn áy náy cùng một bài học rút ra, rồi tự cho phép mình buông nó xuống.',
    'Write down what weighs on you and one lesson learned, then allow yourself to set it down.',
  ),
  'Apathy': LevelSuggestion(
    'Làm một việc nhỏ tử tế cho cơ thể: uống một cốc nước, ra nắng vài phút. Bắt đầu thật nhỏ.',
    'Do one small kindness for your body: a glass of water, a few minutes in the sun. Start tiny.',
  ),
  'Grief': LevelSuggestion(
    'Cho phép cảm xúc được hiện diện. Gọi tên điều bạn mất và nói "Nó từng thật sự quan trọng với tôi."',
    'Let the feeling be here. Name what you lost and say "It truly mattered to me."',
  ),
  'Fear': LevelSuggestion(
    'Thở 4-7-8 vài nhịp, rồi tự hỏi: "Điều gì thật sự đang nằm trong tầm kiểm soát của tôi lúc này?"',
    'Breathe 4-7-8 a few times, then ask: "What is actually within my control right now?"',
  ),
  'Desire': LevelSuggestion(
    'Nhận ra mong cầu mà chưa vội hành động. Nhu cầu sâu xa nào đang ẩn bên dưới nó?',
    'Notice the craving without acting on it. What deeper need lies beneath it?',
  ),
  'Anger': LevelSuggestion(
    'Vận động vài phút để giải phóng năng lượng, rồi viết ra một việc bạn thật sự có thể kiểm soát.',
    'Move for a few minutes to release the energy, then write one thing you can genuinely control.',
  ),
  'Pride': LevelSuggestion(
    'Ghi lại ba điều bạn thật lòng trân trọng ở người khác hôm nay, và giữ tâm thế sẵn sàng học hỏi.',
    'Note three things you genuinely admire in others today, and stay open to learning.',
  ),
  'Courage': LevelSuggestion(
    'Bạn đã ở ngưỡng tích cực. Đứng thẳng, hít thở sâu và nói "Tôi đủ sức đối diện với hôm nay."',
    "You're at the positive threshold. Stand tall, breathe deeply, and say \"I can face today.\"",
  ),
  'Neutrality': LevelSuggestion(
    'Buông bớt kỳ vọng cứng nhắc. Đón nhận mọi việc như nó là — linh hoạt, nhẹ nhàng và tin tưởng.',
    'Loosen rigid expectations. Meet things as they are — flexible, easeful and trusting.',
  ),
  'Willingness': LevelSuggestion(
    'Đặt một ý định cho hôm nay — không phải việc cần làm, mà là cách bạn muốn hiện diện.',
    'Set one intention for today — not a task, but a way you want to show up.',
  ),
  'Acceptance': LevelSuggestion(
    'Viết 10 điều bạn biết ơn ngay lúc này, dừng lại một nhịp để thật sự cảm nhận từng điều.',
    'Write 10 things you are grateful for right now, pausing to truly feel each one.',
  ),
  'Reason': LevelSuggestion(
    'Hỏi một câu sâu sắc và viết tự do 10 phút: "Sự thật sâu xa bên dưới điều tôi đang trải qua là gì?"',
    'Ask a meaningful question and free-write for 10 minutes: "What is the deeper truth here?"',
  ),
  'Love': LevelSuggestion(
    'Hướng sự chú ý vào vùng tim, gợi lại một khoảnh khắc yêu thương sâu sắc và để nó lan toả.',
    'Bring attention to your heart, recall a moment of deep love and let it radiate outward.',
  ),
  'Joy': LevelSuggestion(
    'Nhớ lại một niềm vui không nguyên cớ. Cảm nhận nó trong cơ thể và để nó lan rộng.',
    'Recall a moment of uncaused joy. Feel where it lives in your body and let it expand.',
  ),
  'Peace': LevelSuggestion(
    'Ngồi yên 10 phút. Để suy nghĩ trôi qua như mây — bạn là bầu trời, không phải thời tiết.',
    'Sit quietly for 10 minutes. Let thoughts drift like clouds — you are the sky, not the weather.',
  ),
  'Enlightenment': LevelSuggestion(
    'An trú trong nhận biết rộng mở. Chỉ cần nhận ra chính sự nhận biết đang hiện diện.',
    'Rest in open awareness. Simply notice the awareness in which all experience arises.',
  ),
  'Pure Consciousness': LevelSuggestion(
    'Không cần kỹ thuật nào. Chỉ đơn giản là hiện hữu.',
    'No technique needed. Simply be.',
  ),
};

/// Returns the localized suggestion text for [levelName], or empty string.
String suggestionFor(String levelName, Lang lang) {
  final sug = levelSuggestions[levelName];
  if (sug == null) return '';
  return lang == Lang.vi ? sug.vi : sug.en;
}
