# Finanzas Móviles - Gestión y Onboarding

Segunda fase del proyecto "Finanzas Móviles". Se ha implementado un flujo completo de bienvenida y un sistema de registro robusto con validaciones avanzadas bajo estándares de accesibilidad.

## 🚀 Nuevas Implementaciones (Semana 8)

### 1. Flujo de Onboarding
- Implementación de **PageView** con 3 pantallas informativas.
- Navegación controlada con opciones de "Saltar" y "Siguiente".
- Redirección inteligente al formulario de registro.

### 2. Validaciones Complejas y Accesibilidad
- **Validación de Formato:** Uso de `RegExp` para correos y bloqueo de caracteres numéricos en nombres mediante `inputFormatters`.
- **Validación Cruzada:** Comparación en tiempo real de contraseñas (Password match).
- **Feedback Accesible:** Mensajes de error claros que no dependen únicamente del color, integrando iconos y texto descriptivo (WCAG 2.2).
- **Controladores:** Gestión de estado mediante `TextEditingController` con limpieza de memoria activa (`dispose`).

### 3. Persistencia y Seguridad
- Las validaciones aseguran que solo datos íntegros se almacenen en la base de datos **SQLite**.
- Uso de **Debounce** para optimizar las validaciones asíncronas de campos únicos.

---

## 🏗️ Arquitectura
El proyecto sigue los principios de **Clean Architecture** y el patrón **MVI**, separando las responsabilidades de datos, lógica de negocio y UI.

## 🛠️ Instalación y Uso
1. Asegúrese de tener el archivo `.env` configurado.
2. Ejecute `flutter pub get` para instalar Riverpod y las nuevas dependencias de validación.
3. Inicie el simulador y ejecute `flutter run`.

---
**Desarrollado por:** Santiago
**Curso:** Desarrollo de Aplicaciones Móviles - 2026