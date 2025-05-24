import 'package:flutter/material.dart';

class CustomUpperbar extends StatelessWidget {
  /// Para que poder usar StatelessWidget y aún así usar un valor opcional
  /// Se puede indicar un valor por defecto en el constructor.

  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  const CustomUpperbar(
      {super.key,
        required this.children,
        this.mainAxisAlignment = MainAxisAlignment.spaceAround});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: kMinInteractiveDimension,
      width: MediaQuery.of(context).size.width,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.all(
            Radius.circular(1),
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).appBarTheme.shadowColor!,
              blurRadius: 0,
              spreadRadius: 0,
              // offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: mainAxisAlignment,
          children: [
            ...children, // Spread operator como en JavaScript.
          ],
        ),
      ),
    );
  }
}
