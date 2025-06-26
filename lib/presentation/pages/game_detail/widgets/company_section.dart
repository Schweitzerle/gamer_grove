// ==================================================
// COMPANY SECTION
// ==================================================

// lib/presentation/pages/game_detail/widgets/company_section.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/cached_image_widget.dart';
import '../../../../domain/entities/involved_company.dart';

class CompanySection extends StatelessWidget {
  final List<InvolvedCompany> companies;

  const CompanySection({
    super.key,
    required this.companies,
  });

  @override
  Widget build(BuildContext context) {
    final developers = companies.where((c) => c.isDeveloper).toList();
    final publishers = companies.where((c) => c.isPublisher).toList();
    final others = companies.where((c) => !c.isDeveloper && !c.isPublisher).toList();

    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Companies',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),

          if (developers.isNotEmpty) ...[
            _buildCompanySubsection(context, 'Developer', developers),
            const SizedBox(height: AppConstants.paddingMedium),
          ],

          if (publishers.isNotEmpty) ...[
            _buildCompanySubsection(context, 'Publisher', publishers),
            const SizedBox(height: AppConstants.paddingMedium),
          ],

          if (others.isNotEmpty) ...[
            _buildCompanySubsection(context, 'Other Companies', others),
          ],
        ],
      ),
    );
  }

  Widget _buildCompanySubsection(
      BuildContext context,
      String title,
      List<InvolvedCompany> companyList,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        ...companyList.map((involvedCompany) => _buildCompanyTile(context, involvedCompany)),
      ],
    );
  }

  Widget _buildCompanyTile(BuildContext context, InvolvedCompany involvedCompany) {
    final company = involvedCompany.company;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: company.logoUrl != null
            ? ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedImageWidget(
            imageUrl: company.logoUrl!,
            width: 40,
            height: 40,
            fit: BoxFit.contain,
          ),
        )
            : const Icon(Icons.business),
        title: Text(company.name),
        subtitle: company.country != null ? Text(company.country!) : null,
        trailing: _buildRoleBadges(context, involvedCompany),
        onTap: () {
          // Navigate to company details
        },
      ),
    );
  }

  Widget _buildRoleBadges(BuildContext context, InvolvedCompany company) {
    final roles = <String>[];
    if (company.isDeveloper) roles.add('Dev');
    if (company.isPublisher) roles.add('Pub');
    if (company.isPorting) roles.add('Port');
    if (company.isSupporting) roles.add('Support');

    return Wrap(
      spacing: 4,
      children: roles.map((role) => Chip(
        label: Text(
          role,
          style: const TextStyle(fontSize: 10),
        ),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      )).toList(),
    );
  }
}