# Sistema de Plantación de Weed - Implementación Completa

He transformado el pack de props `mriprops_weed` en un sistema de plantación completo con UI moderna y soporte multilenguaje.

## Características Nuevas
- 🌐 **Multilenguaje**: Soporte completo para Español Latino (`es`) e Inglés ([en](file:///Users/jarmijo/ProyectosP/Addons%20FIvem/mriprops_weed/ui/script.js#26-66)).
- 💻 **Interfaz UI**: Panel moderno para ver el estado de la planta (Cepa, Etapa, Crecimiento %).
- 🪴 **Sistema de Macetas**: Requiere el item `weed_pot` para plantar.
- 💾 **Persistencia**: Las plantas se guardan en BD.

## Archivos Creados

### Configuración y Locales
- **[config.lua](file:///Users/jarmijo/ProyectosP/Addons%20FIvem/mriprops_weed/config.lua)**: Configuración de cepas, tiempos y `RequirePot`.
- **[locales/locale.lua](file:///Users/jarmijo/ProyectosP/Addons%20FIvem/mriprops_weed/locales/locale.lua)**: Sistema de traducción.
- **[locales/es.lua](file:///Users/jarmijo/ProyectosP/Addons%20FIvem/mriprops_weed/locales/es.lua)**: Traducciones al Español.

### Interfaz (UI)
- **[ui/index.html](file:///Users/jarmijo/ProyectosP/Addons%20FIvem/mriprops_weed/ui/index.html)**: Estructura del Dashboard.
- **[ui/style.css](file:///Users/jarmijo/ProyectosP/Addons%20FIvem/mriprops_weed/ui/style.css)**: Estilos modernos (Glassmorphism).
- **[ui/script.js](file:///Users/jarmijo/ProyectosP/Addons%20FIvem/mriprops_weed/ui/script.js)**: Lógica de UI.

### Scripts
- **[client/interactions.lua](file:///Users/jarmijo/ProyectosP/Addons%20FIvem/mriprops_weed/client/interactions.lua)**: Maneja el uso de semillas (check de maceta) y abre la UI con Target.
- **[client/main.lua](file:///Users/jarmijo/ProyectosP/Addons%20FIvem/mriprops_weed/client/main.lua)**: Renderizado de plantas y callbacks de UI.
- **[server/main.lua](file:///Users/jarmijo/ProyectosP/Addons%20FIvem/mriprops_weed/server/main.lua)**: Lógica segura de servidor y base de datos.
  - **Actualización**: Ahora consume la `weed_pot` al plantar si `Config.RequirePot = true`.

## Instrucciones de Integración

### 1. Agregar Items a QB-Core
Abre `qb-core/shared/items.lua` y agrega el siguiente bloque:

```lua
-- Weed System Items
['weed_pot'] = {['name'] = 'weed_pot', ['label'] = 'Maceta', ['weight'] = 200, ['type'] = 'item', ['image'] = 'weed_pot.png', ['unique'] = false, ['useable'] = false, ['shouldClose'] = false, ['combinable'] = nil, ['description'] = 'Una maceta para plantar.'},

-- Seeds
['weed_seed_blue'] = {['name'] = 'weed_seed_blue', ['label'] = 'Semilla Blue Dream', ['weight'] = 10, ['type'] = 'item', ['image'] = 'weed_seed_blue.png', ['unique'] = false, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'Semilla de Blue Dream.'},
['weed_seed_green'] = {['name'] = 'weed_seed_green', ['label'] = 'Semilla Green Crack', ['weight'] = 10, ['type'] = 'item', ['image'] = 'weed_seed_green.png', ['unique'] = false, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'Semilla de Green Crack.'},
['weed_seed_orange'] = {['name'] = 'weed_seed_orange', ['label'] = 'Semilla Orange Kush', ['weight'] = 10, ['type'] = 'item', ['image'] = 'weed_seed_orange.png', ['unique'] = false, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'Semilla de Orange Kush.'},
['weed_seed_pink'] = {['name'] = 'weed_seed_pink', ['label'] = 'Semilla Pink Panther', ['weight'] = 10, ['type'] = 'item', ['image'] = 'weed_seed_pink.png', ['unique'] = false, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'Semilla de Pink Panther.'},
['weed_seed_purple'] = {['name'] = 'weed_seed_purple', ['label'] = 'Semilla Purple Haze', ['weight'] = 10, ['type'] = 'item', ['image'] = 'weed_seed_purple.png', ['unique'] = false, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'Semilla de Purple Haze.'},
['weed_seed_red'] = {['name'] = 'weed_seed_red', ['label'] = 'Semilla Red Dragon', ['weight'] = 10, ['type'] = 'item', ['image'] = 'weed_seed_red.png', ['unique'] = false, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'Semilla de Red Dragon.'},
['weed_seed_yellow'] = {['name'] = 'weed_seed_yellow', ['label'] = 'Semilla Yellow Submarine', ['weight'] = 10, ['type'] = 'item', ['image'] = 'weed_seed_yellow.png', ['unique'] = false, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'Semilla de Yellow Submarine.'},

-- Buds (Cogollos)
['weed_blue'] = {['name'] = 'weed_blue', ['label'] = 'Blue Dream', ['weight'] = 50, ['type'] = 'item', ['image'] = 'weed_blue.png', ['unique'] = false, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'Cogollos de Blue Dream.'},
['weed_green'] = {['name'] = 'weed_green', ['label'] = 'Green Crack', ['weight'] = 50, ['type'] = 'item', ['image'] = 'weed_green.png', ['unique'] = false, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'Cogollos de Green Crack.'},
['weed_orange'] = {['name'] = 'weed_orange', ['label'] = 'Orange Kush', ['weight'] = 50, ['type'] = 'item', ['image'] = 'weed_orange.png', ['unique'] = false, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'Cogollos de Orange Kush.'},
['weed_pink'] = {['name'] = 'weed_pink', ['label'] = 'Pink Panther', ['weight'] = 50, ['type'] = 'item', ['image'] = 'weed_pink.png', ['unique'] = false, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'Cogollos de Pink Panther.'},
['weed_purple'] = {['name'] = 'weed_purple', ['label'] = 'Purple Haze', ['weight'] = 50, ['type'] = 'item', ['image'] = 'weed_purple.png', ['unique'] = false, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'Cogollos de Purple Haze.'},
['weed_red'] = {['name'] = 'weed_red', ['label'] = 'Red Dragon', ['weight'] = 50, ['type'] = 'item', ['image'] = 'weed_red.png', ['unique'] = false, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'Cogollos de Red Dragon.'},
['weed_yellow'] = {['name'] = 'weed_yellow', ['label'] = 'Yellow Submarine', ['weight'] = 50, ['type'] = 'item', ['image'] = 'weed_yellow.png', ['unique'] = false, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'Cogollos de Yellow Submarine.'},
```

### 2. Agregar a Tiendas (qb-shops)
Para vender los items en una tienda (ej. Smoke Shop), agrega esto a `qb-shops/config.lua` (o equivalente):

```lua
Config.Products["weed_shop"] = {
    [1] = { name = "weed_pot", price = 50, amount = 50, info = {}, type = "item", slot = 1 },
    [2] = { name = "weed_seed_blue", price = 100, amount = 50, info = {}, type = "item", slot = 2 },
    [3] = { name = "weed_seed_green", price = 100, amount = 50, info = {}, type = "item", slot = 3 },
    -- ... agrega las demás semillas
}
```

### 3. Comandos de Admin
Puedes spawnear items usando el comando estándar de qb-core:
- `/giveitem [id] weed_pot 1`
- `/giveitem [id] weed_seed_blue 1`

También he incluido un comando de prueba en el script:
- `/giveseed [color]` (ej: `/giveseed blue`)

## Cómo Usar

1. **Requisitos**: Ten una `weed_pot` y una `weed_seed_[color]` en tu inventario.
2. **Plantar**: Usa la semilla. Si tienes maceta, comenzará la animación y **se consumirá la maceta**.
3. **Estado**: Usa el ojo (Target) en la planta para abrir el Dashboard.
4. **Cosechar**: Cuando llegue a "Floración" (Etapa 2), el botón "COSECHAR" en la UI se activará.
