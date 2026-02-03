# Finanzas Móviles - Sistema de Gestión de Gastos

Este proyecto es una aplicación móvil desarrollada en **Flutter** que permite la gestión de finanzas personales, cumpliendo con los requisitos de arquitectura limpia, persistencia de datos local y manejo de roles de usuario.

## 🚀 Características del Proyecto

- **Registro de Usuarios:** Selección de roles (Administrador / Usuario Estándar).
- **Autenticación Real:** Validación de credenciales mediante base de datos local.
- **Persistencia de Datos:** Uso de SQLite para el almacenamiento de información.
- **Gestión de Entorno:** Configuración de variables globales mediante archivos `.env`.
- **Arquitectura:** Implementación de **Clean Architecture** y patrón **MVI** (Model-View-Intent).

---

## 🛠️ Stack Tecnológico

| Herramienta | Uso |
|:--- |:--- |
| **Flutter/Dart** | Framework de desarrollo UI |
| **SQLite (sqflite)** | Base de Datos local (Persistencia) |
| **flutter_dotenv** | Gestión de variables de entorno |
| **Material 3** | Sistema de diseño de la interfaz |

---

## 🏗️ Arquitectura y Patrones

El proyecto se divide en capas para asegurar la escalabilidad y el mantenimiento:

1. **Capa de Dominio (`lib/domain`):** Contiene las entidades (`Usuario`, `Gasto`) y la lógica de negocio pura.
2. **Capa de Datos (`lib/data`):** Implementación de repositorios y gestión de la base de datos local con `DatabaseHelper`.
3. **Capa de Presentación (`lib/presentation`):** Pantallas (Screens) y manejo de estados (MVI).



---

## ⚙️ Configuración del Entorno

Para ejecutar este proyecto, es necesario configurar las variables de entorno:

1. Crear un archivo `.env` en la raíz del proyecto.
2. Definir las siguientes variables:
   ```env
   APP_NAME=Finanzas Pro
   DB_NAME=finanzas_moviles.db
   DEBUG_MODE=true