# wheel_spinner

WheelSpinner provides you with a simple number spinner that resembles a wheel, knob, or more
specifically pitch bender knobs. It allows you to update a single `double` value with a finger fling
or drag as in the example below.

<img src="https://casraf.blog/assets/images/wheel-spinner-tutorial/scr04.gif" width="300px" /> <img src="https://casraf.blog/assets/images/wheel-spinner-tutorial/scr05.gif" width="300px" />

## How to use

Simply import the package, and use the exposed `WheelSpinner` widget.

See all the individual parameters for more details on theme and display customization, as well as
event handlers. Here is a a full usage example:

```dart
Widget build(BuildContext context) {
  return WheelSpinner(
    // required
    value: value,
    min: 0.0,
    max: 100.0,

    // optional
    onSlideStart: (val) => debugPrint(value),
    onSlideUpdate: (val) => onChange(value),
    onSlideDone: (val) => debugPrint(value),
    childBuilder: (val) => Text(val.toString()),
    theme: WheelSpinnerTheme.light(),
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
  theme: WheelSpinnerTheme.light().copyWith(
    borderRadius: BorderRadius.circular(10),
  ),
)
```

**Inherited widget override example:**

```dart
WheelSpinnerTheme(
  data: WheelSpinnerTheme.light().copyWith(
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

## Contributing

I am developing this package on my free time, so any support, whether code, issues, or just stars is
very helpful to sustaining its life. If you are feeling incredibly generous and would like to donate
just a small amount to help sustain this project, I would be very very thankful!

<a href='https://ko-fi.com/casraf' target='_blank'>
  <img height='36' style='border:0px;height:36px;'
    src='https://cdn.ko-fi.com/cdn/kofi1.png?v=3'
    alt='Buy Me a Coffee at ko-fi.com' />
</a>

I welcome any issues or pull requests on GitHub. If you find a bug, or would like a new feature,
don't hesitate to open an appropriate issue and I will do my best to reply promptly.

If you are a developer and want to contribute code, here are some starting tips:

1. Fork this repository
2. Run `dart pub get`
3. Make any changes you would like
4. Update the relevant documentation (readme, code comments)
5. Create a PR on upstream
