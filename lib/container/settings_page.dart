// Copyright (C) 2021 Michael Debertol
//
// This file is part of digitales_register.
//
// digitales_register is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// digitales_register is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with digitales_register.  If not, see <http://www.gnu.org/licenses/>.

import 'package:built_collection/built_collection.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_built_redux/flutter_built_redux.dart';

import '../actions/app_actions.dart';
import '../app_state.dart';
import '../ui/settings_page_widget.dart';

class SettingsPageContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnection<AppState, AppActions, SettingsViewModel>(
      builder: (context, vm, actions) {
        return SettingsPageWidget(
          vm: vm,
          onSetDarkMode: (dm) {
            DynamicTheme.of(context)!.setBrightness(
              dm ? Brightness.dark : Brightness.light,
            );
          },
          onSetFollowDeviceDarkMode: (dm) {
            DynamicTheme.of(context)!.setFollowDevice(dm);
          },
          onSetPlatformOverride: (o) {
            DynamicTheme.of(context)!.setPlatformOverride(o);
          },
          onSetNoPassSaving: actions.settingsActions.saveNoPass,
          onSetNoDataSaving: actions.settingsActions.saveNoData,
          onSetAskWhenDelete: actions.settingsActions.askWhenDeleteReminder,
          onSetDeleteDataOnLogout: actions.settingsActions.deleteDataOnLogout,
          onSetSubjectNicks: (map) =>
              actions.settingsActions.subjectNicks(BuiltMap(map)),
          onSetShowCalendarEditNicksBar:
              actions.settingsActions.showCalendarSubjectNicksBar,
          onSetShowGradesDiagram: actions.settingsActions.showGradesDiagram,
          onSetShowAllSubjectsAverage:
              actions.settingsActions.showAllSubjectsAverage,
          onSetDashboardMarkNewOrChangedEntries:
              actions.settingsActions.markNotSeenDashboardEntries,
          onSetDashboardDeduplicateEntries:
              actions.settingsActions.deduplicateDashboardEntries,
          onShowProfile: actions.routingActions.showProfile,
          onSetIgnoreForGradesAverage: (list) =>
              actions.settingsActions.ignoreSubjectsForAverage(BuiltList(list)),
          onSetDashboardColorBorders:
              actions.settingsActions.dashboardColorBorders,
          onSetDashboardColorTestsInRed:
              actions.settingsActions.dashboardColorTestsInRed,
          onSetSubjectTheme: actions.settingsActions.setSubjectTheme,
        );
      },
      connect: (state) {
        return SettingsViewModel(state);
      },
    );
  }
}

typedef OnSettingChanged<T> = void Function(T newValue);

class SettingsViewModel {
  final Map<String, String> subjectNicks;
  final bool noPassSaving;
  final bool noDataSaving;
  final bool askWhenDelete;
  final bool deleteDataOnLogout;
  final bool showCalendarEditNicksBar;
  final bool showGradesDiagram;
  final bool showAllSubjectsAverage;
  final bool dashboardMarkNewOrChangedEntries;
  final bool dashboardDeduplicateEntries;
  final bool showSubjectNicks;
  final bool showGradesSettings;
  final bool dashboardColorBorders;
  final bool dashboardColorTestsInRed;
  final List<String> allSubjects;
  final List<String> ignoreForGradesAverage;
  final BuiltMap<String, SubjectTheme> subjectThemes;
  SettingsViewModel(AppState state)
      : noPassSaving = state.settingsState.noPasswordSaving,
        noDataSaving = state.settingsState.noDataSaving,
        askWhenDelete = state.settingsState.askWhenDelete,
        deleteDataOnLogout = state.settingsState.deleteDataOnLogout,
        subjectNicks = state.settingsState.subjectNicks.toMap(),
        showSubjectNicks = state.settingsState.scrollToSubjectNicks,
        showGradesSettings = state.settingsState.scrollToGrades,
        showCalendarEditNicksBar = state.settingsState.showCalendarNicksBar,
        showGradesDiagram = state.settingsState.showGradesDiagram,
        showAllSubjectsAverage = state.settingsState.showAllSubjectsAverage,
        dashboardMarkNewOrChangedEntries =
            state.settingsState.dashboardMarkNewOrChangedEntries,
        dashboardDeduplicateEntries =
            state.settingsState.dashboardDeduplicateEntries,
        dashboardColorBorders = state.settingsState.dashboardColorBorders,
        dashboardColorTestsInRed = state.settingsState.dashboardColorTestsInRed,
        allSubjects = state.extractAllSubjects(),
        ignoreForGradesAverage =
            state.settingsState.ignoreForGradesAverage.toList(),
        subjectThemes = state.settingsState.subjectThemes;
}
