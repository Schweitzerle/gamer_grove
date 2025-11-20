// ==================================================
// COMPANY DETAIL PAGE (WITH BLOC)
// ==================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/core/widgets/error_widget.dart';
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

          if (state is CompanyLoading) {
            return _buildLoadingState();
          } else if (state is CompanyDetailsLoaded) {
            return CompanyDetailScreen(
              company: state.company,
              games: state.games,
            );
          } else if (state is CompanyError) {
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
    // Check if it's a network error
    final isNetworkError = message.toLowerCase().contains('internet') ||
        message.toLowerCase().contains('network') ||
        message.toLowerCase().contains('connection') ||
        message.toLowerCase().contains('timeout');

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        title: Text(
          'Company Details',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isNetworkError
          ? NetworkErrorWidget(onRetry: _loadCompanyDetails)
          : CustomErrorWidget(
              message: message,
              onRetry: _loadCompanyDetails,
            ),
    );
  }
}
