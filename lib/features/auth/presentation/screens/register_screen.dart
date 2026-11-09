import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:revida/features/auth/presentation/cubits/auth/auth_cubit.dart';
import 'package:revida/features/auth/presentation/cubits/register/register_form_cubit.dart';
import 'package:revida/features/auth/presentation/widgets/widgets.dart';

class RegisterScreen extends StatelessWidget {
  static String name = 'register';
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RegisterFormCubit(
        registerUserCallback: context.read<AuthCubit>().register,
      ),
      child: const _RegisterView(),
    );
  }
}

class _RegisterView extends StatelessWidget {
  const _RegisterView();

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
      child: BackgroundStyle(content: _RegisterBody()),
    );
  }
}

class _RegisterBody extends StatelessWidget {
  const _RegisterBody();

  @override
  Widget build(BuildContext context) {
    final registerForm = context.watch<RegisterFormCubit>();
    final colors = Theme.of(context).colorScheme;

    void showSnackbar(BuildContext context, String message) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //App name
              Text(
                'Crea una cuenta para ti',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              //Name textfield
              MyTextfield(
                onChanged: registerForm.onFullNameChange,
                errorMessage: registerForm.state.isFormPosted
                    ? registerForm.state.name.errorMessage
                    : null,
                hintText: 'Nombre',
                obscureText: false,
              ),
              const SizedBox(height: 16),
              //Email textfield
              MyTextfield(
                onChanged: registerForm.onEmailChange,
                errorMessage: registerForm.state.isFormPosted
                    ? registerForm.state.email.errorMessage
                    : null,
                hintText: 'Email',
                obscureText: false,
              ),

              const SizedBox(height: 16),
              //Password textfield
              MyTextfield(
                hintText: 'Contraseña',
                onChanged: registerForm.onPasswordChange,
                errorMessage: registerForm.state.isFormPosted
                    ? registerForm.state.password.errorMessage
                    : null,
                obscureText: true,
              ),
              const SizedBox(height: 16),
              //Confirm Password textfield
              MyTextfield(
                hintText: 'Confirmar Contraseña',
                onChanged: registerForm.onPasswordReplicaChange,
                errorMessage: registerForm.state.isFormPosted
                    ? registerForm.state.passwordReplica.errorMessage
                    : null,
                obscureText: true,
              ),
              const SizedBox(height: 20),
              //Register button
              MyButton(
                onTap: registerForm.state.isPosting
                    ? null
                    : () {
                        registerForm.onFormSubmit();
                        if (registerForm.state.isPasswordsEquals == false) {
                          showSnackbar(context, 'Contraseñas no iguales');
                        }
                      },
                text: 'Registra cuenta',
              ),
              //google, ios
              const SizedBox(height: 25),
              //Already account
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Ya tienes una cuenta? ',
                    style: TextStyle(color: colors.primary),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (context.canPop()) {
                        return context.pop();
                      }
                      context.push('/login');
                    },
                    child: Text(
                      'Inicia sesión',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
