const gridSize = 15;
const coordSeparator = ',';

function getCenter(item, containerRect) {
  const rect = item.getBoundingClientRect();
  return {
    x: rect.left + rect.width / 2 - containerRect.left,
    y: rect.top + rect.height / 2 - containerRect.top,
  };
}

function createTunnelLine(point1, point2, stroke, strokeWidth) {
  const line = document.createElementNS('http://www.w3.org/2000/svg', 'line');
  line.setAttribute('x1', point1.x);
  line.setAttribute('y1', point1.y);
  line.setAttribute('x2', point2.x);
  line.setAttribute('y2', point2.y);
  line.setAttribute('stroke', stroke);
  line.setAttribute('stroke-width', strokeWidth);
  return line;
}

function initGrid({ gridContainer, checkbox, notesData = {}, tunnelsData = {} } = {}) {
  if (typeof gridContainer === 'string') {
    gridContainer = document.querySelector(gridContainer);
  }
  if (!gridContainer) {
    throw new Error('Grid container element is required.');
  }

  const tunnelOverlay = gridContainer.querySelector('.tunnel-overlay') || createTunnelOverlay(gridContainer);
  const svg = tunnelOverlay.querySelector('svg') || createTunnelSvg(tunnelOverlay);

  Array.from(gridContainer.children).forEach((child) => {
    if (!child.classList.contains('tunnel-overlay')) {
      gridContainer.removeChild(child);
    }
  });

  for (let row = 1; row <= gridSize; row++) {
    for (let colCode = 65; colCode < 65 + gridSize; colCode++) {
      const col = String.fromCharCode(colCode);
      const coordinate = `${row}${coordSeparator}${col}`;
      const gridItem = document.createElement('div');
      gridItem.className = 'grid-item';
      gridItem.setAttribute('data-coord', `${row}_${col}`);

      const img = document.createElement('img');
      img.src = `imgs/${row}_${col}.png`;
      img.loading = 'lazy';
      gridItem.appendChild(img);

      const badge = document.createElement('span');
      badge.className = 'coordinate-badge';
      badge.tabIndex = 0;
      badge.textContent = coordinate;

      const noteText = notesData[coordinate];
      if (noteText) {
        const tooltip = document.createElement('div');
        tooltip.className = 'tooltip';
        tooltip.textContent = `${coordinate}: ${noteText}`;
        badge.appendChild(tooltip);
      }

      gridItem.appendChild(badge);
      gridContainer.insertBefore(gridItem, tunnelOverlay);
    }
  }

  svg.setAttribute('width', gridContainer.clientWidth);
  svg.setAttribute('height', gridContainer.clientHeight);
  svg.setAttribute('viewBox', `0 0 ${gridContainer.clientWidth} ${gridContainer.clientHeight}`);

  tunnelOverlay.style.display = 'none';

  if (checkbox) {
    checkbox.addEventListener('change', () => {
      tunnelOverlay.style.display = checkbox.checked ? 'block' : 'none';
    });
  }

  const containerRect = gridContainer.getBoundingClientRect();
  Object.entries(tunnelsData).forEach(([from, to]) => {
    const [fromRow, fromCol] = from.split(coordSeparator);
    const [toRow, toCol] = to.split(coordSeparator);
    const item1 = gridContainer.querySelector(`[data-coord="${fromRow}_${fromCol}"]`);
    const item2 = gridContainer.querySelector(`[data-coord="${toRow}_${toCol}"]`);
    if (!item1 || !item2) {
      return;
    }

    const center1 = getCenter(item1, containerRect);
    const center2 = getCenter(item2, containerRect);
    svg.appendChild(createTunnelLine(center1, center2, 'black', '6'));
    svg.appendChild(createTunnelLine(center1, center2, 'yellow', '2'));
  });
}

function createTunnelOverlay(gridContainer) {
  const overlay = document.createElement('div');
  overlay.className = 'tunnel-overlay';
  const svg = createTunnelSvg(overlay);
  overlay.appendChild(svg);
  gridContainer.appendChild(overlay);
  return overlay;
}

function createTunnelSvg(overlay) {
  return document.createElementNS('http://www.w3.org/2000/svg', 'svg');
}

function startGrid() {
  if (typeof document === 'undefined') {
    return;
  }

  const gridContainer = document.querySelector('.grid-container');
  const checkbox = document.getElementById('showTunnels');
  const notesData = window.COORD_NOTES || {};
  const tunnelsData = window.TUNNELS || {};

  if (gridContainer) {
    initGrid({ gridContainer, checkbox, notesData, tunnelsData });
  }
}

if (typeof window !== 'undefined') {
  window.initGrid = initGrid;
  window.getCenter = getCenter;
  window.createTunnelLine = createTunnelLine;
}

if (typeof module !== 'undefined' && module.exports) {
  module.exports = { initGrid, getCenter, createTunnelLine };
}

if (typeof document !== 'undefined') {
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', startGrid);
  } else {
    startGrid();
  }
}
