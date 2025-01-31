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

import '../container/absence_group_container.dart';
import '../data.dart';

class AbsenceGroupWidget extends StatelessWidget {
  final AbsencesViewModel vm;

  const AbsenceGroupWidget({Key? key, required this.vm}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        side: vm.justified == AbsenceJustified.notYetJustified ||
                vm.justified == AbsenceJustified.notJustified
            ? const BorderSide(color: Colors.red)
            : const BorderSide(color: Colors.green, width: 0),
        borderRadius: BorderRadius.circular(16),
      ),
      color: Colors.transparent,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            if (vm.reason != null) ...[
              Text(vm.reason!),
              Row(
                children: const [
                  Spacer(),
                  Flexible(
                    flex: 48,
                    child: Divider(
                      height: 8,
                    ),
                  ),
                  Spacer(),
                ],
              ),
            ],
            Text(
              vm.fromTo,
              style: Theme.of(context).textTheme.subtitle1,
            ),
            Text(
              vm.duration,
              style: Theme.of(context).textTheme.bodyText2,
            ),
            Row(
              children: const [
                Spacer(),
                Flexible(
                  flex: 48,
                  child: Divider(
                    height: 8,
                  ),
                ),
                Spacer(),
              ],
            ),
            Text(
              vm.justifiedString,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
