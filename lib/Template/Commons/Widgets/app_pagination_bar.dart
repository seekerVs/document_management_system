import 'package:flutter/material.dart';

class AppPaginationBar extends StatelessWidget {
  final int totalPages;
  final int currentPage;
  final bool isLoading;
  final bool isVisible;
  final Function(int) onPageChanged;
  final Future<void> Function() onNext;
  final Future<void> Function() onPrevious;

  const AppPaginationBar({
    super.key,
    required this.totalPages,
    required this.currentPage,
    this.isLoading = false,
    this.isVisible = true,
    required this.onPageChanged,
    required this.onNext,
    required this.onPrevious,
  });

  static const double _chipSize = 48.0;
  static const double _chipSpacing = 4.0;
  static const double _borderRadius = 10.0;

  @override
  Widget build(BuildContext context) {
    if (!isVisible || totalPages <= 1) return const SizedBox.shrink();

    final pages = _buildVisiblePages(currentPage, totalPages);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ← Prev button
              _PageNavButton(
                icon: Icons.chevron_left_rounded,
                enabled: currentPage > 1 && !isLoading,
                onTap: onPrevious,
                size: _chipSize,
                borderRadius: _borderRadius,
              ),
              const SizedBox(width: _chipSpacing),

              ...pages.map((page) {
                if (page == 0) {
                  return const SizedBox(
                    width: _chipSize + _chipSpacing,
                    height: _chipSize,
                  );
                }
                if (page == -1) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: _chipSpacing / 2,
                    ),
                    child: _EllipsisChip(
                      size: _chipSize,
                      borderRadius: _borderRadius,
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: _chipSpacing / 2,
                  ),
                  child: _PageNumberChip(
                    page: page,
                    isActive: page == currentPage,
                    onTap: isLoading ? null : () => onPageChanged(page),
                    size: _chipSize,
                    borderRadius: _borderRadius,
                  ),
                );
              }),

              const SizedBox(width: _chipSpacing),
              // → Next button
              _PageNavButton(
                icon: Icons.chevron_right_rounded,
                enabled: currentPage < totalPages && !isLoading,
                onTap: onNext,
                size: _chipSize,
                borderRadius: _borderRadius,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<int> _buildVisiblePages(int current, int total) {
    if (total <= 4) {
      final pages = List.generate(total, (i) => i + 1);
      while (pages.length < 4) {
        pages.add(0);
      }
      return pages;
    }

    if (current <= 2) {
      return [1, 2, -1, total];
    }

    if (current >= total - 1) {
      return [1, -1, total - 1, total];
    }

    return [1, current, -1, total];
  }
}

class _PageNumberChip extends StatelessWidget {
  final int page;
  final bool isActive;
  final VoidCallback? onTap;
  final double size;
  final double borderRadius;

  const _PageNumberChip({
    required this.page,
    required this.isActive,
    required this.onTap,
    required this.size,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeInOut,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isActive ? cs.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        border: isActive ? null : Border.all(color: cs.outlineVariant, width: 1.2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: onTap,
          child: Center(
            child: Text(
              '$page',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    color: isActive ? cs.onPrimary : cs.onSurfaceVariant,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EllipsisChip extends StatelessWidget {
  final double size;
  final double borderRadius;

  const _EllipsisChip({required this.size, required this.borderRadius});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: cs.outlineVariant, width: 1.2),
      ),
      child: Center(
        child: Text(
          '···',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
        ),
      ),
    );
  }
}

class _PageNavButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final Future<void> Function() onTap;
  final double size;
  final double borderRadius;

  const _PageNavButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
    required this.size,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: enabled ? cs.outlineVariant : cs.outlineVariant.withValues(alpha: 0.4),
          width: 1.2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: enabled ? () => onTap() : null,
          child: Center(
            child: Icon(
              icon,
              size: 18,
              color: enabled ? cs.primary : cs.onSurface.withValues(alpha: 0.3),
            ),
          ),
        ),
      ),
    );
  }
}
