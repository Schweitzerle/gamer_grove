// ==========================================

// lib/domain/entities/recommendations/game_mood.dart
enum GameMood {
  actionPacked('action_packed', 'Action-Packed', 'High-energy, fast-paced games'),
  relaxing('relaxing', 'Relaxing', 'Calm, peaceful, meditative games'),
  storyRich('story_rich', 'Story-Rich', 'Narrative-focused, cinematic games'),
  challenging('challenging', 'Challenging', 'Difficult, skill-testing games'),
  social('social', 'Social', 'Multiplayer, party, co-op games'),
  creative('creative', 'Creative', 'Building, crafting, sandbox games'),
  nostalgic('nostalgic', 'Nostalgic', 'Retro, classic, vintage-style games'),
  innovative('innovative', 'Innovative', 'Unique, experimental, groundbreaking games'),
  competitive('competitive', 'Competitive', 'Esports, ranked, PvP games'),
  atmospheric('atmospheric', 'Atmospheric', 'Immersive, mood-setting games');

  const GameMood(this.value, this.displayName, this.description);
  final String value;
  final String displayName;
  final String description;
}

