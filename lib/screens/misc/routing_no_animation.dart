// Custom PageRoute that skips transitions
import 'package:flutter/material.dart';

class NoTransitionPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  NoTransitionPageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: Duration.zero, // No transition duration
          reverseTransitionDuration:
              Duration.zero, // No reverse transition duration
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              child, // No transitions
        );
}

// Usage example
void navigateWithoutTransition(BuildContext context, Widget page) {
  Navigator.of(context).push(NoTransitionPageRoute(page: page));
}
