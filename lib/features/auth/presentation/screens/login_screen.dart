import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:revida/features/auth/presentation/cubits/auth/auth_cubit.dart';
import 'package:revida/features/auth/presentation/cubits/login/login_form_cubit.dart';
import 'package:revida/features/auth/presentation/widgets/widgets.dart';

class LoginScreen extends StatelessWidget {
  static String name = 'login';
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginFormCubit(
        loginUserCallback: context.read<AuthCubit>().login,
        forgetSubmitCallback: context.read<AuthCubit>().forgotPassword,
      ),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatelessWidget {
  const _LoginView();

  @override
  Widget build(BuildContext context) {
    void showSnackbar(String message) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          showSnackbar(state.message);
        }
      },
      child: BackgroundStyle(content: _LoginBody()),
    );
  }
}

void openForgetPasswordBox(BuildContext context) {
  final loginForm = context.read<LoginFormCubit>();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Forgot Password?'),
      content: MyTextfield(
        hintText: 'Enter Email...',
        obscureText: false,
        onChanged: loginForm.onForgetPassword,
        errorMessage: loginForm.state.isFormPosted
            ? loginForm.state.email.errorMessage
            : null,
      ),
      actions: [
        TextButton(onPressed: () => context.pop(), child: const Text('Cancel')),
        TextButton(
          onPressed: () async {
            String message = await loginForm.forgetPasswordSubmit(
              loginForm.state.emailForgetPassword != null
                  ? loginForm.state.emailForgetPassword!.value
                  : '',
            );

            if (message == 'Password reset email! Check your inbox.') {
              if (!context.mounted) return;
              context.pop();
            }

            if (!context.mounted) return;
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
          },
          child: const Text('Restablecer'),
        ),
      ],
    ),
  );
}

class _LoginBody extends StatelessWidget {
  const _LoginBody();

  @override
  Widget build(BuildContext context) {
    final loginForm = context.watch<LoginFormCubit>();
    final authCubit = context.watch<AuthCubit>();

    const colorTextoAcento = Color(0xFF1B5E20);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/revida_new_logo.png', height: 92),
          const SizedBox(height: 20),
          MyTextfield(
            onChanged: loginForm.onEmailChange,
            errorMessage: loginForm.state.isFormPosted
                ? loginForm.state.email.errorMessage
                : null,
            hintText: 'Email',
            obscureText: false,
          ),
          const SizedBox(height: 16),
          MyTextfield(
            hintText: 'Contraseña',
            onChanged: loginForm.onPasswordChange,
            errorMessage: loginForm.state.isFormPosted
                ? loginForm.state.password.errorMessage
                : null,
            onFieldSubmitted: (_) => loginForm.onFormSubmit(),
            obscureText: true,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => openForgetPasswordBox(context),
                child: Text(
                  'Olvidé mi contraseña',
                  style: TextStyle(
                    color: colorTextoAcento,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          MyButton(
            onTap: () {
              loginForm.state.isPosting ? null : loginForm.onFormSubmit();
            },
            text: 'Ingresar',
          ),
          const SizedBox(height: 20),

          MyButton(
            imageAsset: 'assets/google_logo.png',
            onTap: () => authCubit.signInWithGoogle(),
            text: 'Inicia sesión con Google',
          ),
          const SizedBox(height: 25),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '¿No tienes una cuenta? ',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              GestureDetector(
                onTap: () => context.push('/register'),
                child: Text(
                  'Regístrate aquí',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorTextoAcento,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

