const app = document.getElementById('app');
const strainNameEl = document.getElementById('strain-name');
const stageValueEl = document.getElementById('stage-value');
const growthValueEl = document.getElementById('growth-value');
const growthBarEl = document.getElementById('growth-bar');
const harvestBtn = document.getElementById('harvest-btn');
const closeBtn = document.getElementById('close-btn');

// Labels
const lblStage = document.getElementById('lbl-stage');
const lblGrowth = document.getElementById('lbl-growth');
const lblHarvest = document.getElementById('lbl-harvest');

let currentPlantId = null;

window.addEventListener('message', (event) => {
    const data = event.data;

    if (data.action === 'open') {
        openUI(data.plant, data.translations);
    } else if (data.action === 'close') {
        closeUI();
    }
});

function openUI(plant, translations) {
    currentPlantId = plant.id;

    // Apply translations
    if (translations) {
        lblStage.textContent = translations.ui_stage || 'Growth Stage';
        lblGrowth.textContent = translations.ui_growth || 'MATURITY';
        lblHarvest.textContent = translations.ui_harvest || 'HARVEST PLANT';

        if (document.getElementById('lbl-health')) document.getElementById('lbl-health').textContent = translations.ui_health || 'Health';
        if (document.getElementById('lbl-water')) document.getElementById('lbl-water').textContent = translations.ui_water || 'Water';

        // Stage text
        const stageKey = `stage_${plant.stage}`;
        stageValueEl.textContent = translations[stageKey] || `Stage ${plant.stage}`;
    }

    strainNameEl.textContent = plant.label;
    if (document.getElementById('strain-type')) document.getElementById('strain-type').textContent = 'PREMIUM STRAIN';

    // Stats (Randomized or passed from server)
    const health = plant.health || 100;
    const water = plant.water || 100;

    if (document.getElementById('health-value')) document.getElementById('health-value').textContent = `${health}%`;
    if (document.getElementById('health-bar')) document.getElementById('health-bar').style.width = `${health}%`;

    if (document.getElementById('water-value')) document.getElementById('water-value').textContent = `${water}%`;
    if (document.getElementById('water-bar')) document.getElementById('water-bar').style.width = `${water}%`;

    // Calculate growth percentage
    let percentage = plant.growthPercent || 33;
    if (plant.stage === 0) percentage = plant.growthPercent || 33;
    else if (plant.stage === 1) percentage = plant.growthPercent || 66;
    else if (plant.stage === 2) percentage = 100;

    growthValueEl.textContent = `${percentage}%`;
    growthBarEl.style.width = `${percentage}%`;

    // Show time remaining
    if (plant.timeRemaining && plant.stage < 2) {
        const minutes = Math.floor(plant.timeRemaining / 60);
        const timeText = minutes > 60 ? `${Math.floor(minutes / 60)}h ${minutes % 60}m` : `${minutes}m`;
        stageValueEl.textContent = `${stageValueEl.textContent} (${timeText})`;
    }

    if (plant.stage >= 2) {
        harvestBtn.disabled = false;
    } else {
        harvestBtn.disabled = true;
    }

    app.style.display = 'flex';
    setTimeout(() => {
        app.classList.add('visible');
    }, 10);
}

function closeUI() {
    app.classList.remove('visible');
    setTimeout(() => {
        app.style.display = 'none';
        fetch(`https://${GetParentResourceName()}/close`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json; charset=UTF-8' },
            body: JSON.stringify({})
        });
    }, 300);
}

closeBtn.addEventListener('click', closeUI);

harvestBtn.addEventListener('click', () => {
    if (currentPlantId) {
        fetch(`https://${GetParentResourceName()}/harvest`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json; charset=UTF-8' },
            body: JSON.stringify({ plantId: currentPlantId })
        });
        closeUI();
    }
});

document.addEventListener('keyup', (e) => {
    if (e.key === 'Escape') {
        closeUI();
    }
});
