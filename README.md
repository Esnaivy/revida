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

El código pide el ID token con ese cliente web. `google-services.json` también incluye el cliente Android (`client_type` 1) de la huella de debug `8cef88a0cda63d113d4df74edc805617d0e3b540`. Google Sign-In funciona cuando la app se instala desde la computadora que tiene ese keystore.

Si firmas desde otra computadora, Play Services responde `ApiException: 10`. Agrega el SHA-1 y el SHA-256 de ese otro keystore en la app Android, descarga de nuevo `google-services.json` y reemplaza `android/app/google-services.json`.

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
