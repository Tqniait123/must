import 'package:equatable/equatable.dart';

abstract class ParkingTimerState extends Equatable {
  const ParkingTimerState();

  @override
  List<Object?> get props => [];
}

class ParkingTimerInitial extends ParkingTimerState {
  const ParkingTimerInitial();
}

class ParkingTimerLoading extends ParkingTimerState {
  const ParkingTimerLoading();
}

class ParkingTimerRunning extends ParkingTimerState {
  final String elapsedTime;
  final DateTime startTime;
  final int timerTickCount;
  final List<String> logs;

  const ParkingTimerRunning({
    required this.elapsedTime,
    required this.startTime,
    required this.timerTickCount,
    required this.logs,
  });

  @override
  List<Object?> get props => [identityHashCode(this)];

  ParkingTimerRunning copyWith({String? elapsedTime, DateTime? startTime, int? timerTickCount, List<String>? logs}) {
    return ParkingTimerRunning(
      elapsedTime: elapsedTime ?? this.elapsedTime,
      startTime: startTime ?? this.startTime,
      timerTickCount: timerTickCount ?? this.timerTickCount,
      logs: logs ?? this.logs,
    );
  }
}

class ParkingTimerError extends ParkingTimerState {
  final String message;
  final List<String> logs;

  const ParkingTimerError({required this.message, required this.logs});

  @override
  List<Object?> get props => [message, logs];
}
