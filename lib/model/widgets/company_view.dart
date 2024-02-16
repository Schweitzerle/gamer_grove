import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gamer_grove/model/igdb_models/company.dart';

import '../igdb_models/involved_companies.dart';

class InvolvedCompaniesList extends StatelessWidget {
  final List<InvolvedCompany> involvedCompanies;
  final Color lightColor;

  InvolvedCompaniesList({required this.involvedCompanies, required this.lightColor});

  @override
  Widget build(BuildContext context) {
    final luminance = lightColor.computeLuminance();
    final targetLuminance = 0.5;

    final adjustedIconColor =
    luminance > targetLuminance ? Colors.black : Colors.white;
    return  Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: lightColor.withOpacity(.5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 8, right: 8),
              child: Text(
                'Involved Companies',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: adjustedIconColor
                ),
              ),
            ),
            buildCategory("Publisher", adjustedIconColor, lightColor),
            buildCategory("Developer", adjustedIconColor, lightColor),
            buildCategory("Porting", adjustedIconColor, lightColor),
            buildCategory("Supporting", adjustedIconColor, lightColor),
          ],
        ),
      ),
    );
  }

  Widget buildCategory(String category, Color color, Color backgroundColor) {
    List<InvolvedCompany> companies = [];
    String title = "";

    switch (category) {
      case "Publisher":
        title = "Publisher";
        companies = involvedCompanies.where((company) => company.publisher == true).toList();
        break;
      case "Developer":
        title = "Developer";
        companies = involvedCompanies.where((company) => company.developer == true).toList();
        break;
      case "Porting":
        title = "Porting";
        companies = involvedCompanies.where((company) => company.porting == true).toList();
        break;
      case "Supporting":
        title = "Supporting";
        companies = involvedCompanies.where((company) => company.supporting == true).toList();
        break;
    }

    if (companies.isEmpty) {
      return SizedBox(); // Wenn die Liste leer ist, wird nichts angezeigt
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: backgroundColor,
      ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            SizedBox(height: 4),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: companies.map((company) {
                  return CompanyCard(company: company.company);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CompanyCard extends StatelessWidget {
  final Company? company;

  CompanyCard({required this.company});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(14),color: Colors.black,),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              // Bild des Unternehmens mit ShaderMask
              if (company?.logo != null)
                ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7), // Dunkelheit des Gradients anpassen
                      ],
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.darken,
                  child: CachedNetworkImage(
                    imageUrl: company!.logo!.url!,
                    width: 80,
                    height: 80,
                    fit: BoxFit.contain, // Bildgröße anpassen
                  ),
                ),
              // Name des Unternehmens
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
                  child: FittedBox(
                    child: Text(
                      company?.name ?? "",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



