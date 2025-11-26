# 🗺️ Configuración de Navegación - Mapbox y Apps Externas

## 📱 Android - Configuración de AndroidManifest.xml

Para que el botón "Iniciar Navegación" funcione correctamente, necesitas agregar las siguientes configuraciones:

### 1. Permisos de Ubicación

Abre `android/app/src/main/AndroidManifest.xml` y agrega dentro de `<manifest>`:

```xml
<!-- Permisos de ubicación -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
```

### 2. Queries para Apps Externas (Android 11+)

Agrega dentro de `<manifest>` (antes de `<application>`):

```xml
<!-- Queries para verificar apps instaladas -->
<queries>
    <!-- Mapbox Navigation -->
    <intent>
        <action android:name="android.intent.action.VIEW" />
        <data android:scheme="mapbox" />
    </intent>
    
    <!-- Google Maps -->
    <intent>
        <action android:name="android.intent.action.VIEW" />
        <data android:scheme="https" android:host="www.google.com" />
    </intent>
    
    <!-- Navegador web genérico -->
    <intent>
        <action android:name="android.intent.action.VIEW" />
        <data android:scheme="https" />
    </intent>
</queries>
```

### Ejemplo Completo de AndroidManifest.xml

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    
    <!-- Permisos -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    
    <!-- Queries para Android 11+ -->
    <queries>
        <intent>
            <action android:name="android.intent.action.VIEW" />
            <data android:scheme="mapbox" />
        </intent>
        <intent>
            <action android:name="android.intent.action.VIEW" />
            <data android:scheme="https" android:host="www.google.com" />
        </intent>
        <intent>
            <action android:name="android.intent.action.VIEW" />
            <data android:scheme="https" />
        </intent>
        <intent>
            <action android:name="android.intent.action.VIEW" />
            <data android:scheme="http" />
        </intent>
    </queries>

    <application
        android:label="loca_tales"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        
        <!-- Resto de la configuración... -->
        
    </application>
</manifest>
```

---

## 🍎 iOS - Configuración de Info.plist

Abre `ios/Runner/Info.plist` y agrega:

### 1. Permisos de Ubicación

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Necesitamos tu ubicación para mostrarte direcciones a los lugares</string>

<key>NSLocationAlwaysUsageDescription</key>
<string>Necesitamos tu ubicación para mostrarte direcciones a los lugares</string>
```

### 2. URL Schemes para Apps Externas

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>mapbox</string>
    <string>comgooglemaps</string>
    <string>maps</string>
</array>
```

### Ejemplo Completo de Info.plist

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- Configuración existente... -->
    
    <!-- Permisos de ubicación -->
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>Necesitamos tu ubicación para mostrarte direcciones a los lugares</string>
    
    <key>NSLocationAlwaysUsageDescription</key>
    <string>Necesitamos tu ubicación para mostrarte direcciones a los lugares</string>
    
    <!-- URL Schemes -->
    <key>LSApplicationQueriesSchemes</key>
    <array>
        <string>mapbox</string>
        <string>comgooglemaps</string>
        <string>maps</string>
    </array>
    
    <!-- Resto de la configuración... -->
</dict>
</plist>
```

---

## 🔧 Cómo Funciona el Botón "Iniciar Navegación"

El sistema intenta abrir las apps en este orden:

### 1. **Mapbox Navigation** (Preferido)
- URL: `mapbox://navigation?destination=lon,lat&name=PlaceName`
- Requiere: App Mapbox instalada
- Beneficio: Navegación integrada con Mapbox

### 2. **Google Maps** (Fallback)
- URL: `https://www.google.com/maps/dir/?api=1&destination=lat,lon`
- Funciona en navegador si no está instalada la app
- Compatible con Android e iOS

### 3. **Apple Maps** (iOS Fallback)
- URL: `http://maps.apple.com/?daddr=lat,lon&dirflg=d`
- Solo iOS
- Navegación nativa de Apple

---

## 🧪 Cómo Probar

### Paso 1: Aplicar Configuraciones
```bash
# Después de modificar AndroidManifest.xml e Info.plist
flutter clean
flutter pub get
```

### Paso 2: Ejecutar en Dispositivo Real
```bash
# Android
flutter run --release

# iOS
flutter run --release
```

**⚠️ IMPORTANTE**: La navegación debe probarse en dispositivos reales, no en simuladores.

### Paso 3: Probar el Flujo
1. Abre la app
2. Genera un plan de viaje
3. Ve al mapa
4. Haz clic en el botón flotante de ubicación (acepta permisos)
5. Selecciona un lugar
6. Haz clic en "Cómo llegar"
7. Haz clic en "Iniciar Navegación"

**Resultado esperado**:
- Si tienes Mapbox instalada → Abre Mapbox Navigation
- Si no → Abre Google Maps (app o navegador)
- En iOS sin Google Maps → Abre Apple Maps

---

## 🐛 Troubleshooting

### Problema: "No se puede abrir la URL"

**Solución Android**:
1. Verifica que agregaste las `<queries>` en AndroidManifest.xml
2. Ejecuta `flutter clean` y `flutter pub get`
3. Desinstala la app completamente y reinstala

**Solución iOS**:
1. Verifica que agregaste `LSApplicationQueriesSchemes` en Info.plist
2. Ejecuta `flutter clean` y `cd ios && pod install`
3. Desinstala la app completamente y reinstala

### Problema: "Permisos de ubicación denegados"

**Solución**:
1. Ve a Configuración del dispositivo
2. Busca la app "loca_tales"
3. Habilita permisos de ubicación
4. Reinicia la app

### Problema: "Botón no hace nada"

**Solución**:
1. Abre la consola de debug: `flutter run`
2. Busca errores en los logs
3. Verifica que `url_launcher` esté instalado: `flutter pub get`
4. Verifica que las configuraciones nativas estén correctas

---

## 📦 Alternativa: Usar Mapbox Directions API Directamente

Si prefieres mantener la navegación dentro de la app (sin abrir apps externas), puedes usar Mapbox Directions API para mostrar la ruta en el mapa:

```dart
// Ya implementado en MapViewModel.getDirectionsToPlace()
// Muestra la ruta en el mapa con polyline
// Usuario puede seguir la ruta visualmente
```

**Ventajas**:
- Todo dentro de la app
- Control total de la UI
- No requiere apps externas

**Desventajas**:
- No tiene navegación turn-by-turn con voz
- Usuario debe seguir la ruta manualmente

---

## 🎯 Recomendación

Para la mejor experiencia:

1. **Mostrar la ruta en el mapa** (ya implementado)
2. **Ofrecer botón para navegación externa** (ya implementado)
3. **Agregar navegación turn-by-turn en el futuro** (requiere Mapbox Navigation SDK)

---

## 📚 Referencias

- [Mapbox Navigation SDK](https://docs.mapbox.com/android/navigation/guides/)
- [url_launcher Package](https://pub.dev/packages/url_launcher)
- [Android Queries](https://developer.android.com/training/package-visibility)
- [iOS URL Schemes](https://developer.apple.com/documentation/uikit/inter-process_communication/allowing_apps_and_websites_to_link_to_your_content)

---

¿Necesitas ayuda con alguna configuración específica?
