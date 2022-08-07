import 'dart:math';

/// clamps [value] to [min] and [max]
double clamp<T extends num>(T number, T low, T high) =>
    max(low * 1.0, min(number * 1.0, high * 1.0));
