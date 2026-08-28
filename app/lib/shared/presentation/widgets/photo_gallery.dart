import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

import '../../../l10n/app_localizations.dart';

/// Carrusel de fotos con controles pulsables además del deslizamiento — A-21
/// prohíbe cualquier acción solo por gesto, así que el `PageView` nunca es la
/// única forma de pasar de foto: siempre hay flechas y puntos que hacen lo
/// mismo con un toque.
class PhotoGallery extends StatefulWidget {
  const PhotoGallery({required this.photoUrls, super.key});

  final List<String> photoUrls;

  @override
  State<PhotoGallery> createState() => _PhotoGalleryState();
}

class _PhotoGalleryState extends State<PhotoGallery> {
  late final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.photoUrls.isEmpty) return const SizedBox.shrink();

    final AppLocalizations l10n = AppLocalizations.of(context);
    final int total = widget.photoUrls.length;
    final bool showControls = total > 1;

    return Semantics(
      liveRegion: true,
      label: l10n.galleryPhotoOfTotal(_currentPage + 1, total),
      child: ClipRRect(
        borderRadius: AppRadius.lgAll,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            SizedBox(
              height: 220,
              child: PageView.builder(
                controller: _controller,
                itemCount: total,
                onPageChanged: (int index) =>
                    setState(() => _currentPage = index),
                itemBuilder: (BuildContext context, int index) =>
                    CachedNetworkImage(
                      imageUrl: widget.photoUrls[index],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorWidget: (_, _, _) => const ColoredBox(
                        color: Colors.black12,
                        child: Icon(Icons.storefront_outlined),
                      ),
                    ),
              ),
            ),
            if (showControls) ...<Widget>[
              Positioned(
                left: AppSpacing.xs,
                child: _NavButton(
                  icon: Icons.chevron_left,
                  label: l10n.galleryPrevious,
                  onPressed: _currentPage == 0 ? null : _goToPrevious,
                ),
              ),
              Positioned(
                right: AppSpacing.xs,
                child: _NavButton(
                  icon: Icons.chevron_right,
                  label: l10n.galleryNext,
                  onPressed: _currentPage == total - 1 ? null : _goToNext,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    for (int index = 0; index < total; index++)
                      _DotButton(
                        selected: index == _currentPage,
                        label: l10n.galleryGoToPhoto(index + 1, total),
                        onPressed: () => _goToPage(index),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _goToPrevious() => _goToPage(_currentPage - 1);

  void _goToNext() => _goToPage(_currentPage + 1);

  void _goToPage(int index) {
    _controller.animateToPage(
      index,
      duration: AppMotion.normal,
      curve: AppMotion.standard,
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: IconButton.filled(
        onPressed: onPressed,
        icon: Icon(icon),
        style: IconButton.styleFrom(
          backgroundColor: Colors.black45,
          disabledBackgroundColor: Colors.black12,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}

class _DotButton extends StatelessWidget {
  const _DotButton({
    required this.selected,
    required this.label,
    required this.onPressed,
  });

  final bool selected;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    // El punto visible mide 8dp, pero el área pulsable cumple el mínimo de
    // 48dp (A-20) aunque no se vea entera — un vecino con el dedo grande no
    // necesita acertar en un punto diminuto.
    return Semantics(
      button: true,
      label: label,
      selected: selected,
      child: SizedBox(
        width: AppSize.minTouchTarget,
        height: AppSize.minTouchTarget,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: Center(
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? Colors.white : Colors.white38,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
