import 'dart:math';

/// clamps [number] to [low] and [high]
double clamp<T extends num>(T number, T low, T high) =>
    max(low * 1.0, min(number * 1.0, high * 1.0));
