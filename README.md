# 🎨 ArtVerse

**ArtVerse** is a premium, state-of-the-art creative ecosystem designed for digital artists and animators. Built with Flutter and powered by Supabase, it provides a seamless bridge between a powerful professional drawing studio and a vibrant social community.

![ArtVerse Hero Banner](assets/images/branding/hero_banner_bg.png)

## 🚀 Key Features

### 🖌️ Professional Art Studio
- **Advanced Canvas Engine**: High-performance drawing with support for pressure sensitivity and tilt.
- **Layer System**: Comprehensive layer management (Lock, Hide, Reorder, Opacity).
- **Animation Suite**: Frame-by-frame animation tools with Onion Skinning and timeline management.
- **Dynamic Brushes**: Customizable brush engine with scatter, hardness, and opacity controls.
- **HLS Export**: Seamless video export using FFmpeg, optimized for high-quality streaming.

### 👥 Creative Community
- **Global Feed**: Discover stunning 2D artwork and animations from creators worldwide.
- **Challenges**: Participate in themed art contests to win exclusive badges and XP.
- **Real-time Interaction**: Follow artists, like posts, and receive instant notifications.
- **Rich Profiles**: Showcase your portfolio, specialties, and achievements with a modern glassmorphic dashboard.

### 💎 Marketplace & Gamification
- **Digital Gear**: Customize your presence with exclusive avatar frames and profile themes.
- **XP & Leveling**: Earn experience points for creative activity and climb the leaderboard.
- **Badges**: Collect unique achievements for milestone artistic accomplishments.

## 🛠️ Technology Stack

- **Frontend**: [Flutter](https://flutter.dev) (Dart)
- **State Management**: [GetX](https://pub.dev/packages/get)
- **Backend & Auth**: [Supabase](https://supabase.com)
- **Local Storage**: [Hive](https://pub.dev/packages/hive)
- **Media Processing**: [FFmpeg Kit](https://pub.dev/packages/ffmpeg_kit_flutter)
- **Networking**: [Connectivity Plus](https://pub.dev/packages/connectivity_plus), [Cached Network Image](https://pub.dev/packages/cached_network_image)
- **UI Components**: Google Fonts, Material Design Icons, Glassmorphism UI.

## 📦 Getting Started

### Prerequisites
- Flutter SDK (Latest Stable)
- Android Studio / VS Code
- Supabase Account

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/phuocem/ArtVerse.git
   cd ArtVerse
   ```

2. **Setup Environment Variables**:
   Create a `.env` file in the root directory and add your Supabase credentials:
   ```env
   SUPABASE_URL=your_supabase_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   ```

3. **Install dependencies**:
   ```bash
   flutter pub get
   ```

4. **Run the app**:
   ```bash
   flutter run
   ```

## 📂 Project Structure

```
lib/
├── app/
│   ├── core/           # Theme, Bindings, Translations
│   ├── data/           # Models, Services, Providers
│   ├── modules/        # Features (Draw, Profile, Community, etc.)
│   └── routes/         # App Navigation logic
├── main.dart           # Entry point
```

## 📜 License

Distributed under the MIT License. See `LICENSE` for more information.

---
Developed with ❤️ by the **Phước Em**.
