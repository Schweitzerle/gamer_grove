// ==================================================
// EVENT DETAIL PAGE WRAPPER (using Bloc)
// ==================================================

// lib/presentation/pages/event_detail/event_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/core/widgets/error_widget.dart';
import 'package:gamer_grove/domain/entities/game/game.dart';
import 'package:gamer_grove/presentation/blocs/event/event_bloc.dart';
import 'package:gamer_grove/presentation/blocs/event/event_event.dart';
import 'package:gamer_grove/presentation/blocs/event/event_state.dart';
import 'package:gamer_grove/presentation/pages/event/event_details_screen.dart';
import 'package:gamer_grove/presentation/widgets/live_loading_progress.dart';
// ==================================================
// ENHANCED EVENT DETAIL PAGE WITH LIVE LOADING
// ==================================================

// Updated event_detail_page.dart snippet:
class EventDetailPage extends StatefulWidget {

  const EventDetailPage({
    required this.eventId, super.key,
    this.game,
  });
  final int eventId;
  final Game? game;

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  @override
  void initState() {
    super.initState();
    // Event details are loaded via Bloc when this page is pushed
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventBloc, EventState>(
      builder: (context, state) {
        if (state is EventLoading) {
          return _buildLiveLoadingState();
        } else if (state is CompleteEventDetailsLoaded) {
          return EventDetailScreen(
            event: state.eventDetails.event,
            featuredGames: state.eventDetails.featuredGames,
          );
        } else if (state is EventDetailsLoaded) {
          return EventDetailScreen(
            event: state.event,
            showGames: false,
          );
        } else if (state is EventError) {
          return _buildErrorState(state.message);
        }

        return _buildLiveLoadingState();
      },
    );
  }

  Widget _buildLiveLoadingState() {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).colorScheme.onSurface,),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: LiveLoadingProgress(
            title: 'Loading Event Details',
            steps: EventLoadingSteps.eventDetails(context),
            stepDuration: const Duration(milliseconds: 1200),
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

    // Retry callback
    void retry() {
      context.read<EventBloc>().add(
            GetCompleteEventDetailsEvent(eventId: widget.eventId),
          );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        title: Text(
          'Event Details',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).colorScheme.onSurface,),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isNetworkError
          ? NetworkErrorWidget(onRetry: retry)
          : CustomErrorWidget(
              message: message,
              onRetry: retry,
            ),
    );
  }
}
