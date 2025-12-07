# Caserio Weed UI - v1.0.0

Interfaz moderna estilo **GTA 6 / Miami Vice** para el sistema de cosecha de marihuana.

## 🌟 Características Visuales (v1.0.0)

*   **Estilo**: Glassmorphism futurista con transparencia alta (10% opacidad).
*   **Colores**: Gradientes Neón (Pink -> Purple -> Cyan) y Verde para acciones.
*   **Posición**: Esquina inferior derecha (Fixed).
*   **Tipografía**: Sans-serif limpia con sombras para legibilidad sobre fondos transparentes.
*   **Indicadores Integrados**:
    *   **Estado**: Barra de progreso y etapas (Plantula -> Vegetativa -> Floración).
    *   **Cosecha**: Badge `[E] COSECHAR` integrado en la tarjeta.
    *   **Contador**: `🌱 X/5` plantas activas.

## 🛠 Desarrollo y Build

Esta UI está construida con **React**, **TypeScript** y **TailwindCSS**.

### Requisitos
*   Node.js (v18+)

### Comandos

```bash
# Instalar dependencias
npm install

# Servidor de desarrollo (fuera del juego)
npm run dev

# Compilar para producción (FiveM)
npm run build
```

> **IMPORTANTE**: FiveM solo lee los archivos en la carpeta `dist`. Siempre ejecuta `npm run build` después de hacer cambios.

## 🎨 Sistema de Diseño

Ver `DESIGN_SYSTEM.md` para las reglas estrictas de estilos, colores y transparencia.
