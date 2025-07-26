// ==================================================
// EVENT DETAIL PAGE WRAPPER (using Bloc)
// ==================================================

// lib/presentation/pages/event_detail/event_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/game/game.dart';
import '../../blocs/event/event_bloc.dart';
import '../../blocs/event/event_event.dart';
import '../../blocs/event/event_state.dart';
import '../../widgets/custom_shimmer.dart';
import '../../widgets/live_loading_progress.dart';
import 'event_details_screen.dart';
// ==================================================
// ENHANCED EVENT DETAIL PAGE WITH LIVE LOADING
// ==================================================

// Updated event_detail_page.dart snippet:
class EventDetailPage extends StatefulWidget {
  final int eventId;
  final Game? game;

  const EventDetailPage({
    super.key,
    required this.eventId,
    this.game,
  });

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
            showGames: true,
          );
        } else if (state is EventDetailsLoaded) {
          return EventDetailScreen(
            event: state.event,
            featuredGames: null,
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
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
      ),
      body: Center(
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
              'Error Loading Event',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<EventBloc>().add(
                  GetCompleteEventDetailsEvent(eventId: widget.eventId),
                );
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}