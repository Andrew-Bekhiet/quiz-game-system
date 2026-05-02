import 'package:flutter/material.dart';
import 'package:quiz_app/quiz/quiz_game_colors.dart';

class DisconnectedBody extends StatelessWidget {
  const DisconnectedBody({
    required this.ports,
    required this.selectedPort,
    required this.onPortChanged,
    required this.onRefresh,
    required this.onConnect,
    super.key,
  });

  final List<String> ports;
  final String? selectedPort;
  final ValueChanged<String> onPortChanged;
  final VoidCallback onRefresh;
  final VoidCallback? onConnect;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: quizSurfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.usb, color: Colors.white70),
                const SizedBox(width: 12),
                Text(
                  'Connect serial',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton.filledTonal(
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Rescan ports',
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (ports.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.link_off_rounded,
                        size: 56,
                        color: Colors.white.withValues(alpha: 0.35),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No serial devices found.',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Plug in the Arduino and tap refresh.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              Text(
                'Port',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white54,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonHideUnderline(
                child: InputDecorator(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: quizInputColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                  ),
                  child: DropdownButton<String>(
                    isExpanded: true,
                    dropdownColor: quizInputColor,
                    style: const TextStyle(color: Colors.white),
                    value: selectedPort,
                    items: ports
                        .map((port) {
                          return DropdownMenuItem(
                            value: port,
                            child: Text(port),
                          );
                        })
                        .toList(growable: false),
                    onChanged: (port) => onPortChanged(port ?? ''),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: onConnect,
                icon: const Icon(Icons.power),
                label: const Text('Connect'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
