# Albania Speaking Companion

Ứng dụng Flutter theo giao diện tham chiếu: đỏ Albania, nền sáng/tối, đường viền vàng, thanh điều hướng 5 tab.

## Chạy app

Yêu cầu Flutter 3.38+ / Dart 3.10+, Xcode cho iOS hoặc Android SDK cho Android. Dự án được kiểm tra bằng Flutter 3.47.2.

```sh
flutter pub get
flutter run
```

Mở `ios/Runner.xcworkspace` bằng Xcode nếu cần chạy trên iPhone thật. Chọn Development Team và Bundle ID của bạn khi ký app.

```sh
flutter run -d chrome
flutter build apk --debug
flutter build ios --simulator --debug
flutter analyze
flutter test
```

## Tính năng

- 99 câu tiếng Albania, 9 chủ đề, mỗi chủ đề 11 câu.
- 30 từ vựng bổ sung; tìm kiếm tiếng Anh/Albania có hỗ trợ bỏ dấu ë/ç.
- 129 file MP3 đóng gói sẵn, không cần mạng hoặc tải giọng đọc khi dùng bản iOS/Android.
- 3 kiểu quiz: nghĩa của câu, phiên âm, nghe hiểu. 10 câu/lượt; chấm điểm, khóa đáp án sau khi chọn, thực hành lại.
- Lưu riêng câu, từ và chủ đề yêu thích.
- Đánh dấu đã học, chuỗi ngày học, điểm quiz tốt nhất, tiến độ theo chủ đề.
- Theme System/Light/Dark, cỡ chữ, tốc độ 0.5–1.5×, tự phát khi mở câu.
- Nhắc học lúc 19:00 theo múi giờ thiết bị trên iOS/Android; xin quyền khi người dùng bật tính năng. Android dùng lịch không chính xác tuyệt đối để không cần quyền báo thức đặc biệt; hệ điều hành có thể trì hoãn thông báo.
- Không tài khoản, quảng cáo, analytics hoặc máy chủ. Dữ liệu lưu tại thiết bị.
- Nút xóa tiến độ có hộp thoại xác nhận và giữ lại yêu thích/cài đặt.

## Cấu trúc

- `lib/main.dart`: khởi động, theme và điều hướng chính.
- `lib/screens.dart`: trang chủ, chủ đề, chi tiết câu, yêu thích, cài đặt, tiến độ.
- `lib/quiz.dart`: sinh câu hỏi và luồng làm quiz.
- `lib/store.dart`: lưu trạng thái, tính chuỗi ngày học.
- `lib/services.dart`: phát âm thanh và nhắc học cục bộ.
- `assets/data/content.json`: toàn bộ nội dung học, có thể biên tập.
- `assets/audio/`: 129 đoạn đọc tương ứng với ID nội dung.
- `test/widget_test.dart`: kiểm thử dữ liệu, lưu trạng thái, chuỗi ngày học, quiz, tương tác và màn hình nhỏ.

## Nội dung và tài nguyên

Tên, mô tả, màu sắc và icon theo yêu cầu. Icon gốc được lấy từ URL Apple CDN do người dùng cung cấp; icon launcher iOS/Android/Web được tạo từ ảnh này.

Nội dung câu, bản dịch và hướng dẫn phát âm được biên soạn cho bản triển khai này, không trích xuất từ ứng dụng gốc. Phiên âm là cách đọc gần đúng cho người nói tiếng Anh; có câu dùng dạng nam (ví dụ “Jam i humbur”). Trước khi phát hành sản phẩm học ngôn ngữ, nên cho người bản ngữ biên tập.

Âm thanh là giọng tổng hợp tiếng Albania, được tạo qua Google Translate TTS khi dựng bản mẫu và lưu thành MP3. Việc chạy app không gọi dịch vụ này. Trước khi phát hành thương mại, xác nhận quyền sử dụng icon và âm thanh hoặc thay bằng tài nguyên có giấy phép/thu âm riêng. Không có bản ghi giọng người dùng.

## Phạm vi build

Bản iOS Simulator dùng để thử trên máy Mac, không phải IPA đã ký để cài iPhone thật. Bản web là bản xem trước Flutter; nhắc học cục bộ chỉ bật trên iOS/Android. Cam kết offline áp dụng cho bản native đã cài đặt, không phải lần tải đầu của web.

Cấu hình Android release hiện dùng khóa debug từ mẫu Flutter; thay bằng keystore phát hành trước khi đưa lên Google Play. Dự án chưa được gửi lên App Store/Google Play.

## Kết quả kiểm tra

- `flutter analyze`: không có lỗi/cảnh báo phân tích.
- `flutter test`: đạt 7/7 bài kiểm thử.
- Build thành công iOS Simulator Debug, Android Debug APK và Web Release.
- Đã chạy app trên iPhone 16 Plus Simulator, kiểm tra màn hình chính, phát âm thanh và chuyển sang Dark theme.
- Đã mở bản web, kiểm tra giao diện sáng, nút nghe và kích thước 430×932.
- Kiểm tra 129/129 MP3 đều giải mã được và có thời lượng hợp lệ; thông báo nhắc học chưa kiểm tra việc nhận vào 19:00 thực tế.
