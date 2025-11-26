# 🤝 Guía de Contribución

¡Gracias por tu interés en contribuir a LocaTales! Esta guía te ayudará a empezar.

## 📋 Tabla de Contenidos

- [Código de Conducta](#código-de-conducta)
- [¿Cómo puedo contribuir?](#cómo-puedo-contribuir)
- [Proceso de Desarrollo](#proceso-de-desarrollo)
- [Guía de Estilo](#guía-de-estilo)
- [Commit Messages](#commit-messages)
- [Pull Requests](#pull-requests)

## 📜 Código de Conducta

Este proyecto se adhiere a un código de conducta. Al participar, se espera que mantengas este código. Por favor reporta comportamientos inaceptables.

## 🚀 ¿Cómo puedo contribuir?

### Reportar Bugs

Si encuentras un bug, por favor crea un issue con:

- **Título descriptivo**
- **Pasos para reproducir** el problema
- **Comportamiento esperado** vs **comportamiento actual**
- **Screenshots** si es aplicable
- **Versión de Flutter** y **dispositivo**

### Sugerir Mejoras

Las sugerencias de mejoras son bienvenidas. Por favor incluye:

- **Descripción clara** de la mejora
- **Casos de uso** específicos
- **Mockups o ejemplos** si es posible

### Tu Primera Contribución de Código

¿No sabes por dónde empezar? Busca issues etiquetados como:

- `good first issue` - Issues simples para empezar
- `help wanted` - Issues que necesitan ayuda

## 🔧 Proceso de Desarrollo

### 1. Fork y Clone

```bash
# Fork el repositorio en GitHub
# Luego clona tu fork
git clone https://github.com/TU-USUARIO/loca_tales.git
cd loca_tales
```

### 2. Configurar el Entorno

```bash
# Instalar dependencias
flutter pub get

# Generar código
flutter pub run build_runner build --delete-conflicting-outputs

# Configurar API keys (ver SETUP.md)
```

### 3. Crear una Rama

```bash
# Crea una rama desde main
git checkout -b feature/mi-nueva-feature

# O para un bugfix
git checkout -b fix/descripcion-del-bug
```

### 4. Hacer Cambios

- Escribe código limpio y bien documentado
- Sigue la guía de estilo de Dart/Flutter
- Agrega tests si es aplicable
- Actualiza la documentación si es necesario

### 5. Probar

```bash
# Ejecutar tests
flutter test

# Ejecutar análisis de código
flutter analyze

# Verificar formato
dart format --set-exit-if-changed .
```

### 6. Commit

```bash
git add .
git commit -m "feat: descripción clara del cambio"
```

### 7. Push y Pull Request

```bash
git push origin feature/mi-nueva-feature
```

Luego crea un Pull Request en GitHub.

## 🎨 Guía de Estilo

### Dart/Flutter

- Sigue las [Effective Dart Guidelines](https://dart.dev/guides/language/effective-dart)
- Usa `dart format` antes de hacer commit
- Máximo 80 caracteres por línea (flexible a 120 si es necesario)
- Usa nombres descriptivos para variables y funciones

### Arquitectura

- **Clean Architecture**: Separa Domain, Data y Presentation
- **MVVM**: Usa ViewModels para lógica de UI
- **Riverpod**: Para gestión de estado
- **Freezed**: Para modelos inmutables

### Estructura de Archivos

```
feature/
├── models/           # Modelos de dominio
├── view_model/       # Lógica de presentación
├── widgets/          # Componentes de UI
└── screens/          # Pantallas completas
```

### Nombrado

- **Archivos**: `snake_case.dart`
- **Clases**: `PascalCase`
- **Variables/Funciones**: `camelCase`
- **Constantes**: `SCREAMING_SNAKE_CASE`
- **Privados**: `_leadingUnderscore`

## 📝 Commit Messages

Usamos [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Tipos

- `feat`: Nueva funcionalidad
- `fix`: Corrección de bug
- `docs`: Cambios en documentación
- `style`: Formato, punto y coma, etc
- `refactor`: Refactorización de código
- `test`: Agregar o modificar tests
- `chore`: Tareas de mantenimiento

### Ejemplos

```bash
feat(map): add route calculation with Mapbox
fix(chat): resolve message overflow issue
docs(readme): update installation instructions
refactor(viewmodel): simplify state management
```

## 🔍 Pull Requests

### Checklist

Antes de enviar tu PR, asegúrate de:

- [ ] El código compila sin errores
- [ ] Todos los tests pasan
- [ ] El código sigue la guía de estilo
- [ ] La documentación está actualizada
- [ ] Los commits siguen el formato convencional
- [ ] No hay conflictos con `main`

### Descripción del PR

Tu PR debe incluir:

1. **Qué** cambia este PR
2. **Por qué** es necesario este cambio
3. **Cómo** se implementó
4. **Screenshots** si hay cambios visuales
5. **Testing** realizado

### Ejemplo de PR

```markdown
## Descripción
Agrega cálculo de rutas con Mapbox Directions API

## Motivación
Los usuarios necesitan ver rutas entre lugares del plan

## Cambios
- Integración con Mapbox Directions API
- UI para mostrar direcciones paso a paso
- Soporte para múltiples modos de transporte

## Screenshots
[Adjuntar capturas]

## Testing
- ✅ Probado en Android 13
- ✅ Probado en iOS 16
- ✅ Tests unitarios agregados
```

## 🧪 Testing

### Escribir Tests

```dart
// test/features/map/view_model/map_view_model_test.dart
void main() {
  group('MapViewModel', () {
    test('should calculate route successfully', () async {
      // Arrange
      final viewModel = MapViewModel(...);
      
      // Act
      await viewModel.calculateRoute(...);
      
      // Assert
      expect(viewModel.state.route, isNotNull);
    });
  });
}
```

### Ejecutar Tests

```bash
# Todos los tests
flutter test

# Test específico
flutter test test/features/map/view_model/map_view_model_test.dart

# Con cobertura
flutter test --coverage
```

## 📚 Recursos

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- [Riverpod Documentation](https://riverpod.dev/)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

## ❓ Preguntas

Si tienes preguntas, puedes:

- Abrir un issue con la etiqueta `question`
- Contactar a los mantenedores
- Revisar la documentación en [SETUP.md](SETUP.md)

---

¡Gracias por contribuir a LocaTales! 🎉
