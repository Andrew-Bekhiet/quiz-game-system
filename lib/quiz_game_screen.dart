import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_app/cubit/quiz_game_cubit.dart';
import 'package:quiz_app/cubit/quiz_game_state.dart';

class QuizGameScreen extends StatefulWidget {
  const QuizGameScreen({super.key});

  @override
  State<QuizGameScreen> createState() => _QuizGameScreenState();
}

class _QuizGameScreenState extends State<QuizGameScreen> {
  String? _selectedPort;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final s = context.read<QuizGameCubit>().state;
      if (s case QuizGameStateDisconnected(:final availablePorts)) {
        setState(() => _syncSelectedPort(availablePorts));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F1419),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.quiz_outlined,
                      color: theme.colorScheme.primary, size: 32),
                  const SizedBox(width: 12),
                  Text(
                    'Quiz buzzer',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Spacer(),
                  BlocBuilder<QuizGameCubit, QuizGameState>(
                    buildWhen: (prev, curr) =>
                        curr is QuizGameStateWaiting ||
                        curr is QuizGameStatePlayerWon,
                    builder: (context, state) {
                      if (state is! QuizGameStateWaiting &&
                          state is! QuizGameStatePlayerWon) {
                        return const SizedBox.shrink();
                      }
                      return TextButton.icon(
                        onPressed: () =>
                            context.read<QuizGameCubit>().disconnect(),
                        icon: const Icon(Icons.link_off, color: Colors.white70),
                        label: const Text(
                          'Disconnect',
                          style: TextStyle(color: Colors.white70),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Mirrors signals from your Arduino quiz rig: buzzers print the winner over serial; reset notifies the desk.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white54,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: BlocConsumer<QuizGameCubit, QuizGameState>(
                  listener: (context, state) {
                    if (state is QuizGameStateDisconnected) {
                      setState(() {
                        _syncSelectedPort(state.availablePorts);
                      });
                    }
                  },
                  builder: (context, state) {
                    return switch (state) {
                      QuizGameStateDisconnected(:final availablePorts) =>
                        _DisconnectedBody(
                          ports: availablePorts,
                          selectedPort: _selectedPort,
                          onPortChanged: (p) =>
                              setState(() => _selectedPort = p),
                          onRefresh: () => context
                              .read<QuizGameCubit>()
                              .refreshPorts(),
                          onConnect: _selectedPort == null
                              ? null
                              : () => context
                                  .read<QuizGameCubit>()
                                  .connect(_selectedPort!),
                        ),
                      QuizGameStateConnecting() =>
                        const _ConnectingBody(),
                      QuizGameStateWaiting() => const _LiveGameBody(),
                      QuizGameStatePlayerWon(:final playerNumber) =>
                        _WinnerBody(playerNumber: playerNumber),
                      QuizGameStateError(:final message) => _ErrorBody(
                          message: message,
                          onRetry: () =>
                              context.read<QuizGameCubit>().disconnect(),
                        ),
                    };
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _syncSelectedPort(List<String> ports) {
    if (ports.isEmpty) {
      _selectedPort = null;
      return;
    }
    if (_selectedPort != null && ports.contains(_selectedPort)) {
      return;
    }
    _selectedPort = ports.length == 1 ? ports.single : ports.first;
  }
}

class _DisconnectedBody extends StatelessWidget {
  const _DisconnectedBody({
    required this.ports,
    required this.selectedPort,
    required this.onPortChanged,
    required this.onRefresh,
    required this.onConnect,
  });

  final List<String> ports;
  final String? selectedPort;
  final ValueChanged<String?> onPortChanged;
  final VoidCallback onRefresh;
  final VoidCallback? onConnect;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF1A222C),
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
                      Icon(Icons.link_off_rounded,
                          size: 56, color: Colors.white.withValues(alpha: 0.35)),
                      const SizedBox(height: 16),
                      Text(
                        'No serial devices found.',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white70,
                            ),
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
                    fillColor: const Color(0xFF252E3A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  ),
                  child: DropdownButton<String>(
                    isExpanded: true,
                    dropdownColor: const Color(0xFF252E3A),
                    style: const TextStyle(color: Colors.white),
                    value: selectedPort,
                    items: ports
                        .map(
                          (p) =>
                              DropdownMenuItem(value: p, child: Text(p)),
                        )
                        .toList(),
                    onChanged: onPortChanged,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
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

class _ConnectingBody extends StatelessWidget {
  const _ConnectingBody();

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

class _LiveGameBody extends StatelessWidget {
  const _LiveGameBody();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF143D29),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: const Color(0xFF2ECC71).withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF2ECC71),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Live — first buzz wins',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: const Color(0xFFAAF0C4),
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        const Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _PlayerPanel(
                  team: 1,
                  lit: true,
                  accent: Color(0xFF3498DB),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _PlayerPanel(
                  team: 2,
                  lit: true,
                  accent: Color(0xFFE67E22),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Press the hardware RESET on the Arduino to start another round.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.45),
              ),
        ),
      ],
    );
  }
}

class _PlayerPanel extends StatelessWidget {
  const _PlayerPanel({
    required this.team,
    required this.lit,
    required this.accent,
  });

  final int team;
  final bool lit;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: lit ? accent.withValues(alpha: 0.18) : const Color(0xFF1A222C),
        border: Border.all(
          color: lit ? accent.withValues(alpha: 0.7) : Colors.white12,
          width: lit ? 2 : 1,
        ),
        boxShadow: lit
            ? [
                BoxShadow(
                  color: accent.withValues(alpha: 0.35),
                  blurRadius: 24,
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lightbulb_rounded,
            size: 64,
            color: lit ? accent : Colors.white24,
          ),
          const SizedBox(height: 12),
          Text(
            'Player $team',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            lit ? 'Armed' : 'Out',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: lit ? accent : Colors.white38,
                ),
          ),
        ],
      ),
    );
  }
}

class _WinnerBody extends StatelessWidget {
  const _WinnerBody({required this.playerNumber});

  final int playerNumber;

  @override
  Widget build(BuildContext context) {
    final accent = playerNumber == 1
        ? const Color(0xFF3498DB)
        : const Color(0xFFE67E22);
    final other = playerNumber == 1 ? 2 : 1;

    return Column(
      children: [
        const Spacer(),
        Icon(
          Icons.emoji_events_rounded,
          size: 88,
          color: accent,
        ),
        const SizedBox(height: 20),
        Text(
          'Player $playerNumber',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
        ),
        Text(
          'BUZZED IN FIRST',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: accent,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: _PlayerPanel(team: playerNumber, lit: true, accent: accent),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _PlayerPanel(
                team: other,
                lit: false,
                accent: accent,
              ),
            ),
          ],
        ),
        const Spacer(),
        Text(
          'Reset on the Arduino clears the lamps and notifies this screen.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.45),
              ),
        ),
      ],
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning_amber_rounded,
                size: 56, color: Colors.redAccent.shade200),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Back to connection'),
            ),
          ],
        ),
      ),
    );
  }
}
