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

function initTunnels(gridContainer) {
  const showTunnelsChk = document.getElementById('showTunnels');
  const tunnelOverlay = gridContainer.querySelector('.tunnel-overlay');
  if (!tunnelOverlay) {
    return;
  }

  const svg = tunnelOverlay.querySelector('svg');
  if (!svg) {
    return;
  }

  svg.setAttribute('width', gridContainer.clientWidth);
  svg.setAttribute('height', gridContainer.clientHeight);
  svg.setAttribute('viewBox', `0 0 ${gridContainer.clientWidth} ${gridContainer.clientHeight}`);

  tunnelOverlay.style.display = 'none';

  if (showTunnelsChk) {
    showTunnelsChk.addEventListener('change', () => {
      tunnelOverlay.style.display = showTunnelsChk.checked ? 'block' : 'none';
    });
  }

  const tunnelsData = window.TUNNELS || {};
  const containerRect = gridContainer.getBoundingClientRect();
  Object.entries(tunnelsData).forEach(([from, to]) => {
    const [fromRow, fromCol] = from.split(coordSeparator);
    const [toRow, toCol] = to.split(coordSeparator);

    const item1 = gridContainer.querySelector(`[data-coord="${fromRow}_${fromCol}"]`);
    if (!item1) {
        console.warn(`[tunnel] Could not find grid element ${fromRow}_${fromCol}`);
        return;
    }
    const item2 = gridContainer.querySelector(`[data-coord="${toRow}_${toCol}"]`);
    if (!item2) {
        console.warn(`[tunnel] Could not find grid element ${toRow}_${toCol}`);
        return;
    }

    const center1 = getCenter(item1, containerRect);
    const center2 = getCenter(item2, containerRect);
    svg.appendChild(createTunnelLine(center1, center2, 'black', '6'));
    svg.appendChild(createTunnelLine(center1, center2, 'yellow', '2'));
  });
}

function initGrid() {
  if (typeof document === 'undefined') {
    return;
  }

  const gridContainer = document.querySelector('.grid-container');
  if (!gridContainer) {
    return;
  }

  const notesData = window.COORD_NOTES || {};

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
      // Insert grid item without referencing tunnelOverlay
      gridContainer.appendChild(gridItem);
    }
  }

  // Initialize tunnels after grid is set up
  initTunnels(gridContainer);
}

if (typeof window !== 'undefined') {
  window.initGrid = initGrid;
  window.initTunnels = initTunnels;
  window.getCenter = getCenter;
  window.createTunnelLine = createTunnelLine;
}

if (typeof module !== 'undefined' && module.exports) {
  module.exports = { initGrid, initTunnels, getCenter, createTunnelLine };
}

if (typeof document !== 'undefined') {
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initGrid);
  } else {
    initGrid();
  }
}
