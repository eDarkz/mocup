# FumiControl SaaS - Sistema de Gestión de Fumigación

Sistema completo multi-tenant para empresas de control de plagas con 5 niveles de usuario jerárquicos.

## Características Principales

- **Sistema Multi-Tenant**: Arquitectura SaaS completa con aislamiento de datos
- **5 Niveles de Usuario**: SaaS Admin, Empresa, Supervisión, Operativo y Cliente
- **Autenticación Segura**: Basado en Supabase Auth con Row Level Security
- **Base de Datos Completa**: 30+ tablas con relaciones y políticas RLS
- **Diseño Moderno**: UI con Tailwind CSS y componentes reutilizables
- **Routing Protegido**: Control de acceso basado en roles

## Arquitectura de Usuarios

### Nivel 1: SaaS Admin (Super Administrador)
- Vista global del sistema
- Gestión de empresas y suscripciones
- Feature flags y configuración
- Auditoría y backups

### Nivel 2: Empresa (Admin de Fumigadora)
- Dashboard de empresa
- Gestión de clientes y locaciones
- Control de inventario y químicos
- Administración de técnicos y vehículos

### Nivel 3: Supervisión (Coordinadores)
- Monitoreo de equipos en tiempo real
- Asignación de servicios
- Revisión y aprobación de reportes

### Nivel 4: Operativo (Técnicos de Campo)
- App móvil-first
- Registro de fumigaciones
- Escaneo QR de estaciones
- Modo offline

### Nivel 5: Cliente (Portal del Cliente)
- Vista de servicios programados
- Historial de fumigaciones
- Descarga de certificados
- Solicitud de servicios

## Tecnologías Utilizadas

- **Frontend**: React 18 + TypeScript + Vite
- **Estilos**: Tailwind CSS con sistema de diseño personalizado
- **Base de Datos**: Supabase (PostgreSQL)
- **Autenticación**: Supabase Auth
- **Routing**: React Router v6
- **Estado**: React Context API

## Estructura del Proyecto

```
app/
├── src/
│   ├── components/
│   │   ├── ui/              # Componentes UI reutilizables
│   │   │   ├── Button.tsx
│   │   │   ├── Input.tsx
│   │   │   ├── Card.tsx
│   │   │   ├── Badge.tsx
│   │   │   └── StatCard.tsx
│   │   ├── layout/          # Componentes de layout
│   │   │   ├── Sidebar.tsx
│   │   │   ├── MainLayout.tsx
│   │   │   └── PageHeader.tsx
│   │   └── ProtectedRoute.tsx
│   ├── contexts/
│   │   └── AuthContext.tsx  # Contexto de autenticación
│   ├── lib/
│   │   └── supabase.ts      # Cliente de Supabase
│   ├── pages/
│   │   ├── Login.tsx
│   │   ├── Home.tsx
│   │   ├── saas/
│   │   │   └── Dashboard.tsx
│   │   └── empresa/
│   │       └── Dashboard.tsx
│   ├── App.tsx              # Router principal
│   └── index.css            # Estilos globales
├── .env                      # Variables de entorno
└── package.json
```

## Instalación

1. Clonar el repositorio
2. Instalar dependencias:
   ```bash
   npm install
   ```

3. Configurar variables de entorno en `.env`:
   ```
   VITE_SUPABASE_URL=tu_url_de_supabase
   VITE_SUPABASE_SUPABASE_ANON_KEY=tu_clave_publica
   ```

4. Aplicar migraciones de Supabase (ya aplicadas en el proyecto)

5. Ejecutar en desarrollo:
   ```bash
   npm run dev
   ```

## Cuentas de Demostración

Para probar la aplicación, usa estas credenciales:

| Email | Password | Rol |
|-------|----------|-----|
| saas@demo.com | demo | SaaS Admin |
| empresa@demo.com | demo | Empresa Admin |
| super@demo.com | demo | Supervisión |
| tecnico@demo.com | demo | Operativo |
| cliente@demo.com | demo | Cliente |

## Base de Datos

El esquema de base de datos incluye:

### Tablas Principales
- **tenants**: Empresas SaaS
- **users**: Usuarios multi-nivel
- **customers**: Clientes de las fumigadoras
- **locations**: Locaciones a fumigar
- **service_orders**: Órdenes de servicio
- **fumigations**: Registros de fumigación
- **pests**: Catálogo de plagas
- **chemicals**: Inventario de químicos
- **stations**: Estaciones de monitoreo
- **invoices**: Facturación
- **reports**: Reportes de servicio
- **certificates**: Certificados de cumplimiento

### Seguridad
- **Row Level Security (RLS)** habilitado en todas las tablas
- Políticas basadas en tenant_id y role
- Aislamiento completo de datos entre tenants

## Características de Seguridad

1. **Autenticación**: Supabase Auth con sesiones seguras
2. **RLS**: Control de acceso a nivel de fila
3. **Roles**: Sistema jerárquico de 5 niveles
4. **Rutas Protegidas**: Componente ProtectedRoute con validación de roles
5. **Aislamiento de Datos**: Multi-tenancy con separación completa

## Scripts Disponibles

- `npm run dev`: Ejecutar en modo desarrollo
- `npm run build`: Compilar para producción
- `npm run preview`: Vista previa del build de producción

## Próximos Pasos

1. Implementar páginas adicionales para cada nivel
2. Agregar funcionalidad de mapas con GPS
3. Implementar modo offline para técnicos
4. Sistema de notificaciones en tiempo real
5. Generador de PDFs para reportes
6. Integración con facturación electrónica (CFDI)

## Licencia

Proyecto privado - Todos los derechos reservados
