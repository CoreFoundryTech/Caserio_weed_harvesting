import { useState, useEffect, useCallback } from 'react';
import './index.css';

// Interfaz para los datos que vienen desde LUA
interface PlantData {
  id: number;
  strain: string;
  label: string; // Nombre de la planta
  growthPercent: number; // 0 a 100
  isReady: boolean;
  plantCount?: number; // Opcional por si el LUA no lo envía en algún update
  maxPlants?: number;
}

function App() {
  const [visible, setVisible] = useState(false);
  const [data, setData] = useState<PlantData | null>(null);

  const getResourceName = () => (window as any).GetParentResourceName?.() || 'caserio_weed_harvesting';

  const handleClose = useCallback(() => {
    setVisible(false);
    fetch(`https://${getResourceName()}/close`, { method: 'POST', body: '{}' }).catch(() => { });
  }, []);

  const handleHarvest = useCallback(() => {
    if (!data) return;
    setVisible(false);
    fetch(`https://${getResourceName()}/harvest`, {
      method: 'POST',
      body: JSON.stringify({ plantId: data.id })
    }).catch(() => { });
  }, [data]);

  useEffect(() => {
    const handleNuiMessage = (event: MessageEvent) => {
      const { action, plant } = event.data;
      if (action === 'open') {
        setData(plant);
        setVisible(true);
      }
      if (action === 'update' && visible) {
        setData(plant);
      }
    };

    window.addEventListener('message', handleNuiMessage);
    return () => window.removeEventListener('message', handleNuiMessage);
  }, [visible]);

  // Manejo de tecla ESC y E
  useEffect(() => {
    const keyHandler = (e: KeyboardEvent) => {
      if (!visible) return;
      if (e.key === 'Escape') handleClose();
      if (e.key.toLowerCase() === 'e' && data?.isReady) handleHarvest();
    };
    window.addEventListener('keydown', keyHandler);
    return () => window.removeEventListener('keydown', keyHandler);
  }, [visible, data, handleClose, handleHarvest]);

  if (!visible || !data) return null;

  // Calculamos color del badge de plantas (rojo si está lleno)
  const isFull = (data.plantCount || 0) >= (data.maxPlants || 5);
  const plantBadgeColor = isFull ? 'text-orange-400 bg-orange-500/10 border-orange-500/20' : 'text-purple-300 bg-purple-500/10 border-purple-500/20';

  return (
    // CONTENEDOR FLOTANTE - ABAJO A LA DERECHA
    <div className="fixed bottom-10 right-10 flex flex-col items-end gap-2 pointer-events-auto font-sans">

      {/* TARJETA PRINCIPAL */}
      <div className="
        relative w-[340px] rounded-xl overflow-hidden
        animate-fade-in
        /* Borde Neón Sutil */
        p-[1px] bg-gradient-to-r from-pink-500/50 via-purple-500/50 to-cyan-500/50
        shadow-[0_0_30px_rgba(0,0,0,0.5)]
      ">

        {/* FONDO REALMENTE TRANSPARENTE (GLASSMORPHISM) */}
        <div className="
          relative w-full h-full
          bg-black/10             /* 10% opacidad (muy transparente) */
          backdrop-blur-md        /* Efecto borroso elegante */
          p-5
          flex items-center gap-4
          drop-shadow-md          /* Sombra en textos para legibilidad */
        ">

          {/* ICONO HOJA GRANDE CON NEÓN */}
          <div className="relative shrink-0 flex flex-col items-center gap-2">
            <div className="relative">
              <div className="absolute inset-0 bg-green-500/20 blur-xl rounded-full animate-pulse"></div>
              {/* SVG Icono de Hoja de Marihuana */}
              <svg
                className={`w-12 h-12 drop-shadow-[0_0_10px_rgba(74,222,128,0.6)] transition-colors duration-500 ${data.isReady ? 'text-green-400' : 'text-gray-400'}`}
                viewBox="0 0 24 24"
                fill="currentColor"
              >
                <path d="M16.5,8c0.8-0.6,2-0.4,2.6,0.2c0.3,0.3,0.5,0.7,0.5,1.1c0,1.8-1.4,4.2-3.5,6c-0.6,0.5-1.5,0.5-2.1-0.1 c-0.1-0.1-0.2-0.2-0.3-0.3c-1.4-1.6-1.9-3.4-1.6-4.9c0.2-0.8,0.8-1.5,1.5-1.8C14.5,7.8,15.6,7.6,16.5,8z M8.1,9.4 c0.6-0.5,1.5-0.5,2.1,0.1c0.1,0.1,0.2,0.2,0.3,0.3c1.4,1.6,1.9,3.4,1.6,4.9c-0.2,0.8-0.8,1.5-1.5,1.8c-0.9,0.4-2,0.5-2.9,0.2 c-0.8-0.6-2-0.4-2.6,0.2c-0.3,0.3-0.5,0.7-0.5,1.1c0,1.8,1.4,4.2,3.5,6C7.5,23.5,6.6,23.5,6,22.9C6,22.9,6,22.9,6,22.9 c-1.4-1.6-1.9-3.4-1.6-4.9c0.2-0.8,0.8-1.5,1.5-1.8C6.9,15.8,8,15.6,8.1,9.4z M12,2c1.1,0,2,0.9,2,2c0,3-1.6,6.6-4,9 c-0.6,0.6-1.5,0.6-2.1,0c0,0,0,0,0,0c-0.6-0.6-0.6-1.5,0-2.1C10.4,8.6,12,5,12,2z" />
              </svg>
            </div>

            {/* BADGE DE PLANTAS INTEGRADO BAJO EL ICONO */}
            <div className={`
              flex items-center gap-1 px-1.5 py-0.5 rounded
              border text-[9px] font-bold tracking-wider
              ${plantBadgeColor}
            `}>
              <span>🌱</span>
              <span>{data.plantCount ?? 0}/{data.maxPlants ?? 5}</span>
            </div>
          </div>

          {/* INFO TEXTO */}
          <div className="flex-1 min-w-0 flex flex-col justify-center">
            <div className="flex justify-between items-start">
              <h2 className="text-white font-bold text-lg tracking-wide truncate drop-shadow-md pr-2">
                {data.label || 'Planta Desconocida'}
              </h2>

              {/* INDICADOR DE COSECHA INTEGRADO (Solo si está listo) */}
              {data.isReady && (
                <div
                  className="
                    flex items-center gap-1.5 px-2 py-1 rounded
                    bg-green-500/20 border border-green-500/30
                    animate-pulse cursor-pointer group hover:bg-green-500/30 transition-colors
                  "
                  onClick={handleHarvest}
                >
                  <div className="
                    w-4 h-4 flex items-center justify-center 
                    bg-white text-black font-bold rounded-[3px] text-[10px]
                    shadow-sm
                  ">E</div>
                  <span className="text-[10px] font-bold text-green-300 tracking-wider">COSECHAR</span>
                </div>
              )}
            </div>

            {/* Barra Progreso Minimalista */}
            <div className="mt-2 w-full bg-white/10 h-1.5 rounded-full overflow-hidden backdrop-blur-sm">
              <div
                className={`h-full shadow-[0_0_10px_currentColor] transition-all duration-700 ease-out ${data.isReady ? 'bg-green-400 text-green-400 w-full' : 'bg-pink-500 text-pink-500'
                  }`}
                style={{ width: `${data.growthPercent}%` }}
              />
            </div>

            <div className="flex justify-between items-center mt-1">
              <span className="text-[10px] text-gray-300 uppercase tracking-wider font-semibold opacity-80">
                {data.isReady ? 'LISTO' : 'CRECIENDO...'}
              </span>
              <span className={`text-xs font-bold ${data.isReady ? 'text-green-400' : 'text-pink-400'}`}>
                {data.growthPercent}%
              </span>
            </div>
          </div>

        </div>
      </div>
    </div>
  );
}

export default App;
