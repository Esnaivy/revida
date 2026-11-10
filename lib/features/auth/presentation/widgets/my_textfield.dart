import 'package:flutter/material.dart';
import 'package:revida/config/theme/app_colors.dart';

class MyTextfield extends StatelessWidget {
  final String? errorMessage;
  final String hintText;
  final bool obscureText;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final Function(String)? onFieldSubmitted;

  const MyTextfield({
    super.key,
    required this.hintText,
    required this.obscureText, 
    this.errorMessage, 
    this.validator, 
    this.onChanged, 
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: obscureText,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      decoration: InputDecoration(
        // Fondo gris muy claro para contrastar suavemente con la tarjeta blanca
        fillColor: AppColors.inset(context), 
        filled: true,
        
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.grey.shade500, 
          fontWeight: FontWeight.w400
        ),
        
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),

        // Borde transparente cuando no está seleccionado (look moderno)
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.transparent),
          borderRadius: BorderRadius.circular(16), // Curva coincidente con el botón
        ),

        // Borde verde esmeralda al escribir
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF10B981), width: 1.5),
          borderRadius: BorderRadius.circular(16),
        ),

        errorText: errorMessage,
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.redAccent),
          borderRadius: BorderRadius.circular(16),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}