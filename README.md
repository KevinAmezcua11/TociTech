<div align="center">

<img src="./documentation/assets/Logo-img.png" width="80"/>

# TociTech

### Sistema Full Stack multiplataforma desarrollado con Flutter, Node.js y React

Aplicación enfocada en la gestión de productos, servicios, pedidos y administración mediante una arquitectura moderna cliente-servidor.

</div>

---

# 📖 Descripción

TociTech es un proyecto Full Stack compuesto por:

- 📱 Aplicación móvil desarrollada en Flutter
- ⚙️ Backend API REST desarrollado con Node.js y Express
- 💻 Panel administrativo web desarrollado con React y Vite

El sistema permite administrar productos, servicios, pedidos y usuarios, además de integrar servicios externos como Stripe, Firebase, Gemini AI y SendGrid.

---

# 🎯 Objetivos del Proyecto

- Desarrollar una aplicación multiplataforma utilizando Flutter
- Implementar una arquitectura Full Stack moderna
- Consumir y desarrollar APIs REST
- Implementar autenticación segura mediante JWT
- Integrar servicios externos
- Implementar persistencia local con SQLite
- Desarrollar un panel administrativo web
- Aplicar buenas prácticas de seguridad y organización

---

# 🛠️ Tecnologías Utilizadas

## 📱 Aplicación móvil (Flutter)

### Framework y lenguaje
- Flutter
- Dart

### Dependencias utilizadas
- http
- shared_preferences
- sqflite
- path
- cached_network_image
- flutter_stripe
- cupertino_icons

---

## ⚙️ Backend (Node.js)

### Tecnologías principales
- Node.js
- Express.js

### Dependencias utilizadas
- @google/generative-ai
- @sendgrid/mail
- bcrypt
- bcryptjs
- cors
- dotenv
- express-rate-limit
- firebase-admin
- jsonwebtoken
- stripe

### Dependencias de desarrollo
- nodemon

---

## 💻 Panel Administrativo Web

### Tecnologías principales
- React
- Vite
- JavaScript

### Dependencias utilizadas
- axios
- firebase
- lucide-react
- react
- react-dom
- react-router-dom
- recharts

### Herramientas de desarrollo
- eslint
- tailwindcss
- postcss
- autoprefixer
- @vitejs/plugin-react

---

# ☁️ Servicios Externos Integrados

- 🔥 Firebase
- 🤖 Gemini AI
- 💳 Stripe
- 📧 SendGrid

---

# 🏗️ Arquitectura General

```txt
📱 Flutter App
        │
        ▼
⚙️ API REST (Node.js + Express)
        │
        ├── Firebase
        ├── Gemini AI
        ├── Stripe
        └── SendGrid

💻 Web Admin (React + Vite)
```

---

# ✨ Funcionalidades Principales

## 📱 Aplicación móvil
- Registro e inicio de sesión
- Gestión de productos
- Gestión de servicios
- Carrito de compras
- Realización de pedidos
- Persistencia local con SQLite
- Integración de pagos con Stripe
- Consumo de API REST
- Manejo de JSON
- Almacenamiento local

---

## ⚙️ Backend
- API REST
- Autenticación JWT
- Seguridad y rate limiting
- Integración con IA
- Envío de correos electrónicos
- Manejo de pagos
- Configuración CORS
- Variables de entorno
- Protección de rutas

---

## 💻 Panel administrativo
- Dashboard administrativo
- Gestión de productos
- Visualización de estadísticas
- Administración general del sistema
- Consumo de API REST
- Visualización de gráficas

---

# 📂 Estructura del Proyecto

```txt
TociTech/
│
├── app_client/
├── backend/
├── web_admin/
│
├── documentation/
│   │
│   ├── assets/
│   │   ├── Logo-img.png
│   │   │
│   │   ├── sprint1/
│   │   ├── sprint2/
│   │   ├── sprint3/
│   │   ├── sprint4/
│   │   └── sprint5/
│   │
│   ├── README-sprint1-ui-ux.md
│   ├── README-sprint2-flutter-api.md
│   ├── README-sprint3-seguridad.md
│   ├── README-sprint4-pruebas.md
│   └── README-sprint5-analitica.md
│
└── README.md
```

---

# ⚙️ Instalación del Proyecto

## 1️⃣ Clonar repositorio

```bash
git clone https://github.com/KevinAmezcua11/TociTech.git
```

---

# ⚙️ Configuración Backend

## Entrar al backend

```bash
cd backend
```

## Instalar dependencias

```bash
npm install
```

## Configurar variables de entorno

Crear archivo `.env`

```env
PORT=
JWT_SECRET=
STRIPE_SECRET_KEY=
SENDGRID_API_KEY=
GEMINI_API_KEY=
FIREBASE_PROJECT_ID=
```

## Ejecutar servidor

```bash
npm run dev
```

---

# 📱 Configuración Flutter

## Entrar a la aplicación

```bash
cd app_client
```

## Instalar dependencias

```bash
flutter pub get
```

## Ejecutar aplicación

```bash
flutter run
```

---

# 💻 Configuración Panel Web

## Entrar al panel web

```bash
cd web_admin
```

## Instalar dependencias

```bash
npm install
```

## Ejecutar proyecto

```bash
npm run dev
```

---

# 📚 Documentación del Proyecto

La documentación del proyecto se encuentra organizada por sprint dentro de la carpeta:

```txt
/documentacion
```

## 📌 Sprints

| Sprint | Descripción |
|---|---|
| Sprint 1 | Diseño UX/UI |
| Sprint 2 | Flutter, SQLite y API REST |
| Sprint 3 | Seguridad y autenticación |
| Sprint 4 | Pruebas y CI/CD |
| Sprint 5 | Analítica y dashboard |

---

# 🔐 Seguridad Implementada

- Autenticación JWT
- Hashing de contraseñas con Bcrypt
- Configuración CORS
- Rate limiting
- Variables de entorno con Dotenv
- Protección de endpoints

---

# 🔌 APIs y Servicios Integrados

| Servicio | Uso |
|---|---|
| Firebase | Servicios externos y administración |
| Gemini AI | Funcionalidades inteligentes |
| Stripe | Procesamiento de pagos |
| SendGrid | Envío de correos electrónicos |

---

# 👨‍💻 Integrantes

- Kevin Elias Amezcua
- José Luis Encarnación García
- Ricardo Said Ramírez Cortez

---

# 🌐 Repositorio

```bash
https://github.com/KevinAmezcua11/TociTech
```

---

<div align="center">

### 📘 Proyecto Final para la materia de Taller de Full Stack

</div>
