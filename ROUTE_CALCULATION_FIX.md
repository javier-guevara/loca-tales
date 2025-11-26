# 🛣️ Corrección del Cálculo de Rutas - Mapbox Directions API

## 🐛 Problema Identificado

El cálculo de rutas estaba fallando debido a:

1. **DTO incorrecto**: El campo `instruction` estaba directamente en `Step`, pero en la API de Mapbox está dentro de `maneuver.instruction`
2. **Falta de validación**: No se validaba el código de respuesta de Mapbox
3. **Falta de logging**: No había logs para diagnosticar errores

## ✅ Cambios Realizados

### 1. Actualizado `directions_response_dto.dart`

**Antes**:
```dart
class Step {
  final String? instruction;  // ❌ Campo incorrecto
  final double? distance;
  final double? duration;
}
```

**Después**:
```dart
class Step {
  final Maneuver? maneuver;  // ✅ Estructura correcta
  final double? distance;
  final double? duration;
  final String? name;
}

class Maneuver {
  final String? instruction;
  final String? type;
  @JsonKey(name: 'bearing_after')
  final double? bearingAfter;
  final List<double>? location;
}
```

### 2. Actualizado `route_mapper.dart`

**Antes**:
```dart
final stepsList = route.legs
    ?.expand((leg) => leg.steps ?? [])
    .map((step) => step.instruction ?? '')  // ❌ Campo no existe
```

**Después**:
```dart
final stepsList = route.legs
    ?.expand((leg) => leg.steps ?? [])
    .map((step) => step.maneuver?.instruction ?? step.name ?? '')  // ✅ Acceso correcto
    .where((s) => s.isNotEmpty)
    .toList();
```

### 3. Mejorado `mapbox_directions_service.dart`

Agregado:
- ✅ Logging detallado de requests y responses
- ✅ Validación del código de respuesta (`code: 'Ok'`)
- ✅ Mejor manejo de errores con mensajes específicos
- ✅ Logs de errores de la API

```dart
developer.log(
  'Requesting Mapbox Directions: $url',
  name: 'MapboxDirectionsService',
);

if (response.data['code'] != 'Ok') {
  throw Exception('Mapbox error: ${response.data['code']} - ${response.data['message']}');
}
```

### 4. Regenerado archivos con build_runner

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## 🧪 Cómo Probar

### Paso 1: Ejecutar la App
```bash
flutter run
```

### Paso 2: Probar el Flujo Completo
1. Genera un plan de viaje (ej: "3 días en París")
2. Ve a "Ver en Mapa"
3. Haz clic en el botón flotante de ubicación (acepta permisos)
4. Selecciona un lugar del plan
5. Haz clic en "Cómo llegar"

### Resultado Esperado:
- ✅ Aparece DirectionsPanel con tiempo y distancia
- ✅ Se muestra la ruta en el mapa (polyline)
- ✅ Puedes cambiar el modo de transporte
- ✅ El botón "Iniciar Navegación" funciona

### Verificar Logs:
```bash
flutter run

# Busca en la consola:
[MapboxDirectionsService] Requesting Mapbox Directions: https://api.mapbox.com/directions/v5/mapbox/walking/...
[MapboxDirectionsService] Mapbox Directions response code: Ok
```

---

## 📊 Estructura de Respuesta de Mapbox Directions API

```json
{
  "code": "Ok",
  "routes": [
    {
      "distance": 1234.5,
      "duration": 567.8,
      "geometry": {
        "type": "LineString",
        "coordinates": [[lon, lat], [lon, lat], ...]
      },
      "legs": [
        {
          "distance": 1234.5,
          "duration": 567.8,
          "steps": [
            {
              "distance": 123.4,
              "duration": 56.7,
              "name": "Rue de Rivoli",
              "maneuver": {
                "instruction": "Gire a la derecha en Rue de Rivoli",
                "type": "turn",
                "bearing_after": 90,
                "location": [lon, lat]
              }
            }
          ]
        }
      ]
    }
  ]
}
```

---

## 🔍 Debugging

### Si el cálculo de ruta falla:

#### 1. Verificar Logs
```bash
flutter run

# Busca errores:
[MapboxDirectionsService] Error getting directions
[MapboxDirectionsService] Mapbox API error response: {...}
```

#### 2. Verificar Token de Mapbox
```bash
# Verifica que el token esté configurado
echo $MAPBOX_ACCESS_TOKEN

# O en el archivo .env
cat .env
```

#### 3. Verificar Coordenadas
Los logs mostrarán la URL completa:
```
https://api.mapbox.com/directions/v5/mapbox/walking/2.3522,48.8566;2.2945,48.8584
```

Verifica que:
- Las coordenadas estén en formato `lon,lat` (no `lat,lon`)
- Los valores sean válidos (-180 a 180 para lon, -90 a 90 para lat)

#### 4. Probar URL Manualmente
Copia la URL de los logs y pruébala en el navegador:
```
https://api.mapbox.com/directions/v5/mapbox/walking/2.3522,48.8566;2.2945,48.8584?access_token=TU_TOKEN&geometries=geojson&overview=full&steps=true
```

---

## 🚨 Errores Comunes

### Error: "Ruta no encontrada"
**Causa**: Los puntos están muy lejos o no hay ruta disponible
**Solución**: Verifica que los puntos estén en áreas con rutas disponibles

### Error: "Límite de solicitudes de Mapbox alcanzado"
**Causa**: Excediste el límite de requests gratuitos
**Solución**: Espera o actualiza tu plan de Mapbox

### Error: "MAPBOX_ACCESS_TOKEN no está configurada"
**Causa**: Token no configurado en .env
**Solución**: Agrega el token en `.env`:
```
MAPBOX_ACCESS_TOKEN=pk.eyJ1...
```

### Error: "The method '_$ManeuverFromJson' isn't defined"
**Causa**: No se regeneraron los archivos con build_runner
**Solución**:
```bash
flutter clean
dart run build_runner build --delete-conflicting-outputs
```

---

## 📚 Referencias

- [Mapbox Directions API](https://docs.mapbox.com/api/navigation/directions/)
- [Mapbox Response Object](https://docs.mapbox.com/api/navigation/directions/#directions-response-object)
- [Mapbox Profiles](https://docs.mapbox.com/api/navigation/directions/#routing-profiles)

---

## ✨ Próximos Pasos

- [ ] Agregar soporte para waypoints intermedios
- [ ] Implementar navegación turn-by-turn con voz
- [ ] Agregar alternativas de rutas
- [ ] Mostrar tráfico en tiempo real
- [ ] Guardar rutas favoritas

---

**¡El cálculo de rutas ahora funciona correctamente con Mapbox!** 🎉
