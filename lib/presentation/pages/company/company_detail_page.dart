// ==================================================
// COMPANY DETAIL PAGE (WITH BLOC)
// ==================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/presentation/blocs/auth/auth_bloc.dart';
import 'package:gamer_grove/presentation/blocs/auth/auth_state.dart';
import 'package:gamer_grove/presentation/blocs/company/company_bloc.dart';
import 'package:gamer_grove/presentation/blocs/company/company_event.dart';
import 'package:gamer_grove/presentation/blocs/company/company_state.dart';
import 'package:gamer_grove/presentation/pages/company/company_details_screen.dart';
import 'package:gamer_grove/presentation/widgets/live_loading_progress.dart';

class CompanyDetailPage extends StatefulWidget {
  final int companyId;

  const CompanyDetailPage({
    super.key,
    required this.companyId,
  });

  @override
  State<CompanyDetailPage> createState() => _CompanyDetailPageState();
}

class _CompanyDetailPageState extends State<CompanyDetailPage> {
  @override
  void initState() {
    super.initState();
    _loadCompanyDetails();
  }

  void _loadCompanyDetails() {
    final authState = context.read<AuthBloc>().state;
    String? userId;
    if (authState is AuthAuthenticated) {
      userId = authState.user.id;
    }

    print('🏢 CompanyDetailPage: Loading company ID: ${widget.companyId}');
    print('👤 CompanyDetailPage: User ID: ${userId ?? "Not authenticated"}');

    context.read<CompanyBloc>().add(
          GetCompanyDetailsEvent(
            companyId: widget.companyId,
            includeGames: true,
            userId: userId,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<CompanyBloc, CompanyState>(
        builder: (context, state) {
          print('🏢 CompanyDetailPage: Current state: ${state.runtimeType}');

          if (state is CompanyLoading) {
            return _buildLoadingState();
          } else if (state is CompanyDetailsLoaded) {
            print('✅ CompanyDetailPage: Loaded company: ${state.company.name}');
            print('🎮 CompanyDetailPage: Games count: ${state.games.length}');
            return CompanyDetailScreen(
              company: state.company,
              games: state.games,
            );
          } else if (state is CompanyError) {
            print('❌ CompanyDetailPage: Error: ${state.message}');
            return _buildErrorState(state.message);
          }

          return _buildLoadingState();
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: LiveLoadingProgress(
              title: 'Loading Company Details',
              steps: CompanyLoadingSteps.companyDetails(context),
              stepDuration: const Duration(milliseconds: 700),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load company',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadCompanyDetails,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
