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

import 'package:flutter/material.dart';
import 'package:flutter_built_redux/flutter_built_redux.dart';

import '../actions/app_actions.dart';
import '../actions/login_actions.dart';
import '../app_state.dart';
import '../ui/request_pass_reset.dart';

class RequestPassResetContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnection<AppState, AppActions, ResetPassState>(
      connect: (AppState appState) => appState.loginState.resetPassState,
      builder: (context, state, actions) {
        return RequestPassReset(
          resetPass: (user, email) => actions.loginActions.requestPassReset(
            RequestPassResetPayload(
              (b) => b
                ..user = user
                ..email = email,
            ),
          ),
          message: state.message,
          failure: state.failure,
        );
      },
    );
  }
}
