import 'package:bloc/bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:must_invest/core/functions/force_app_update_ui.dart';
import 'package:must_invest/core/preferences/shared_pref.dart';
import 'package:must_invest/core/services/di.dart';

part 'languages_state.dart';

class LanguagesCubit extends Cubit<LanguagesState> {
  final MustInvestPreferences preferences;
  LanguagesCubit(this.preferences) : super(LanguagesInitial());

  void setLanguage(BuildContext context, String langCode) async {
    emit(LanguagesUpdating());
    Future.delayed(Duration.zero, () {
      preferences.saveLang(langCode);
      context.setLocale(Locale(langCode));
      langCode = sl<MustInvestPreferences>().getLang();
    });
    await forceAppUpdate();
    // Emit a new state with the updated language code
    emit(LanguagesUpdated(langCode));
  }
}
