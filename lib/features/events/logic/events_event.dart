part of 'events_bloc.dart';

abstract class EventsEvent extends Equatable {
  const EventsEvent();
  @override
  List<Object> get props => [];
}

// Event yang akan di-dispatch dari UI untuk mengambil data
class FetchEvents extends EventsEvent {}
