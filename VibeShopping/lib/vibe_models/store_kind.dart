/// Cadena de retail representada en datos.
enum VibeStoreKind {
  walmart('Walmart', 'Walmart'),
  maxiPali('MaxiPalí', 'M. Palí'),
  bm('Supermercados BM', 'BM'),
  coopeagri('CoopeAgri', 'C. Agri');

  final String displayName;
  final String shortName;
  const VibeStoreKind(this.displayName, this.shortName);
}
