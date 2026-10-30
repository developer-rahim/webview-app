# webview-app

A webview container with native platform integrations.

## Highlights

- In-app browser built on `webview_flutter`, with `webview_flutter_wkwebview` for iOS.
- Loading placeholders using `shimmer` instead of a blank screen.
- External links open in the system browser via `url_launcher`.
- Custom splash screen and launcher icon setup included.

## Tech Stack

| Concern | Choice |
|---|---|
| UI | Flutter, Material |
| Webview | `webview_flutter`, `webview_flutter_wkwebview` |
| UX | `shimmer` |
| Platform | `flutter_native_splash`, `flutter_launcher_icons` |

## Project Structure

```
lib/
- `main.dart`
```

## Getting Started

### Prerequisites

- Flutter `>= 3.16` (Dart `>= 3.2`)

### Run

```bash
git clone https://github.com/developer-rahim/webview-app.git
cd webview-app
flutter pub get
flutter run
```

### Test

```bash
flutter test
flutter analyze
```

## Notes

A single-screen project — the webview and its configuration live in `main.dart`.

## License

Released under the MIT License.
