import 'package:flutter/material.dart';

class ConnectingBody extends StatelessWidget {
  const ConnectingBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
          const SizedBox(height: 24),
          Text(
            'Opening serial…',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
