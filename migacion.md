🌿 Caserio Weed Harvesting (Next-Gen) - Documentación de MigraciónVersión: 2.0.0 RefactorAutor: CoreFoundry & AsistenteEstado: En Progreso1. Visión General del ProyectoEl objetivo de esta refactorización es transformar el script legacy caserio_weed_harvesting en una aplicación moderna, optimizada y estéticamente superior.Principales CambiosCaracterísticaLegacy (Antiguo)Next-Gen (Nuevo)FrontendHTML / jQuery / CSSReact 18 + TypeScript + TailwindCSSBuild ToolNinguno (Raw files)Vite (Optimized Build)InteracciónDrawText3D + Distance Loopqb-target / ox_target (Zero CPU Usage)DatosVariables locales / SQL directoState Bags (Entity.state)CrecimientoAttachEntity (Glitchy)Hot Swap (Transición Atómica de Modelos)2. Estructura de Archivos (Target)La nueva estructura elimina la carpeta ui/ antigua y centraliza el frontend en web/./ (Raíz del Recurso)
├── fxmanifest.lua        <-- Configurado para cargar web/dist/index.html
├── config.lua            <-- Configuraciones compartidas
├── client/
│   ├── main.lua          <-- Lógica principal y Targets
│   └── growth_logic.lua  <-- Motor de crecimiento "Hot Swap"
├── server/
│   └── main.lua          <-- Persistencia y seguridad
└── web/                  <-- Entorno de desarrollo React
    ├── package.json
    ├── vite.config.ts    <-- Configuración crítica para FiveM
    ├── tailwind.config.js
    └── src/
        ├── App.tsx
        ├── main.tsx
        └── components/
            └── PlantCard.tsx  <-- UI Component (Glassmorphism)
3. Fase 1: Limpieza (The Purge)Antes de escribir código nuevo, es obligatorio eliminar la deuda técnica para evitar conflictos.Eliminar Carpeta: Borrar completamente la carpeta ui/ antigua.Eliminar Archivos: Borrar client/html.lua (si existe) o cualquier referencia a SendNUIMessage antiguo.Limpiar Bucles: En client/main.lua, eliminar cualquier Citizen.CreateThread que contenga DrawText3D o chequeos de distancia constantes (#(coords - plyCoords)).4. Configuración del Recursofxmanifest.lua ActualizadoEste manifiesto indica a FiveM que cargue la versión compilada de React.fx_version 'cerulean'
game 'gta5'
lua54 'yes'

description 'Caserio Weed Harvesting Next-Gen'
version '2.0.0'

-- UI React Build (Apunta a la carpeta de salida de Vite)
ui_page 'web/dist/index.html'

files {
    'web/dist/index.html',
    'web/dist/assets/*.js',
    'web/dist/assets/*.css',
    'locales/*.lua',
    'stream/*.ydr',
    'stream/*.ytyp'
}

shared_scripts {
    'config.lua',
    'locales/locale.lua',
    'locales/*.lua' 
}

client_scripts {
    '@PolyZone/client.lua',
    '@qb-core/shared/init.lua',
    'client/growth_logic.lua', -- Nueva lógica
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}
5. Frontend (React + Vite + Tailwind)Configuración del Entorno (web/)Instalación:cd web
npm install
# Dependencias principales: react, react-dom, tailwindcss, postcss, autoprefixer
web/vite.config.ts (Crítico):La propiedad base: './' es obligatoria para que el NUI encuentre los assets.import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  base: './', 
  build: {
    outDir: 'dist',
    emptyOutDir: true,
  },
});
web/tailwind.config.js:export default {
  content: ["./index.html", "./src/**/*.{js,ts,jsx,tsx}"],
  theme: {
    extend: {
      colors: {
        'glass-black': 'rgba(10, 10, 10, 0.70)',
        'neon-green': '#39ff14',
      },
    },
  },
  plugins: [],
}
Componente UI: PlantCard.tsxUbicación: web/src/components/PlantCard.tsxEste componente renderiza la tarjeta flotante con estilo Glassmorphism.(Ver código completo en la respuesta del chat anterior o en los archivos generados).6. Backend Logic (Lua Client)Arquitectura de Crecimiento: "The Hot Swap"Dado que los assets son modelos combinados (Maceta + Planta), no podemos escalar la entidad. Debemos sustituirla.Archivo: client/growth_logic.luaAlgoritmo de Intercambio:Captura: Guarda coordenadas, rotación y el StateBag actual.Limpieza: Elimina la entidad antigua (Fase 1).Generación: Crea la nueva entidad (Fase 2) en la misma posición exacta.Inyección: Escribe los datos guardados en el StateBag de la nueva entidad.Snippet de Código Clave:local function HotSwapPlant(currentEntity, nextStageModel, plantData)
    local coords = GetEntityCoords(currentEntity)
    local heading = GetEntityHeading(currentEntity)
    
    -- Limpieza
    SetEntityAsMissionEntity(currentEntity, true, true)
    DeleteEntity(currentEntity)

    -- Generación
    local modelHash = GetHashKey(nextStageModel)
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do Wait(10) end
    local newObj = CreateObject(modelHash, coords.x, coords.y, coords.z, false, true, false)
    
    -- Inyección de Estado
    Entity(newObj).state:set('plantData', {
        id = plantData.id,
        strain = plantData.strain,
        water = plantData.water,
        growth = plantData.growth,
        stage = plantData.stage + 1
    }, true)
    
    return newObj
end
7. Instrucciones de Despliegue (Build)Cada vez que realices cambios en la carpeta web/, debes recompilar para que FiveM vea los cambios.Abrir terminal en web/.Ejecutar:npm run build
Reiniciar el script en el servidor:ensure caserio_weed_harvesting
8. Siguientes Pasos (Roadmap)Integrar Target: Configurar client/main.lua para usar exports['qb-target']:AddTargetModel en los modelos de las macetas.Hook de NUI: Crear el hook useNuiEvent en React para escuchar cuando el jugador mira la planta.Eventos Servidor: Asegurar que server/main.lua guarde el estado en la base de datos cuando el StateBag cambia.