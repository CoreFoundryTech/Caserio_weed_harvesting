import React from 'react';

interface PlantData {
    id: number;
    strain: string;
    stage: number;
    label: string;
    health: number;
    water: number;
    growthPercent: number;
    timeRemaining: number;
}

interface PlantCardProps {
    plant: PlantData;
    onClose: () => void;
    onHarvest: (id: number) => void;
}

const PlantCard: React.FC<PlantCardProps> = ({ plant, onClose, onHarvest }) => {
    const isReady = plant.stage >= 2;

    // Colors based on percentage
    const getBarColor = (val: number) => {
        if (val > 80) return 'bg-neon-green';
        if (val > 40) return 'bg-yellow-400';
        return 'bg-red-500';
    };

    return (
        <div className="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 w-96 bg-glass-black backdrop-blur-md rounded-xl border border-white/10 p-6 shadow-[0_0_50px_rgba(57,255,20,0.2)] text-white font-sans animate-fade-in">
            {/* Header */}
            <div className="flex justify-between items-start mb-6">
                <div>
                    <h2 className="text-2xl font-bold bg-clip-text text-transparent bg-gradient-to-r from-neon-green to-white">
                        {plant.label}
                    </h2>
                    <p className="text-sm text-gray-400 uppercase tracking-widest mt-1">
                        {isReady ? 'LISTO PARA COSECHAR' : `ETAPA ${plant.stage + 1}/3`}
                    </p>
                </div>
                <button
                    onClick={onClose}
                    className="text-gray-400 hover:text-white transition-colors"
                >
                    <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                    </svg>
                </button>
            </div>

            {/* Stats */}
            <div className="space-y-4 mb-8">
                {/* Growth */}
                <div>
                    <div className="flex justify-between text-xs mb-1">
                        <span className="text-gray-300">Crecimiento</span>
                        <span>{plant.growthPercent}%</span>
                    </div>
                    <div className="h-2 bg-white/10 rounded-full overflow-hidden">
                        <div
                            className="h-full bg-neon-green transition-all duration-1000 ease-out shadow-[0_0_10px_#39ff14]"
                            style={{ width: `${plant.growthPercent}%` }}
                        />
                    </div>
                </div>

                {/* Health */}
                <div>
                    <div className="flex justify-between text-xs mb-1">
                        <span className="text-gray-300">Salud</span>
                        <span>{plant.health}%</span>
                    </div>
                    <div className="h-1.5 bg-white/10 rounded-full overflow-hidden">
                        <div
                            className={`h-full transition-all duration-500 ${getBarColor(plant.health)}`}
                            style={{ width: `${plant.health}%` }}
                        />
                    </div>
                </div>

                {/* Water */}
                <div>
                    <div className="flex justify-between text-xs mb-1">
                        <span className="text-gray-300">Agua</span>
                        <span>{plant.water}%</span>
                    </div>
                    <div className="h-1.5 bg-white/10 rounded-full overflow-hidden">
                        <div
                            className={`h-full transition-all duration-500 bg-blue-400`}
                            style={{ width: `${plant.water}%` }}
                        />
                    </div>
                </div>
            </div>

            {/* Actions */}
            <div className="flex gap-3">
                {isReady && (
                    <button
                        onClick={() => onHarvest(plant.id)}
                        className="flex-1 bg-neon-green/90 hover:bg-neon-green text-black font-bold py-3 px-4 rounded-lg shadow-[0_0_20px_rgba(57,255,20,0.4)] transition-all hover:scale-105 active:scale-95 flex items-center justify-center gap-2"
                    >
                        <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M刀5 3v4M3 5h4M6 17v4m-2-2h4m5-16l2.286 6.857L21 12l-5.714 2.143L13 21l-2.286-6.857L5 12l5.714-2.143L13 3z" />
                        </svg>
                        COSECHAR
                    </button>
                )}
            </div>
        </div>
    );
};

export default PlantCard;
