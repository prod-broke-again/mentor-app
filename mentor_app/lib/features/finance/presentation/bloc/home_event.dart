part of 'home_bloc.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

final class HomeLoadRequested extends HomeEvent {
  const HomeLoadRequested();
}

final class HomeAiTextSent extends HomeEvent {
  const HomeAiTextSent(this.text);

  final String text;

  @override
  List<Object?> get props => [text];
}

final class HomeMicPressed extends HomeEvent {
  const HomeMicPressed();
}

final class HomeMicReleased extends HomeEvent {
  const HomeMicReleased();
}
