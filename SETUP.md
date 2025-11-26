# Guía de Configuración - Travel AI Planner

## Configuración de API Keys

### 1. Obtener API Keys

#### Google Gemini API Key
1. Visita [Google AI Studio](https://aistudio.google.com/)
2. Inicia sesión con tu cuenta de Google
3. Crea una nueva API key
4. Copia la clave generada

#### Mapbox Access Token
1. Visita [Mapbox](https://www.mapbox.com/)
2. Crea una cuenta o inicia sesión
3. Ve a [Account Settings > Access Tokens](https://account.mapbox.com/access-tokens/)
4. Crea un nuevo token o copia uno existente
5. Asegúrate de que el token tenga los siguientes scopes:
   - `styles:read`
   - `fonts:read`
   - `datasets:read`
   - `vision:read`
   - `tilesets:read`

### 2. Configurar Variables de Entorno

Crea los siguientes archivos en la raíz del proyecto:

#### `.env.development`
```env
ENVIRONMENT=development
MAPBOX_ACCESS_TOKEN=tu_token_de_mapbox_aqui
GEMINI_API_KEY=tu_clave_de_gemini_aqui
API_BASE_URL=
```

#### `.env.staging`
```env
ENVIRONMENT=staging
MAPBOX_ACCESS_TOKEN=tu_token_de_mapbox_aqui
GEMINI_API_KEY=tu_clave_de_gemini_aqui
API_BASE_URL=
```

#### `.env.production`
```env
ENVIRONMENT=production
MAPBOX_ACCESS_TOKEN=tu_token_de_mapbox_aqui
GEMINI_API_KEY=tu_clave_de_gemini_aqui
API_BASE_URL=
```

**⚠️ IMPORTANTE:** Nunca commitees estos archivos al repositorio. Están en `.gitignore` por defecto.

### 3. Configurar Mapbox en Android

#### 3.1 Token en strings.xml

Edita el archivo `android/app/src/main/res/values/strings.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="mapbox_access_token">TU_TOKEN_DE_MAPBOX_AQUI</string>
</resources>
```

#### 3.2 SDK Registry Token (REQUERIDO)

**IMPORTANTE**: Mapbox requiere un token con scope `Downloads:Read` para descargar el SDK.

Edita el archivo `android/gradle.properties` y agrega:

```properties
SDK_REGISTRY_TOKEN=TU_SECRET_TOKEN_DE_MAPBOX_AQUI
```

**Nota**: Este debe ser un **SECRET token** (no público) con el scope `Downloads:Read`. Puedes crearlo en [Mapbox Account Settings](https://account.mapbox.com/access-tokens/).

### 4. Configurar Mapbox en iOS

Edita el archivo `ios/Runner/Info.plist` y reemplaza `YOUR_MAPBOX_ACCESS_TOKEN` con tu token real:

```xml
<key>MGLMapboxAccessToken</key>
<string>TU_TOKEN_DE_MAPBOX_AQUI</string>
```

## Ejecutar la Aplicación

### Desarrollo
```bash
flutter run --flavor development -t lib/main_development.dart
```

### Staging
```bash
flutter run --flavor staging -t lib/main_staging.dart
```

### Producción
```bash
flutter run --flavor production -t lib/main.dart
```

## Generar Código

Después de hacer cambios en modelos o providers, ejecuta:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Para modo watch (desarrollo):

```bash
flutter pub run build_runner watch
```

## Estructura del Proyecto

```
lib/
├── config/          # Configuración (environment, theme, constants)
├── domain/          # Lógica de negocio (modelos, repositorios, use cases)
├── data/            # Implementación de datos (DTOs, servicios, repositorios)
├── ui/              # Interfaz de usuario (screens, widgets, view models)
└── routing/         # Configuración de navegación
```

## Troubleshooting

### Error: "GEMINI_API_KEY no está configurada"
- Verifica que el archivo `.env` correspondiente existe
- Verifica que la variable `GEMINI_API_KEY` está definida
- Asegúrate de ejecutar con el flavor correcto

### Error: "MAPBOX_ACCESS_TOKEN no está configurada"
- Verifica que el archivo `.env` correspondiente existe
- Verifica que la variable `MAPBOX_ACCESS_TOKEN` está definida
- Verifica la configuración en `strings.xml` (Android) e `Info.plist` (iOS)

### El mapa no se muestra
- Verifica que el token de Mapbox es válido
- Verifica los permisos de ubicación en Android/iOS
- Revisa los logs para errores específicos

## Próximos Pasos

1. ✅ Configurar API keys
2. ⏳ Probar la generación de planes de viaje
3. ⏳ Probar la visualización en el mapa
4. ⏳ Ajustar la integración de Mapbox según la versión
5. ⏳ Agregar tests unitarios
6. ⏳ Optimizaciones de rendimiento


