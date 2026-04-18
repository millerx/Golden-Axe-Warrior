const { initGrid, getCenter, createTunnelLine } = require('../image-grid');

describe('image-grid module', () => {
  beforeEach(() => {
    document.body.innerHTML = `
      <input type="checkbox" id="showTunnels">
      <div class="grid-container">
        <div class="tunnel-overlay"><svg></svg></div>
      </div>
    `;
    window.COORD_NOTES = {};
    window.TUNNELS = {};
  });

  test('creates a 15x15 grid of items', () => {
    initGrid();
    expect(document.querySelectorAll('.grid-item').length).toBe(225);
  });

  test('creates a tooltip when notes data contains a coordinate', () => {
    window.COORD_NOTES = { '1,A': 'Test note' };
    initGrid();

    const badge = document.querySelector('.coordinate-badge');
    expect(badge).not.toBeNull();
    expect(badge.textContent).toContain('1,A');
    const tooltip = badge.querySelector('.tooltip');
    expect(tooltip).not.toBeNull();
    expect(tooltip.textContent).toBe('1,A: Test note');
  });

  test('checkbox toggles tunnel overlay visibility', () => {
    initGrid();

    const overlay = document.querySelector('.tunnel-overlay');
    const checkbox = document.getElementById('showTunnels');
    expect(overlay.style.display).toBe('none');

    checkbox.checked = true;
    checkbox.dispatchEvent(new Event('change'));
    expect(overlay.style.display).toBe('block');
  });

  test('createTunnelLine returns an SVG line element with proper attributes', () => {
    const line = createTunnelLine({ x: 10, y: 20 }, { x: 30, y: 40 }, 'red', '4');
    expect(line.namespaceURI).toBe('http://www.w3.org/2000/svg');
    expect(line.getAttribute('x1')).toBe('10');
    expect(line.getAttribute('y1')).toBe('20');
    expect(line.getAttribute('x2')).toBe('30');
    expect(line.getAttribute('y2')).toBe('40');
    expect(line.getAttribute('stroke')).toBe('red');
    expect(line.getAttribute('stroke-width')).toBe('4');
  });

  test('getCenter computes center coordinates relative to container', () => {
    const item = { getBoundingClientRect: () => ({ left: 100, top: 120, width: 20, height: 30 }) };
    const containerRect = { left: 50, top: 100 };
    expect(getCenter(item, containerRect)).toEqual({ x: 60, y: 35 });
  });
});
