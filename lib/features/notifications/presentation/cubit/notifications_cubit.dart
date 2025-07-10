import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:must_invest/core/errors/app_error.dart';
import 'package:must_invest/features/notifications/data/models/notification_model.dart';

import '../../data/repositories/notifications_repo.dart';

part 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final NotificationsRepo _repository;

  NotificationsCubit(this._repository) : super(NotificationsInitial());

  static NotificationsCubit get(context) => BlocProvider.of(context);

  Future<void> getNotifications() async {
    try {
      emit(NotificationsLoading());
      final response = await _repository.getNotifications();
      response.fold(
        (notifications) => emit(NotificationsSuccess(notifications)),
        (error) => emit(NotificationsError(error.message)),
      );
    } on AppError catch (e) {
      emit(NotificationsError(e.message));
    } catch (e) {
      emit(NotificationsError(e.toString()));
    }
  }

  // Add your cubit methods here
}
