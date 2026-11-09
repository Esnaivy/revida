## Firebase

Revida es una app **solo Android** conectada al proyecto Firebase **`revida-bbadb`** (número de proyecto `380496289978`).

| | |
| --- | --- |
| Proyecto | `revida-bbadb` |
| App Android | `1:380496289978:android:ff184e5034267b92ada283` |
| Package | `app.marcomendez.revida` |
| Config nativa | `android/app/google-services.json` |
| Config Dart | `lib/firebase_options.dart` (solo Android; el resto de plataformas lanza `UnsupportedError`) |

No hay apps de iOS, web, macOS ni Windows en este proyecto. El alias por defecto del CLI está en `.firebaserc`.

### Auth

La app usa Firebase Authentication con **correo/contraseña** y **Google Sign-In**.

Google Sign-In en Android toma el cliente OAuth web (`client_type` 3) de `google-services.json` a través del plugin `com.google.gms.google-services`. Ese cliente ya está en el archivo:

`380496289978-u7s3ch4k9nnlp5uoed223bh3v2ugplmc.apps.googleusercontent.com`

Para que el inicio de sesión con Google funcione en un dispositivo, en la consola de Firebase hay que:

1. Activar los proveedores **Email/Password** y **Google** en Authentication.
2. Registrar las huellas **SHA-1** y **SHA-256** del keystore con el que firmas la app (Project settings → tu app Android → Add fingerprint). El `google-services.json` actual no incluye un cliente OAuth Android (`client_type` 1), así que falta esa huella. El build de release de este repo firma con el keystore de debug.
3. Volver a descargar `google-services.json` después de añadir las huellas y reemplazar `android/app/google-services.json`.

### Firestore

Reglas: `firestore.rules`. Índices: `firestore.indexes.json`.

- `residuos`: cada usuario autenticado solo lee y escribe documentos con `userId == request.auth.uid`. El historial, las estadísticas y la racha se calculan en el dispositivo a partir de esa consulta (`where userId == uid`, `orderBy date` descendente).
- `contenedores`: datos de referencia. Cualquier usuario autenticado puede leerlos; la app no los escribe. Hay que cargarlos desde la consola de Firebase o el Admin SDK.

Publicar reglas e índices (después de `firebase login`):

```bash
firebase deploy --only firestore
```

### Ejecutar

```bash
flutter pub get
flutter run
```
