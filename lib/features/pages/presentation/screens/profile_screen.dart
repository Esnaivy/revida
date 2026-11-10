import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:revida/config/theme/app_colors.dart';
import 'package:revida/config/theme/theme_controller.dart';
import 'package:revida/features/auth/presentation/cubits/auth/auth_cubit.dart';

import 'package:revida/features/pages/presentation/cubits/image_db_revida/image_db_revida_cubit.dart';

class ProfileScreen extends StatelessWidget {
  static String name = 'profile';
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: user == null
              ? const [Text('No hay usuario autenticado')]
              : [
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.tint(context),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: user.photoURL != null
                              ? NetworkImage(user.photoURL!)
                              : AssetImage('assets/user.png'),
                        ),

                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.displayName ?? 'Sin nombre',
                              style: textTheme.bodyLarge!.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(user.email ?? 'Sin email'),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Apariencia',
                      style: textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<ThemeMode>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.system,
                        label: Text('Sistema'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.light,
                        label: Text('Claro'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        label: Text('Oscuro'),
                      ),
                    ],
                    selected: {ThemeScope.of(context).mode},
                    onSelectionChanged: (selection) {
                      ThemeScope.of(context).setMode(selection.first);
                    },
                  ),
                  const SizedBox(height: 28),
                  _BotonAdvertencia(
                    textContent: 'Borrar data',
                    icon: Icons.delete,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (dialogContext) => AlertDialog.adaptive(
                          title: const Text('Borrar data'),
                          content: const Text(
                            '¿Seguro que deseas borrar tu data?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () async {
                                Navigator.pop(dialogContext);

                                await context.read<ImageDbRevidaCubit>().borrarData();

                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Data eliminada correctamente'),
                                    ),
                                  );
                                }
                              },
                              child: const Text(
                                'Aceptar',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _BotonAdvertencia(
                    textContent: 'Cerrar sesión',
                    icon: Icons.logout_rounded,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (dialogContext) => AlertDialog.adaptive(
                          title: const Text('Cerrar sesión'),
                          content: const Text(
                            '¿Seguro que deseas cerrar sesión?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(dialogContext);
                                context.read<AuthCubit>().logout();
                              },
                              child: const Text(
                                'Cerrar sesión',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
        ),
      ),
    );
  }
}

class _BotonAdvertencia extends StatelessWidget {
  const _BotonAdvertencia({
    required this.textContent,
    required this.icon,
    this.onTap,
  });

  final String textContent;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: const Color.fromARGB(66, 192, 192, 192),
          borderRadius: BorderRadius.circular(30),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color.fromARGB(49, 158, 158, 158),
                  child: Icon(
                    icon,
                    size: 32,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  textContent,
                  style: textTheme.titleMedium!.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
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
