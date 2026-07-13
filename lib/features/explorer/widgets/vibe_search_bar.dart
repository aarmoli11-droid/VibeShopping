// ======================================================
// Archivo: features/explorer/widgets/vibe_search_bar.dart
// Responsabilidad: Barra de búsqueda de productos
// Qué hace: Renderiza un TextField con icono de lupa y
//   borde verde menta. El controller se conecta al state
//   de MarketExplorerView para filtrar en tiempo real
// Quién lo utiliza: MarketExplorerView (dentro del
//   SliverAppBar)
//
// Concepto: TextEditingController
//   Objeto que controla el contenido de un TextField.
//   Se pasa desde el padre para que el padre pueda leer
//   el texto (filtrar productos) o modificarlo (limpiar
//   después de enviar). El padre se suscribe a cambios
//   con addListener(() => setState(...)) para actualizar
//   la UI en cada tecla
// ======================================================

import 'package:flutter/material.dart';
import '../../../core/vibe_constants.dart';

class VibeSearchBar extends StatelessWidget {
  const VibeSearchBar({
    super.key,
    required this.controller,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      cursorColor: VibeColors.navy,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        isDense: true,
        hintText: 'Buscar productos',
        hintStyle: const TextStyle(
          color: Colors.black,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: const Icon(
          Icons.search,
          color: Colors.black,
          size: 22,
        ),
        filled: true,
        fillColor: VibeColors.backgroundWhite,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 12,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: VibeColors.mint,
            width: 1.35,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: VibeColors.mint,
            width: 1.75,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: VibeColors.mint,
            width: 1.35,
          ),
        ),
      ),
    );
  }
}
