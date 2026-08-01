import 'package:flutter/material.dart';

import '../localization/app_strings.dart';
import '../theme/app_colors.dart';

class PinKeypad extends StatelessWidget {
  const PinKeypad({
    required this.pinLength,
    required this.onDigit,
    required this.onBackspace,
    super.key,
    this.compact = false,
    this.showLetters = false,
  });

  final int pinLength;
  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  final bool compact;
  final bool showLetters;

  static const _letters = [
    '',
    '',
    'ABC',
    'DEF',
    'GHI',
    'JKL',
    'MNO',
    'PQRS',
    'TUV',
    'WXYZ',
  ];

  @override
  Widget build(BuildContext context) {
    final keyExtent = compact ? 68.0 : 76.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (index) {
            final filled = index < pinLength;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: filled ? 14 : 13,
              height: filled ? 14 : 13,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: filled ? AppColors.cyan : Colors.transparent,
                border: Border.all(
                  color: filled ? AppColors.cyan : AppColors.outline,
                  width: 2,
                ),
                boxShadow: filled
                    ? [
                        BoxShadow(
                          color: AppColors.cyan.withValues(alpha: .5),
                          blurRadius: 10,
                        ),
                      ]
                    : null,
              ),
            );
          }),
        ),
        SizedBox(height: compact ? 20 : 28),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: compact ? 300 : 340),
          child: Column(
            children: [
              for (var row = 0; row < 3; row++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(3, (column) {
                      final digit = row * 3 + column + 1;
                      return _PinKey(
                        digit: '$digit',
                        letters: showLetters ? _letters[digit] : '',
                        extent: keyExtent,
                        onPressed: () => onDigit('$digit'),
                      );
                    }),
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(width: keyExtent, height: keyExtent),
                  _PinKey(
                    digit: '0',
                    letters: '',
                    extent: keyExtent,
                    onPressed: () => onDigit('0'),
                  ),
                  Semantics(
                    button: true,
                    label: AppStrings.deleteDigit,
                    child: IconButton(
                      onPressed: onBackspace,
                      icon: const Icon(Icons.backspace_outlined),
                      color: AppColors.onSurfaceVariant,
                      iconSize: 27,
                      style: IconButton.styleFrom(
                        fixedSize: Size.square(keyExtent),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PinKey extends StatelessWidget {
  const _PinKey({
    required this.digit,
    required this.letters,
    required this.extent,
    required this.onPressed,
  });

  final String digit;
  final String letters;
  final double extent;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${AppStrings.pinDigit} $digit',
      child: Material(
        color: AppColors.surfaceHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.outlineVariant),
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: SizedBox.square(
            dimension: extent,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  digit,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (letters.isNotEmpty)
                  Text(
                    letters,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
