import { useState, useEffect } from 'react';
import { useNuiEvent } from './hooks/useNuiEvent';
import { fetchNui } from './utils/fetchNui';
import PlantCard from './components/PlantCard';

function App() {
  const [visible, setVisible] = useState(false);
  const [plantData, setPlantData] = useState<any>(null);

  // Handle NUI Show
  useNuiEvent('open', (data: { plant: any }) => {
    setPlantData(data.plant);
    setVisible(true);
  });

  // Handle Close
  const handleClose = () => {
    setVisible(false);
    fetchNui('close');
  };

  const handleHarvest = (id: number) => {
    setVisible(false);
    fetchNui('harvest', { plantId: id });
  };

  // Keyboard Close (ESC)
  useEffect(() => {
    const handleKey = (e: KeyboardEvent) => {
      if (visible && e.key === 'Escape') {
        handleClose();
      }
    };
    window.addEventListener('keydown', handleKey);
    return () => window.removeEventListener('keydown', handleKey);
  }, [visible]);

  if (!visible || !plantData) return null;

  return (
    <div className="w-screen h-screen flex items-center justify-center">
      <PlantCard
        plant={plantData}
        onClose={handleClose}
        onHarvest={handleHarvest}
      />
    </div>
  );
}

export default App;
