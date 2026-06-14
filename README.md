# Angel — Flutter app

Một ứng dụng wellness giúp **check-in** và **ghi lại năng lượng cảm xúc** theo
Bản đồ Ý thức (Map of Consciousness) trong sách *Power vs. Force* của
David R. Hawkins. Đây là bản port từ prototype Figma Make (React) sang **Flutter**.

## Tính năng

- **Onboarding** 3 bước: giới thiệu, tuyên bố miễn trách, thang năng lượng 20–1000
- **Today** — năng lượng hiện tại, hành trình trong ngày, năng lượng tổng hợp, gợi ý check-in theo buổi
- **Luồng check-in 3 bước** — chọn cảm xúc → lĩnh vực cuộc sống → đặt điểm + viết nhật ký → bài tập gợi ý theo cấp độ
- **Close the Day** — chiêm nghiệm cuối ngày
- **Energy** — biểu đồ xu hướng 7 ngày + thống kê tuần
- **Journal** — lịch sử chiêm nghiệm theo ngày
- **Journey** — thực hành 21 ngày, streak, mốc quan trọng
- **Profile** — đổi ngôn ngữ, cài đặt, tuyên bố miễn trách
- **Song ngữ Anh / Việt**, vòng tròn Aura đổi màu theo 18 cấp độ Hawkins
- **Lưu dữ liệu thật trên máy** bằng `shared_preferences` (check-in giữ lại sau khi tắt app)

## Cấu trúc thư mục

```
lib/
  main.dart                 # điểm vào, provider, chọn Onboarding/Home
  models/
    hawkins.dart            # 18 cấp độ Hawkins, cảm xúc, lĩnh vực
    check_in.dart           # model CheckIn + dữ liệu mẫu + hàm tiện ích
  i18n/strings.dart         # toàn bộ chuỗi song ngữ EN/VI
  state/app_state.dart      # ChangeNotifier + lưu shared_preferences
  theme/app_theme.dart      # màu sắc + font (Playfair Display, DM Sans)
  widgets/                  # AuraCircle, EnergySlider, EnergyChart, BottomNav...
  screens/                  # các màn hình + luồng check-in
```

---

## Cài đặt Flutter (Windows) — làm 1 lần

1. **Tải Flutter SDK**: vào <https://docs.flutter.dev/get-started/install/windows>
   tải file `.zip` bản stable.
2. **Giải nén** vào ví dụ `C:\src\flutter` (tránh thư mục có dấu cách hoặc cần quyền admin như `C:\Program Files`).
3. **Thêm vào PATH**: mở *Edit environment variables* → thêm `C:\src\flutter\bin` vào biến `Path`.
4. Mở **PowerShell mới** và kiểm tra:
   ```powershell
   flutter --version
   flutter doctor
   ```
   `flutter doctor` sẽ chỉ ra phần còn thiếu. Để chạy trên Android cần cài
   **Android Studio** (kèm Android SDK); hoặc bật **Windows desktop** để chạy ngay
   trên máy tính mà không cần điện thoại:
   ```powershell
   flutter config --enable-windows-desktop
   ```

## Chạy app

Trong thư mục `angel_flutter`:

```powershell
# Tạo phần khung nền tảng (android / windows) — KHÔNG ghi đè thư mục lib
flutter create --platforms=android,windows .

# Tải các thư viện (provider, shared_preferences, google_fonts)
flutter pub get

# Chạy thử — chọn thiết bị khi được hỏi
flutter run
```

- Chạy trên **Windows desktop**: `flutter run -d windows`
- Chạy trên **điện thoại Android** (đã bật USB debugging): cắm máy rồi `flutter run`
- Tạo file cài đặt APK:
  ```powershell
  flutter build apk --release
  ```
  File nằm ở `build\app\outputs\flutter-apk\app-release.apk`.

> Lưu ý: lần chạy đầu cần mạng để `google_fonts` tải font Playfair Display & DM Sans
> (sau đó được lưu cache). Nếu muốn dùng offline hoàn toàn, có thể nhúng sẵn file
> font vào thư mục `assets/`.

## Tuyên bố miễn trách

Angel là công cụ tự chiêm nghiệm và viết nhật ký, **không phải** công cụ y tế hay
chẩn đoán. Điểm năng lượng chỉ mang tính biểu tượng cho trạng thái nội tâm.
