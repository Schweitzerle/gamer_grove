# Gamer Grove

<div align="center">
  <img src="assets/icon/app_icon.png" alt="Gamer Grove Logo" width="200"/>

**Discover, rate, and recommend video games**

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

</div>

## Overview

Gamer Grove is a comprehensive gaming social platform built with Flutter that allows users to discover, rate, and share their favorite video games. Connect with fellow gamers, track your gaming journey, and explore an extensive database of games powered by the IGDB API.

## Features

### Game Management

- **Extensive Game Database**: Browse thousands of games with detailed information from IGDB
- **Personal Collections**: Rate games, create wishlists, and recommend titles to friends
- **Top Three Games**: Showcase your favorite games on your profile
- **Game Details**: View comprehensive information including trailers, screenshots, release dates, platforms, and more

### Social Features

- **User Profiles**: Customize your gaming profile with avatars and personal information
- **Follow System**: Connect with other gamers and see their gaming activity
- **Activity Feed**: Stay updated with your friends' latest ratings and recommendations
- **Leaderboard**: See top-rated games and most active community members
- **User Discovery**: Search and explore other gamers' profiles and collections

### Discover & Explore

- **Search**: Find games, users, and gaming events
- **Game Details**: Explore characters, companies, platforms, game engines, and more
- **Events**: Stay informed about gaming events and releases
- **Rich Media**: View game trailers, screenshots, and artwork in full-screen galleries
- **Smart Recommendations**: Get personalized game suggestions based on your preferences

### User Experience

- **Modern UI**: Beautiful, responsive design with dark/light theme support
- **Performance Optimized**: Smooth scrolling, image caching, and efficient data loading
- **Offline Support**: Access cached data when offline
- **Toast Notifications**: Clear, non-intrusive feedback for user actions
- **Image Galleries**: Full-screen image viewer with zoom capabilities

## Architecture

Gamer Grove follows **Clean Architecture** principles with clear separation of concerns:

```
lib/
├── core/                 # Core utilities, constants, and widgets
│   ├── constants/       # App-wide constants
│   ├── errors/          # Error handling
│   ├── services/        # Core services
│   ├── utils/           # Utility functions
│   └── widgets/         # Reusable widgets
├── data/                # Data layer
│   ├── models/          # Data models
│   ├── repositories/    # Repository implementations
│   └── datasources/     # Remote and local data sources
├── domain/              # Business logic layer
│   ├── entities/        # Business entities
│   ├── repositories/    # Repository interfaces
│   └── usecases/        # Business use cases
└── presentation/        # Presentation layer
    ├── blocs/           # BLoC state management
    ├── pages/           # App screens
    └── widgets/         # UI components
```

## Tech Stack

### Core

- **Flutter 3.0+**: Cross-platform mobile framework
- **Dart 3.0+**: Programming language
- **Clean Architecture**: Separation of concerns and testability

### State Management

- **flutter_bloc**: BLoC pattern implementation
- **rxdart**: Reactive programming

### Backend & API

- **Supabase**: Backend as a Service (authentication, database, storage)
- **IGDB API**: Video game database via Twitch
- **Dio**: HTTP client for API requests

### UI & Design

- **flex_color_scheme**: Advanced theming
- **cached_network_image**: Efficient image loading and caching
- **shimmer**: Loading animations
- **flutter_staggered_grid_view**: Advanced grid layouts
- **youtube_player_flutter**: Video playback
- **font_awesome_flutter**: Icon library
- **toasty_box**: Toast notifications

### Utilities

- **get_it**: Dependency injection
- **shared_preferences**: Local storage
- **flutter_secure_storage**: Secure credential storage
- **connectivity_plus**: Network status monitoring
- **image_picker**: Image selection from gallery/camera
- **permission_handler**: Runtime permissions

## Getting Started

### Prerequisites

- Flutter SDK (3.0 or higher)
- Dart SDK (3.0 or higher)
- Android Studio / VS Code with Flutter extensions
- An active internet connection for API access

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/Schweitzerle/gamer_grove.git
   cd gamer_grove
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Configure environment variables**

   Create a `.env` file in the project root:

   ```env
   SUPABASE_URL=your_supabase_project_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   IGDB_CLIENT_ID=your_twitch_client_id
   IGDB_CLIENT_SECRET=your_twitch_client_secret
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Setup Services

#### Supabase Setup

1. Create a project at [supabase.com](https://supabase.com)
2. Run the SQL scripts in `/SupabaseScripts` to set up the database schema
3. Configure authentication providers as needed
4. Add your Supabase URL and anon key to `.env`

#### IGDB API Setup

1. Create a Twitch developer account at [dev.twitch.tv](https://dev.twitch.tv)
2. Register your application to get Client ID and Client Secret
3. Add credentials to `.env`

## Project Structure

### Key Pages

- **Home**: Main feed with game discovery and activity
- **Search**: Find games, users, and events
- **Profile**: User profile with collections and statistics
- **Game Detail**: Comprehensive game information
- **Grove**: Community features and leaderboards
- **Settings**: App configuration and account management

### State Management

All features use the BLoC pattern with clear separation between:

- **Events**: User actions
- **States**: UI states (loading, loaded, error)
- **BLoCs**: Business logic controllers

## Development

### Code Generation

```bash
# Generate code for freezed, json_serializable, etc.
flutter pub run build_runner build --delete-conflicting-outputs
```

### Run Tests

```bash
flutter test
```

### Analyze Code

```bash
flutter analyze
```

### Generate App Icons

```bash
flutter pub run flutter_launcher_icons
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- [IGDB](https://www.igdb.com/) for providing the comprehensive game database
- [Supabase](https://supabase.com/) for backend infrastructure
- [Flutter](https://flutter.dev/) team for the amazing framework
- All contributors and testers

## Contact

Project Link: [https://github.com/Schweitzerle/gamer_grove](https://github.com/Schweitzerle/gamer_grove)

---

<div align="center">
  Made with ❤️ by the Gamer Grove team
</div>
