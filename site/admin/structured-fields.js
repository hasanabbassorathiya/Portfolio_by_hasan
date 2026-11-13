class StructuredField {
  constructor(root) {
    this.root = root;
    this.input = root.querySelector('[name]');
    this.list = root.querySelector('[data-items]');
    this.shape = root.dataset.shape;
    this.images = root.dataset.images === '1';
    this.rows = [];
    this.dragState = null;
    this.setupEventListeners();
    this.set(null);
  }

  setupEventListeners() {
    const addBtn = this.root.querySelector('[data-add]');
    if (addBtn) {
      addBtn.addEventListener('click', () => {
        this.append(this.shape === 'list' ? '' : ['', '']);
        this.list.lastElementChild?.querySelector('input')?.focus();
      });
    }
  }

  set(raw) {
    const value = typeof raw === 'string' && raw !== '' ? JSON.parse(raw) : raw;
    const scalar = (item) => typeof item === 'string' || typeof item === 'number';
    let rows = [];
    if (value != null && value !== '') {
      if (this.shape === 'object') {
        if (typeof value !== 'object' || (Array.isArray(value) && value.length > 0)) throw new Error('Expected key/value data.');
        rows = Object.entries(value);
      } else {
        if (!Array.isArray(value)) throw new Error('Expected a list.');
        rows = value;
      }
      if (!rows.every((row) => this.shape === 'list' ? scalar(row) : Array.isArray(row) && row.length === 2 && row.every(scalar))) {
        throw new Error('This field contains nested data that cannot be edited here.');
      }
    }
    this.rows = rows;
    this.input.value = value == null || value === '' ? '' : JSON.stringify(value);
    this.render();
  }

  append(value) {
    this.rows.push(value);
    this.changed();
    this.render();
  }

  changed() {
    this.input.value = JSON.stringify(this.shape === 'object' ? Object.fromEntries(this.rows) : this.rows);
    this.input.dispatchEvent(new Event('input', { bubbles: true }));
  }

  validate() {
    if (this.shape !== 'object') return '';
    const keys = this.rows.map(([key]) => String(key).trim());
    if (keys.some((key) => !key)) return 'Enter a key for every row, or remove the unused row.';
    if (new Set(keys).size !== keys.length) return 'Keys must be unique. Rename or remove the duplicate.';
    return '';
  }

  render() {
    this.list.replaceChildren();
    if (!this.rows.length) {
      const empty = document.createElement('p');
      empty.className = 'field-help structured-empty';
      empty.textContent = this.images ? 'No screenshots yet. Upload images to get started.' : 'No items yet.';
      this.list.append(empty);
      return;
    }

    this.rows.forEach((value, index) => {
      const row = this.createRow(value, index);
      this.list.append(row);
    });

    this.attachDragHandlers();
  }

  createRow(value, index) {
    const row = document.createElement('div');
    row.className = 'structured-row';
    row.draggable = true;
    row.dataset.index = index;

    const inputs = document.createElement('div');
    inputs.className = 'structured-inputs';

    if (this.images) {
      const preview = document.createElement('img');
      preview.alt = `Screenshot ${index + 1}`;
      preview.className = 'structured-preview';
      preview.loading = 'lazy';
      preview.referrerPolicy = 'no-referrer';
      this.preview(preview, value);
      row.append(preview);
    }

    const values = this.shape === 'list' ? [value] : value;
    values.forEach((part, column) => {
      const label = document.createElement('label');
      label.className = 'structured-label';
      const caption = document.createElement('span');
      const title = this.shape === 'list' ? (this.images ? 'Image path' : 'Item') : column === 1 ? 'Value' : this.shape === 'object' ? 'Key' : 'Label';
      caption.textContent = `${title} ${index + 1}`;
      const input = document.createElement('input');
      input.type = 'text';
      input.value = part;
      input.addEventListener('input', () => {
        if (this.shape === 'list') this.rows[index] = input.value;
        else this.rows[index][column] = input.value;
        if (this.images) {
          const img = row.querySelector('.structured-preview');
          if (img) this.preview(img, input.value);
        }
        this.changed();
      });
      label.append(caption, input);
      inputs.append(label);
    });

    row.append(inputs);
    row.append(this.createActions(index));

    return row;
  }

  createActions(index) {
    const actions = document.createElement('div');
    actions.className = 'structured-actions';

    for (const [text, direction, word] of [['↑', -1, 'up'], ['↓', 1, 'down'], ['✕', 0, 'remove']]) {
      const button = document.createElement('button');
      button.type = 'button';
      button.className = 'btn-sm';
      button.textContent = text;
      button.setAttribute('aria-label', direction ? `Move item ${index + 1} ${word}` : `Remove item ${index + 1}`);
      const target = index + direction;
      button.disabled = direction !== 0 && (target < 0 || target >= this.rows.length);

      button.addEventListener('click', (e) => {
        e.stopPropagation();
        if (direction) {
          [this.rows[index], this.rows[target]] = [this.rows[target], this.rows[index]];
        } else {
          this.rows.splice(index, 1);
        }
        this.changed();
        this.render();
        if (direction !== 0) this.list.children[target]?.focus();
      });
      actions.append(button);
    }

    return actions;
  }

  attachDragHandlers() {
    this.list.querySelectorAll('.structured-row').forEach((row, index) => {
      row.addEventListener('dragstart', (e) => {
        this.dragState = index;
        e.dataTransfer.effectAllowed = 'move';
        e.dataTransfer.setData('text/plain', index);
        row.classList.add('dragging');
      });

      row.addEventListener('dragover', (e) => {
        e.preventDefault();
        e.dataTransfer.dropEffect = 'move';
      });

      row.addEventListener('drop', (e) => {
        e.preventDefault();
        const dropIndex = parseInt(e.dataTransfer.getData('text/plain'), 10);
        if (!isNaN(dropIndex) && dropIndex !== index) {
          [this.rows[dropIndex], this.rows[index]] = [this.rows[index], this.rows[dropIndex]];
          this.changed();
          this.render();
        }
        this.dragState = null;
      });

      row.addEventListener('dragend', () => {
        row.classList.remove('dragging');
        this.dragState = null;
      });

      row.setAttribute('tabindex', '0');
      row.setAttribute('role', 'listitem');
      row.setAttribute('aria-grabbed', 'false');
    });
  }

  preview(img, value) {
    const path = String(value).trim();
    const allowed = /^\/(?!\/)/.test(path) || /^https?:\/\//i.test(path);
    img.hidden = !allowed;
    if (allowed) img.src = path;
    else img.removeAttribute('src');
  }
}
