# Changelog

Todos los cambios notables de este proyecto serán documentados en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.0.0/),
y este proyecto adhiere a [Semantic Versioning](https://semver.org/lang/es/).

## [Unreleased]

### Agregado
- Pantalla de inicio rediseñada con gradientes y diseño moderno
- Sugerencias de viaje adaptadas a la ubicación del usuario
- Detección automática de ciudad (Barranquilla, Cartagena, Bogotá)
- Validación de distancia para rutas (límite 500km)
- Navegación externa con fallbacks (Mapbox → Google Maps → Apple Maps)
- Botones de cerrar en todos los paneles y mensajes de error
- Sugerencias rápidas mejoradas con emojis en el chat
- Logs detallados para debugging de rutas

### Cambiado
- Eliminado botón "Iniciar Chat" de la pantalla principal
- Mejorada la UI del HomeScreen con tarjetas interactivas
- Actualizado el sistema de sugerencias para ser más descriptivo
- Cambiados los logs de `developer.log` a `print` para mejor visibilidad

### Corregido
- Error 422 al calcular rutas intercontinentales
- Problema con coordenadas en formato incorrecto para Mapbox
- Overflow en cards de respuesta del chat
- Botones de cerrar que no funcionaban correctamente
- Parsing de respuesta de Mapbox Directions API

## [0.1.0] - 2024-11-25

### Agregado
- Integración inicial con Google Gemini AI
- Chat conversacional para crear planes de viaje
- Integración con Mapbox Maps para visualización
- Cálculo de rutas con Mapbox Directions API
- Soporte para múltiples modos de transporte
- Detalle de planes de viaje por día
- Arquitectura Clean con MVVM
- Gestión de estado con Riverpod
- Soporte para modo oscuro
- Permisos de ubicación en Android e iOS
- Configuración de flavors (development, staging, production)

### Características Iniciales

#### Chat con IA
- Generación de planes de viaje personalizados
- Parsing de respuestas estructuradas de Gemini
- Manejo de errores y reintentos
- Historial de conversación

#### Mapas
- Visualización de lugares en mapa interactivo
- Marcadores personalizados por categoría
- Cámara con animaciones fluidas
- Ubicación del usuario en tiempo real

#### Navegación
- Rutas calculadas con Mapbox
- Panel de direcciones con instrucciones
- Cambio de modo de transporte
- Integración con apps de navegación externas

#### UI/UX
- Material Design 3
- Tema claro y oscuro
- Animaciones y transiciones
- Responsive design

## [0.0.1] - 2024-11-01

### Agregado
- Configuración inicial del proyecto Flutter
- Estructura de carpetas con Clean Architecture
- Configuración de dependencias principales
- Setup de Riverpod para gestión de estado
- Configuración de go_router para navegación
- Setup de build_runner y code generation

---

## Tipos de Cambios

- `Agregado` para nuevas funcionalidades
- `Cambiado` para cambios en funcionalidades existentes
- `Deprecado` para funcionalidades que serán removidas
- `Removido` para funcionalidades removidas
- `Corregido` para corrección de bugs
- `Seguridad` para vulnerabilidades

## Enlaces

- [Unreleased]: Cambios no publicados aún
- [0.1.0]: Primera versión funcional
- [0.0.1]: Setup inicial del proyecto
