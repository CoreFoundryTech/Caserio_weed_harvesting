import { useState, useEffect, useCallback } from 'react';
import { motion, AnimatePresence } from 'framer-motion';

interface PlantData {
  id: number;
  strain: string;
  stage: number;
  stageName: string;
  label: string;
  health: number;
  water: number;
  growthPercent: number;
  isReady: boolean;
  plantCount?: number;
  maxPlants?: number;
}

function App() {
  const [visible, setVisible] = useState(false);
  const [plant, setPlant] = useState<PlantData | null>(null);

  const getResourceName = () => (window as any).GetParentResourceName?.() || 'caserio_weed_harvesting';

  const handleClose = useCallback(() => {
    setVisible(false);
    fetch(`https://${getResourceName()}/close`, { method: 'POST', body: '{}' }).catch(() => { });
  }, []);

  const handleHarvest = useCallback((id: number) => {
    setVisible(false);
    fetch(`https://${getResourceName()}/harvest`, { method: 'POST', body: JSON.stringify({ plantId: id }) }).catch(() => { });
  }, []);

  useEffect(() => {
    const handler = (e: MessageEvent) => {
      if (e.data?.action === 'open') { setPlant(e.data.plant); setVisible(true); }
      if (e.data?.action === 'update') setPlant(e.data.plant);
    };
    window.addEventListener('message', handler);
    return () => window.removeEventListener('message', handler);
  }, []);

  useEffect(() => {
    const keyHandler = (e: KeyboardEvent) => { if (visible && e.key === 'Escape') handleClose(); };
    window.addEventListener('keydown', keyHandler);
    return () => window.removeEventListener('keydown', keyHandler);
  }, [visible, handleClose]);

  const getStage = (s: number, n: string) => n?.includes('stage_') ? ['Plántula', 'Vegetativa', 'Floración'][s] : n;

  if (!visible || !plant) return null;

  return (
    <div style={{ position: 'fixed', bottom: 40, right: 40, pointerEvents: 'auto' }}>
      <AnimatePresence>
        <motion.div
          key="card"
          initial={{ opacity: 0, x: 30 }}
          animate={{ opacity: 1, x: 0 }}
          exit={{ opacity: 0, x: 30 }}
          transition={{ type: 'spring', damping: 22, stiffness: 280 }}
          style={{
            width: 300,
            padding: '22px 24px',
            borderRadius: 16,
            background: 'linear-gradient(180deg, rgba(25,25,35,0.85) 0%, rgba(18,18,28,0.75) 100%)',
            backdropFilter: 'blur(12px)',
            WebkitBackdropFilter: 'blur(12px)',
            fontFamily: '-apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif',
            color: '#fff',
            boxShadow: '0 8px 32px rgba(0,0,0,0.35)'
          }}
        >
          {/* Header */}
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 16 }}>
            <div>
              <div style={{
                fontSize: 20,
                fontWeight: 700,
                color: '#fff',
                letterSpacing: '-0.5px',
                textShadow: '0 2px 10px rgba(0,0,0,0.3)'
              }}>{plant.label}</div>
              <div style={{
                fontSize: 11,
                marginTop: 8,
                padding: '5px 14px',
                borderRadius: 20,
                display: 'inline-block',
                background: plant.isReady
                  ? 'linear-gradient(90deg, rgba(45,212,191,0.25), rgba(34,197,94,0.2))'
                  : 'linear-gradient(90deg, rgba(168,85,247,0.2), rgba(139,92,246,0.15))',
                color: plant.isReady ? '#5eead4' : '#c4b5fd',
                fontWeight: 600,
                letterSpacing: 0.8,
                textTransform: 'uppercase'
              }}>{getStage(plant.stage, plant.stageName)}{plant.isReady && ' ✓'}</div>
            </div>
            <div
              onClick={handleClose}
              style={{
                cursor: 'pointer',
                color: 'rgba(255,255,255,0.4)',
                fontSize: 16,
                padding: 8,
                borderRadius: 8,
                transition: 'all 0.2s'
              }}
            >✕</div>
          </div>

          {/* Stats Container */}
          <div style={{
            background: 'linear-gradient(180deg, rgba(255,255,255,0.04) 0%, rgba(255,255,255,0.02) 100%)',
            borderRadius: 14,
            padding: '16px 18px',
            marginBottom: 14
          }}>
            {[
              { label: 'Crecimiento', value: plant.growthPercent, gradient: 'linear-gradient(90deg, #a855f7, #ec4899)' },
              { label: 'Salud', value: plant.health, gradient: plant.health > 50 ? 'linear-gradient(90deg, #22c55e, #10b981)' : 'linear-gradient(90deg, #f59e0b, #ef4444)' },
              { label: 'Agua', value: plant.water, gradient: 'linear-gradient(90deg, #0ea5e9, #06b6d4)' }
            ].map((stat, idx) => (
              <div key={idx} style={{ marginBottom: idx < 2 ? 14 : 0 }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 6 }}>
                  <span style={{ fontSize: 12, color: 'rgba(255,255,255,0.5)', fontWeight: 500 }}>{stat.label}</span>
                  <span style={{ fontSize: 13, color: '#fff', fontWeight: 700 }}>{stat.value}%</span>
                </div>
                <div style={{
                  height: 6,
                  background: 'rgba(255,255,255,0.08)',
                  borderRadius: 8,
                  overflow: 'hidden'
                }}>
                  <motion.div
                    animate={{ width: `${stat.value}%` }}
                    transition={{ duration: 0.5, ease: 'easeOut' }}
                    style={{
                      height: '100%',
                      background: stat.gradient,
                      borderRadius: 8,
                      boxShadow: '0 0 12px rgba(168,85,247,0.3)'
                    }}
                  />
                </div>
              </div>
            ))}
          </div>

          {/* Plant Count */}
          {plant.plantCount !== undefined && (
            <div style={{
              display: 'flex',
              justifyContent: 'space-between',
              alignItems: 'center',
              padding: '12px 16px',
              background: 'linear-gradient(90deg, rgba(168,85,247,0.1), rgba(139,92,246,0.08))',
              borderRadius: 12,
              marginBottom: plant.isReady ? 14 : 0
            }}>
              <span style={{ fontSize: 12, color: 'rgba(255,255,255,0.5)', fontWeight: 500 }}>🌱 Plantas activas</span>
              <span style={{ fontSize: 15, color: '#c4b5fd', fontWeight: 700 }}>{plant.plantCount} / {plant.maxPlants}</span>
            </div>
          )}

          {/* Harvest Button */}
          {plant.isReady && (
            <motion.div
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.1 }}
              onClick={() => handleHarvest(plant.id)}
              style={{
                padding: '14px 0',
                textAlign: 'center',
                borderRadius: 14,
                background: 'linear-gradient(135deg, #14b8a6, #0d9488)',
                color: '#fff',
                fontSize: 14,
                fontWeight: 700,
                cursor: 'pointer',
                letterSpacing: 0.5,
                boxShadow: '0 4px 20px rgba(20,184,166,0.35)',
                textTransform: 'uppercase'
              }}
            >🌿 Cosechar</motion.div>
          )}
        </motion.div>
      </AnimatePresence>
    </div>
  );
}

export default App;
