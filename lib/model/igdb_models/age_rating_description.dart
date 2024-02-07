class AgeRatingDescription {
  int id;
  AgeRatingContentDescriptionCategory? category;
  String? checksum;
  String? description;

  AgeRatingDescription({
    required this.id,
    this.category,
    this.checksum,
    this.description,
  });

  factory AgeRatingDescription.fromJson(Map<String, dynamic> json) {
    return AgeRatingDescription(
      category: json['category'] != null
          ? AgeRatingContentDescriptionCategoryExtension.fromValue(json['category'])
          : null,
      checksum: json['checksum'],
      description: json['description'], id: json['id'],
    );
  }

}

enum AgeRatingContentDescriptionCategory {
  ESRB_alcohol_reference,
  ESRB_animated_blood,
  ESRB_blood,
  ESRB_blood_and_gore,
  ESRB_cartoon_violence,
  ESRB_comic_mischief,
  ESRB_crude_humor,
  ESRB_drug_reference,
  ESRB_fantasy_violence,
  ESRB_intense_violence,
  ESRB_language,
  ESRB_lyrics,
  ESRB_mature_humor,
  ESRB_nudity,
  ESRB_partial_nudity,
  ESRB_real_gambling,
  ESRB_sexual_content,
  ESRB_sexual_themes,
  ESRB_sexual_violence,
  ESRB_simulated_gambling,
  ESRB_strong_language,
  ESRB_strong_lyrics,
  ESRB_strong_sexual_content,
  ESRB_suggestive_themes,
  ESRB_tobacco_reference,
  ESRB_use_of_alcohol,
  ESRB_use_of_drugs,
  ESRB_use_of_tobacco,
  ESRB_violence,
  ESRB_violent_references,
  ESRB_animated_violence,
  ESRB_mild_language,
  ESRB_mild_violence,
  ESRB_use_of_drugs_and_alcohol,
  ESRB_drug_and_alcohol_reference,
  ESRB_mild_suggestive_themes,
  ESRB_mild_cartoon_violence,
  ESRB_mild_blood,
  ESRB_realistic_blood_and_gore,
  ESRB_realistic_violence,
  ESRB_alcohol_and_tobacco_reference,
  ESRB_mature_sexual_themes,
  ESRB_mild_animated_violence,
  ESRB_mild_sexual_themes,
  ESRB_use_of_alcohol_and_tobacco,
  ESRB_animated_blood_and_gore,
  ESRB_mild_fantasy_violence,
  ESRB_mild_lyrics,
  ESRB_realistic_blood,
  PEGI_violence,
  PEGI_sex,
  PEGI_drugs,
  PEGI_fear,
  PEGI_discrimination,
  PEGI_bad_language,
  PEGI_gambling,
  PEGI_online_gameplay,
  PEGI_in_game_purchases,
  CERO_love,
  CERO_sexual_content,
  CERO_violence,
  CERO_horror,
  CERO_drinking_smoking,
  CERO_gambling,
  CERO_crime,
  CERO_controlled_substances,
  CERO_languages_and_others,
  GRAC_sexuality,
  GRAC_violence,
  GRAC_fear_horror_threatening,
  GRAC_language,
  GRAC_alcohol_tobacco_drug,
  GRAC_crime_anti_social,
  GRAC_gambling,
  CLASS_IND_violencia,
  CLASS_IND_violencia_extrema,
  CLASS_IND_conteudo_sexual,
  CLASS_IND_nudez,
  CLASS_IND_sexo,
  CLASS_IND_sexo_explicito,
  CLASS_IND_drogas,
  CLASS_IND_drogas_licitas,
  CLASS_IND_drogas_ilicitas,
  CLASS_IND_linguagem_impropria,
  CLASS_IND_atos_criminosos,
}

extension AgeRatingContentDescriptionCategoryExtension on AgeRatingContentDescriptionCategory {
  int get value {
    return this.index + 1;
  }

  static AgeRatingContentDescriptionCategory fromValue(int value) {
    return AgeRatingContentDescriptionCategory.values[value - 1];
  }
}
