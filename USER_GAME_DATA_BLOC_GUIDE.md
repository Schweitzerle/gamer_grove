# UserGameDataBloc - Global State Management Guide

## Übersicht

Der `UserGameDataBloc` ist ein **globaler Singleton-BLoC**, der als **Single Source of Truth** für alle User-Game-Beziehungen dient:

- ✅ Wishlist Status
- ✅ Recommendations
- ✅ Game Ratings (0-10)
- ✅ Top Three Games

### Problem gelöst

**Vorher:** Wenn du im GameDetailScreen ein Game zur Wishlist hinzugefügt hast, wurde das Wishlist-Symbol auf der GameCard im HomeScreen nicht automatisch aktualisiert.

**Jetzt:** Der UserGameDataBloc synchronisiert automatisch alle UI-Komponenten app-weit!

---

## Architektur

```
┌─────────────────────────────────────────────────────┐
│                     main.dart                        │
│  ┌───────────────────────────────────────────────┐  │
│  │  BlocProvider.value(UserGameDataBloc)         │  │
│  │  - Singleton über gesamte App                 │  │
│  │  - Lädt Daten bei Login automatisch           │  │
│  │  - Cleared Daten bei Logout                   │  │
│  └───────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────┘
                          │
          ┌───────────────┼───────────────┐
          │               │               │
    ┌─────▼─────┐   ┌────▼─────┐   ┌────▼──────┐
    │ GameCard  │   │  Detail  │   │   Home    │
    │  Widget   │   │  Screen  │   │  Screen   │
    └───────────┘   └──────────┘   └───────────┘
         │               │               │
         └───────────────┼───────────────┘
                         │
              Alle hören auf denselben State!
```

---

## Verwendung

### 1. Daten abrufen (Read)

```dart
// In jedem Widget mit context.watch oder context.read
final userGameDataState = context.watch<UserGameDataBloc>().state;

if (userGameDataState is UserGameDataLoaded) {
  // Check if game is wishlisted
  final isWishlisted = userGameDataState.isWishlisted(gameId);

  // Check if game is recommended
  final isRecommended = userGameDataState.isRecommended(gameId);

  // Get rating (null if not rated)
  final rating = userGameDataState.getRating(gameId);

  // Check if in top three
  final isInTopThree = userGameDataState.isInTopThree(gameId);

  // Get top three position (1-3, or null)
  final position = userGameDataState.getTopThreePosition(gameId);
}
```

### 2. Daten ändern (Write)

```dart
// Toggle Wishlist
context.read<UserGameDataBloc>().add(
  ToggleWishlistEvent(
    userId: currentUserId,
    gameId: gameId,
  ),
);

// Toggle Recommendation
context.read<UserGameDataBloc>().add(
  ToggleRecommendationEvent(
    userId: currentUserId,
    gameId: gameId,
  ),
);

// Rate Game
context.read<UserGameDataBloc>().add(
  RateGameEvent(
    userId: currentUserId,
    gameId: gameId,
    rating: 8.5, // 0-10
  ),
);

// Remove Rating
context.read<UserGameDataBloc>().add(
  RemoveRatingEvent(
    userId: currentUserId,
    gameId: gameId,
  ),
);

// Update Top Three
context.read<UserGameDataBloc>().add(
  UpdateTopThreeEvent(
    userId: currentUserId,
    gameIds: [gameId1, gameId2, gameId3],
  ),
);
```

---

## Beispiel: GameCard aktualisieren

### Vorher (Alte Implementierung)

```dart
class GameCard extends StatelessWidget {
  final Game game; // Game enthält isWishlisted, userRating, etc.

  @override
  Widget build(BuildContext context) {
    // Problem: Game-Daten sind statisch, aktualisieren sich nicht
    return Card(
      child: Column(
        children: [
          if (game.isWishlisted) Icon(Icons.favorite),
          if (game.userRating != null) Text('${game.userRating}'),
        ],
      ),
    );
  }
}
```

### Nachher (Mit UserGameDataBloc)

```dart
class GameCard extends StatelessWidget {
  final Game game;

  @override
  Widget build(BuildContext context) {
    // Listen to global user game data
    return BlocBuilder<UserGameDataBloc, UserGameDataState>(
      builder: (context, userDataState) {
        // Extract data from global state
        bool isWishlisted = false;
        double? userRating;
        bool isInTopThree = false;
        int? topThreePosition;

        if (userDataState is UserGameDataLoaded) {
          isWishlisted = userDataState.isWishlisted(game.id);
          userRating = userDataState.getRating(game.id);
          isInTopThree = userDataState.isInTopThree(game.id);
          topThreePosition = userDataState.getTopThreePosition(game.id);
        }

        return Card(
          child: Column(
            children: [
              // Wishlist Icon - updates automatically!
              if (isWishlisted)
                Icon(Icons.favorite, color: Colors.red),

              // User Rating - updates automatically!
              if (userRating != null)
                Text('${userRating.toStringAsFixed(1)}'),

              // Top Three Badge - updates automatically!
              if (isInTopThree && topThreePosition != null)
                Badge(
                  label: Text('#$topThreePosition'),
                  child: Icon(Icons.emoji_events),
                ),
            ],
          ),
        );
      },
    );
  }
}
```

---

## Beispiel: GameDetailPage aktualisieren

