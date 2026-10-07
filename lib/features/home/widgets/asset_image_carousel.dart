import 'dart:async';
import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../../assets/domain/asset.dart';
import '../../assets/presentation/asset_detail_page.dart';

class AssetImageCarousel extends StatefulWidget {
  const AssetImageCarousel({
    required this.assets,
    required this.onAddAsset,
    super.key,
  });

  final List<Asset> assets;
  final VoidCallback onAddAsset;

  @override
  State<AssetImageCarousel> createState() => _AssetImageCarouselState();
}

class _AssetImageCarouselState extends State<AssetImageCarousel> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _autoPlayTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    if (widget.assets.length <= 1) return;
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_pageController.hasClients) return;
      final nextPage = (_currentPage + 1) % widget.assets.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (widget.assets.isEmpty) {
      return Container(
        height: 180,
        decoration: BoxDecoration(
          color: isDark ? JagainColors.darkSurface : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isDark ? JagainColors.darkBorder : JagainColors.border,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add_photo_alternate_outlined,
                size: 38,
                color: isDark ? JagainColors.darkMuted : JagainColors.muted,
              ),
              const SizedBox(height: 10),
              FilledButton.icon(
                onPressed: widget.onAddAsset,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Tambah Aset Pertama'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 195,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.assets.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemBuilder: (context, index) {
              final asset = widget.assets[index];
              return _CarouselSlide(
                asset: asset,
                isDark: isDark,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AssetDetailPage(asset: asset),
                    ),
                  );
                },
              );
            },
          ),
        ),
        if (widget.assets.length > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.assets.length,
              (index) {
                final isSelected = index == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 240),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  height: 5,
                  width: isSelected ? 20 : 6,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark ? JagainColors.primaryLight : JagainColors.primaryDark)
                        : (isDark
                            ? JagainColors.darkMuted.withValues(alpha: 0.3)
                            : JagainColors.muted.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

class _CarouselSlide extends StatelessWidget {
  const _CarouselSlide({
    required this.asset,
    required this.isDark,
    required this.onTap,
  });

  final Asset asset;
  final bool isDark;
  final VoidCallback onTap;

  Color _getConditionColor(AssetCondition condition) {
    switch (condition) {
      case AssetCondition.good:
        return const Color(0xFF10B981);
      case AssetCondition.needsAttention:
        return const Color(0xFFF59E0B);
      case AssetCondition.underMaintenance:
        return const Color(0xFF3B82F6);
      case AssetCondition.critical:
        return const Color(0xFFEF4444);
    }
  }

  String _getConditionText(AssetCondition condition) {
    switch (condition) {
      case AssetCondition.good:
        return 'Baik';
      case AssetCondition.needsAttention:
        return 'Perlu Perhatian';
      case AssetCondition.underMaintenance:
        return 'Perawatan';
      case AssetCondition.critical:
        return 'Kritis';
    }
  }

  @override
  Widget build(BuildContext context) {
    final condColor = _getConditionColor(asset.condition);
    final condText = _getConditionText(asset.condition);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? JagainColors.darkSurface : const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isDark ? JagainColors.darkBorder : Colors.transparent,
              width: 1,
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Background Image
              if (asset.imagePath != null && asset.imagePath!.isNotEmpty)
                Image.asset(
                  asset.imagePath!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _buildFallbackBackground(),
                )
              else
                _buildFallbackBackground(),

              // 2. Multi-stop Gradient Vignette for perfect text readability
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.45),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.75),
                      Colors.black.withValues(alpha: 0.90),
                    ],
                    stops: const [0.0, 0.35, 0.70, 1.0],
                  ),
                ),
              ),

              // 3. Top Badges: Category & Condition
              Positioned(
                top: 14,
                left: 14,
                right: 14,
                child: Row(
                  children: [
                    // Category Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getCategoryIcon(asset.categoryId),
                            size: 13,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _getCategoryName(asset.categoryId),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),

                    // Condition Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: condColor.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: condColor.withValues(alpha: 0.35),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            condText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 4. Bottom Information: Name, Subtitle & Checklist Status
              Positioned(
                bottom: 14,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      asset.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                        shadows: [
                          Shadow(
                            color: Colors.black54,
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            [
                              if (asset.brand != null) asset.brand,
                              if (asset.model != null) asset.model,
                              if (asset.location != null) asset.location,
                            ].whereType<String>().join(' · '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        if (asset.hasChecklist) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: asset.completedChecklistCount == asset.totalChecklistCount
                                  ? const Color(0xFF10B981).withValues(alpha: 0.3)
                                  : Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: asset.completedChecklistCount == asset.totalChecklistCount
                                    ? const Color(0xFF10B981).withValues(alpha: 0.6)
                                    : Colors.white.withValues(alpha: 0.3),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  asset.completedChecklistCount == asset.totalChecklistCount
                                      ? Icons.check_circle_rounded
                                      : Icons.checklist_rounded,
                                  size: 13,
                                  color: asset.completedChecklistCount == asset.totalChecklistCount
                                      ? const Color(0xFF6EE7B7)
                                      : Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${asset.completedChecklistCount}/${asset.totalChecklistCount} checklist',
                                  style: TextStyle(
                                    color: asset.completedChecklistCount == asset.totalChecklistCount
                                        ? const Color(0xFF6EE7B7)
                                        : Colors.white,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? const [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)]
              : const [Color(0xFF1E3A8A), Color(0xFF0D9488)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          _getCategoryIcon(asset.categoryId),
          size: 64,
          color: Colors.white.withValues(alpha: 0.25),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String cat) {
    switch (cat) {
      case 'vehicle':
        return Icons.directions_car_rounded;
      case 'electronics':
        return Icons.devices_rounded;
      case 'property':
        return Icons.home_work_rounded;
      case 'personal':
        return Icons.watch_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  String _getCategoryName(String cat) {
    switch (cat) {
      case 'vehicle':
        return 'Kendaraan';
      case 'electronics':
        return 'Elektronik';
      case 'property':
        return 'Properti';
      case 'personal':
        return 'Pribadi';
      default:
        return 'Lainnya';
    }
  }
}
