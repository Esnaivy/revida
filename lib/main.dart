import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:revida/config/router/app_router.dart';
import 'package:revida/config/theme/theme_controller.dart';
import 'package:revida/features/auth/infrastructure/datasources/auth_datasource_impl.dart';
import 'package:revida/features/auth/infrastructure/repositories/auth_repository_impl.dart';
import 'package:revida/features/auth/presentation/cubits/auth/auth_cubit.dart';
import 'package:revida/features/pages/infrastructure/datasources/revida_datasource_impl.dart';
import 'package:revida/features/pages/infrastructure/datasources/save_image_datasource_impl.dart';
import 'package:revida/features/pages/infrastructure/repositories/image_db_revida_repository_impl.dart';
import 'package:revida/features/pages/presentation/cubits/image_db_revida/image_db_revida_cubit.dart';
import 'package:revida/firebase_options.dart';

void main() async {
  //firebase setup
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final datasource = AuthDatasourceImpl();
  final repository = AuthRepositoryImpl(datasource: datasource);

  final revidaDatasource = RevidaDatasourceImpl();
  final saveImageDatasource = SaveImageDatasourceImpl();
  final imageDbRevidaRepositoy = ImageDbRevidaRepositoryImpl(
    imageDatasource: saveImageDatasource,
    revidaDatasource: revidaDatasource,
  );

  final themeController = ThemeController();

  runApp(
    ThemeScope(
      controller: themeController,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthCubit(authRepo: repository)..checkAuth(),
          ),
          BlocProvider(
            create: (context) =>
                ImageDbRevidaCubit(imageDbRevidaRepositoy)..loadReciclajes(),
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}
