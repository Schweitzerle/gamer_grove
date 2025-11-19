// lib/domain/entities/search/character_search_filters.dart
import 'package:equatable/equatable.dart';
import '../character/character_gender.dart';
import '../character/character_species.dart';

enum CharacterSortBy {
  relevance,
  name,
  gamesCount,
}

enum CharacterSortOrder {
  ascending,
  descending,
}

class CharacterSearchFilters extends Equatable {
  // ============================================================
  // GENDER FILTER
  // ============================================================
  final CharacterGenderEnum? gender;

  // ============================================================
  // SPECIES FILTER
  // ============================================================
  final CharacterSpeciesEnum? species;

  // ============================================================
  // EXISTENCE FILTERS
  // ============================================================
  final bool? hasMugShot;
  final bool? hasDescription;
  final bool? hasGames;

  // ============================================================
  // SORTING
  // ============================================================
  final CharacterSortBy sortBy;
  final CharacterSortOrder sortOrder;

  const CharacterSearchFilters({
    // Gender Filter
    this.gender,

    // Species Filter
    this.species,

    // Existence Filters
    this.hasMugShot,
    this.hasDescription,
    this.hasGames,

    // Sorting
    this.sortBy = CharacterSortBy.relevance,
    this.sortOrder = CharacterSortOrder.descending,
  });

  bool get hasFilters =>
      gender != null ||
      species != null ||
      hasMugShot == true ||
      hasDescription == true ||
      hasGames == true ||
      sortBy != CharacterSortBy.relevance;

  bool get hasGenderFilter => gender != null;

  bool get hasSpeciesFilter => species != null;

  bool get hasExistenceFilters =>
      hasMugShot == true || hasDescription == true || hasGames == true;

  CharacterSearchFilters copyWith({
    CharacterGenderEnum? gender,
    CharacterSpeciesEnum? species,
    bool? hasMugShot,
    bool? hasDescription,
    bool? hasGames,
    CharacterSortBy? sortBy,
    CharacterSortOrder? sortOrder,
    bool clearGender = false,
    bool clearSpecies = false,
  }) {
    return CharacterSearchFilters(
      gender: clearGender ? null : (gender ?? this.gender),
      species: clearSpecies ? null : (species ?? this.species),
      hasMugShot: hasMugShot ?? this.hasMugShot,
      hasDescription: hasDescription ?? this.hasDescription,
      hasGames: hasGames ?? this.hasGames,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  CharacterSearchFilters clearFilters() {
    return const CharacterSearchFilters();
  }

  @override
  List<Object?> get props => [
        gender,
        species,
        hasMugShot,
        hasDescription,
        hasGames,
        sortBy,
        sortOrder,
      ];
}
