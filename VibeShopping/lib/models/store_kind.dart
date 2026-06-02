/// Cadena de retail representada en datos.
enum VibeStoreKind {
  walmart('Walmart', 'Walmart'),
  maxiPali('MaxiPalí', 'M. Palí'),
  bm('Supermercados BM', 'BM'),
  coopeagri('CoopeAgri', 'C. Agri');

  final String displayName;
  final String shortName;
  const VibeStoreKind(this.displayName, this.shortName);

  String get officialLogoAsset => switch (this) {
        VibeStoreKind.walmart => 'assets/assets_logos/Walmart_logo.jpg',
        VibeStoreKind.maxiPali => 'assets/assets_logos/maxipali_logo.jpeg',
        VibeStoreKind.bm => 'assets/assets_logos/Bm_logo.png',
        VibeStoreKind.coopeagri => 'assets/assets_logos/Coopeagri_logo.png',
      };
}
