# Sistema de Diseño UI/UX: Miami Vice Transparente (FiveM)

Este documento define las reglas estrictas de diseño para todas las interfaces (NUI) de este proyecto.

## 🧬 ADN Visual

*   **Estilo**: Glassmorphism futurista, limpio, minimalista (GTA 6 inspired).
*   **Transparencia (CRÍTICO)**: Fondos translúcidos (10-20% opacidad). El juego debe verse detrás.
*   **Efecto**: `backdrop-blur-md` (Sutil).

## 🎨 Paleta de Colores (Tailwind CSS)

| Elemento | Clases Tailwind | Descripción |
| :--- | :--- | :--- |
| **Fondo Principal** | `bg-black/10` o `bg-slate-950/20` | Negro casi transparente. |
| **Bordes/Acentos** | `from-pink-500` via `purple-500` to `cyan-500` | Gradiente Miami Vice. |
| **Texto Principal** | `text-white` | Blanco puro. |
| **Texto Secundario** | `text-gray-300` o `text-cyan-200` | Contraste suave. |
| **Éxito / Acción** | `text-green-400` / `bg-green-500/20` | Verde neón. |
| **Error / Alerta** | `text-pink-500` / `bg-pink-500/20` | Rosa neón. |
| **Glow (Sombra)** | `shadow-[0_0_15px_rgba(236,72,153,0.3)]` | Resplandor neón sutil. |

## 🛠 Estructura Técnica (React + Tailwind)

### 1. Fix de Transparencia Global (`index.css`)
```css
html, body, #root {
  background-color: transparent !important;
  pointer-events: none; /* Permite clickear el juego a través de la UI vacía */
}
```

### 2. Contenedor Base (Pattern)
```tsx
<div className="fixed [posicion] pointer-events-auto">
  <div className="
    relative rounded-xl overflow-hidden
    p-[1px] /* Borde gradiente */
    bg-gradient-to-br from-pink-500/40 via-purple-500/40 to-cyan-500/40
    shadow-[0_0_20px_rgba(0,0,0,0.2)]
    animate-fade-in
  ">
    <div className="
      w-full h-full
      bg-black/30          /* Transparencia alta */
      backdrop-blur-md     /* Desenfoque sutil */
      p-5 text-white
    ">
      {/* Contenido UI */}
    </div>
  </div>
</div>
```

## 🧩 Componentes

*   **Botones**: Deben tener feedback visual (hover: brightness, scale).
*   **Tipografía**: `font-sans` (Inter/Segoe UI). Títulos `font-bold`. Subtítulos `uppercase tracking-wider`.
