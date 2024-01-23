## 0.7.3

- Update dependencies
- Remove pubspec.lock file

## 0.7.2

- Fix Flutter v3 support

## 0.7.1

- Fix Flutter v2 support

## 0.7.0

- Add `childPosition` argument
- Remove excess public members
- Fix clipping behavior
- Improve theme delegation

## 0.6.2

- Remove unused `minMaxLabelBuilder` argument
- Add `onSlideStart` argument for `WheelSpinner`

## 0.6.1

- Update dark theme - remove border

## 0.6.0

- Use `WheelSpinnerTheme` and `WheelSpinnerThemeData` to define styles, similar to `Theme` and
  `ThemeData` in Flutter

- Remove min/max labels and +/- symbols as they are too coupled to the widget which doesn't seem to
  be in its' logical scope. It can be easily recreated and modified more extensively when done
  manually.

- Remove height/width params - the widget adheres to its parent constraints, and since the labels
  are not being built, the constraints can reliably set the size of the widget.

## 0.5.1

- Add example.dart

## 0.5.0

- General code improvement + finalize null safety support

## 0.0.7-nullsafety

- No changes

## 0.0.6-nullsafety

- Updated the package for null-safety

## 0.0.6

- Added style customization options

## 0.0.5

- Added finger fling physics to control

## 0.0.3-0.0.4

- Bugfixes

## 0.0.2

- Added `minMaxLabelBuilder`

## 0.0.1

- Initial release
