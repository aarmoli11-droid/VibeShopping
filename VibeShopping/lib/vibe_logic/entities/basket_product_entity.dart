/// Entidad de dominio — producto de canasta básica (solo informativo).
class BasketProductEntity {
  const BasketProductEntity({
    required this.id,
    required this.name,
    this.category,
    this.referenceUnit,
    this.notes,
  });

  final String id;
  final String name;
  final String? category;
  final String? referenceUnit;
  final String? notes;
}
