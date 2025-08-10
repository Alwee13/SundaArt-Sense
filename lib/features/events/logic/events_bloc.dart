import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:sundaart_sense/features/events/data/models/event_model.dart';
import 'package:sundaart_sense/features/events/data/repositories/event_repository.dart';

part 'events_event.dart';
part 'events_state.dart';

class EventsBloc extends Bloc<EventsEvent, EventsState> {
  final EventRepository _eventRepository;

  EventsBloc({required EventRepository eventRepository})
    : _eventRepository = eventRepository,
      super(EventsInitial()) {
    on<FetchEvents>(_onFetchEvents);
  }

  void _onFetchEvents(FetchEvents event, Emitter<EventsState> emit) async {
    emit(EventsLoading());
    try {
      final events = await _eventRepository.getEvents();
      emit(EventsLoaded(events));
    } catch (e) {
      emit(EventsError(e.toString()));
    }
  }
}