```dart
class GameDetailPage extends StatelessWidget {
  final int gameId;
  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserGameDataBloc, UserGameDataState>(
      builder: (context, userDataState) {
        bool isWishlisted = false;

        if (userDataState is UserGameDataLoaded) {
          isWishlisted = userDataState.isWishlisted(gameId);
        }

        return Scaffold(
          appBar: AppBar(
            actions: [
              // Wishlist Button
              IconButton(
                icon: Icon(
                  isWishlisted ? Icons.favorite : Icons.favorite_border,
                  color: isWishlisted ? Colors.red : null,
                ),
                onPressed: () {
                  // Toggle wishlist
                  context.read<UserGameDataBloc>().add(
                    ToggleWishlistEvent(
                      userId: currentUserId,
                      gameId: gameId,
                    ),
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
              // Game details...
            ],
          ),
        );
      },
    );
  }
}
```

---

## Features

### 1. Optimistic Updates
Der Bloc aktualisiert den UI-State **sofort** und synchronisiert mit dem Backend im Hintergrund:

```dart
// UI aktualisiert sich SOFORT
context.read<UserGameDataBloc>().add(ToggleWishlistEvent(...));

// Backend-Call läuft im Hintergrund
// Bei Fehler: State wird automatisch zurückgesetzt
```

### 2. Automatische Synchronisation

Alle Widgets, die `context.watch<UserGameDataBloc>()` verwenden, werden **automatisch neu gerendert**, wenn sich der State ändert.

### 3. Lifecycle Management

```dart
// Bei Login: Daten werden automatisch geladen
AuthAuthenticated -> LoadUserGameDataEvent

// Bei Logout: Daten werden automatisch gelöscht
AuthUnauthenticated -> ClearUserGameDataEvent
```

---

## State Arten

| State | Beschreibung |
|-------|-------------|
| `UserGameDataInitial` | Initial state (vor Login) |
| `UserGameDataLoading` | Daten werden geladen |
| `UserGameDataLoaded` | Daten geladen und verfügbar |
| `WishlistToggled` | Wishlist wurde getoggelt (extends UserGameDataLoaded) |
| `GameRated` | Game wurde bewertet (extends UserGameDataLoaded) |
| `UserGameDataError` | Fehler beim Laden/Speichern |

---

## Best Practices

### ✅ DO

```dart
// Use context.watch for UI updates
final state = context.watch<UserGameDataBloc>().state;

// Use context.read for events
context.read<UserGameDataBloc>().add(event);

// Check state type before accessing data
if (state is UserGameDataLoaded) {
  final isWishlisted = state.isWishlisted(gameId);
}
```

### ❌ DON'T

```dart
// DON'T store User-Game data in Game entity
// Game entity should only contain IGDB data
class Game {
  final int id;
  final String name;
  // ❌ bool isWishlisted; // Don't do this!
}

// DON'T create multiple instances of UserGameDataBloc
// It's a singleton!

// DON'T forget to check state type
final state = context.watch<UserGameDataBloc>().state;
final isWishlisted = state.isWishlisted(gameId); // ❌ Might crash!
```

---

## Debugging

```dart
// Enable logging in UserGameDataBloc
class UserGameDataBloc extends Bloc<UserGameDataEvent, UserGameDataState> {
  @override
  void onTransition(Transition<UserGameDataEvent, UserGameDataState> transition) {
    print('🔄 UserGameData Transition:');
    print('  Event: ${transition.event}');
    print('  Current: ${transition.currentState}');
    print('  Next: ${transition.nextState}');
    super.onTransition(transition);
  }
}
```

---

## Vorteile

1. **Single Source of Truth**: Nur eine Stelle für User-Game-Daten
2. **Automatische Synchronisation**: Alle UI-Komponenten bleiben synchron
3. **Optimistic Updates**: Sofortiges UI-Feedback
4. **Clean Architecture**: Trennung von IGDB-Daten und User-Daten
5. **Performance**: Singleton verhindert unnötige Datenladungen
6. **Einfache Wartung**: Zentrale Verwaltung aller User-Game-Logik

---

## Migration Guide

### Schritt 1: Game Entity bereinigen

Entferne alle User-bezogenen Felder aus der `Game` Entity:

```dart
class Game {
  final int id;
  final String name;
  // Remove these:
  // final bool isWishlisted;
  // final double? userRating;
  // final bool isRecommended;
  // final bool isInTopThree;
}
```

### Schritt 2: Widgets aktualisieren

Ersetze alle Stellen, wo du `game.isWishlisted` verwendest, durch:

```dart
final userDataState = context.watch<UserGameDataBloc>().state;
final isWishlisted = userDataState is UserGameDataLoaded
    ? userDataState.isWishlisted(game.id)
    : false;
```

### Schritt 3: Actions aktualisieren

Ersetze direkte Repository-Calls durch Bloc-Events:

```dart
// Vorher:
await userRepository.toggleWishlist(userId, gameId);

// Nachher:
context.read<UserGameDataBloc>().add(
  ToggleWishlistEvent(userId: userId, gameId: gameId),
);
```

---

## Zusammenfassung

Der `UserGameDataBloc` löst das Problem der State-Synchronisation zwischen verschiedenen Screens. Anstatt dass jeder Screen seine eigenen User-Daten verwaltet, gibt es jetzt **eine zentrale Stelle**, die alle Screens automatisch aktualisiert.

**Das Ergebnis:** Wenn du im GameDetailScreen ein Game zur Wishlist hinzufügst, aktualisiert sich das Wishlist-Symbol auf der GameCard im HomeScreen automatisch - ohne manuellen Refresh! 🎮✨
