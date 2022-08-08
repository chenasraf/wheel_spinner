# wheel_spinner

WheelSpinner provides you with a simple number spinner that resembles a wheel, knob, or more
specifically pitch bender knobs. It allows you to update a single `double` value with a finger fling
or drag as in the example below.

<img src="https://casraf.blog/assets/images/wheel-spinner-tutorial/scr04.gif" width="300px" />
<img src="https://casraf.blog/assets/images/wheel-spinner-tutorial/scr05.gif" width="300px" />

## How to use

Simply import the package, and use the exposed `WheelSpinner` widget.

See all the individual parameters for more details on theme and display customization, as well as
event handlers. Here is a simple usage example:

```dart
Widget build(BuildContext context) {
  return WheelSpinner(
    value: value,
    min: 0.0,
    max: 100.0,
    onSlideUpdate: (val) => onChange(value),
  );
}
```

## Customizing the theme

You can use the `theme` property to override a theme once, or wrap many sliders in the same
`WheelSpinnerTheme` widget, which references a theme in its' `data` property.

**Direct override example:**

```dart
WheelSpinner(
  value: value,
  min: 0.0,
  max: 100.0,
  onSlideUpdate: (val) => onChange(value),
  theme: WheelSpinnerThemeData.light().copyWith(
    borderRadius: BorderRadius.circular(10),
  ),
)
```

**Inherited widget override example:**

```dart
WheelSpinnerTheme(
  data: WheelSpinnerThemeData.light().copyWith(
    borderRadius: BorderRadius.circular(10),
  ),
  child: WheelSpinner(
    value: value,
    min: 0.0,
    max: 100.0,
    onSlideUpdate: (val) => onChange(value),
  ),
)
```
