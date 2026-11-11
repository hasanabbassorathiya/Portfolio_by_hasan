class StructuredField {
  constructor(root) {
    this.root = root;
    this.input = root.querySelector('[name]');
    this.list = root.querySelector('[data-items]');
    this.shape = root.dataset.shape;
    this.images = root.dataset.images === '1';
    this.rows = [];
    root.querySelector('[data-add]').addEventListener('click', () => {
      this.append(this.shape === 'list' ? '' : ['', '']);
      this.list.lastElementChild.querySelector('input').focus();
    });
    this.set(null);
  }

  set(raw) {
    const value = typeof raw === 'string' && raw !== '' ? JSON.parse(raw) : raw;
    const scalar = (item) => typeof item === 'string' || typeof item === 'number';
    let rows = [];
    if (value != null && value !== '') {
      if (this.shape === 'object') {
        // PHP encodes an empty associative array as [], including decoded {} values.
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
    }
    this.rows.forEach((value, index) => {
      const row = document.createElement('div');
      row.className = 'structured-row';
      const inputs = document.createElement('div');
      inputs.className = 'structured-inputs';
      let preview;
      if (this.images) {
        preview = document.createElement('img');
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
          if (preview) this.preview(preview, input.value);
          this.changed();
        });
        label.append(caption, input);
        inputs.append(label);
      });
      row.append(inputs);
      const actions = document.createElement('div');
      actions.className = 'structured-actions';
      for (const [text, direction] of [['Up', -1], ['Down', 1], ['Remove', 0]]) {
        const button = document.createElement('button');
        button.type = 'button';
        button.className = 'btn-sm';
        button.textContent = text;
        button.setAttribute('aria-label', direction ? `Move item ${index + 1} ${text.toLowerCase()}` : `Remove item ${index + 1}`);
        const target = index + direction;
        button.disabled = direction !== 0 && (target < 0 || target >= this.rows.length);
        button.addEventListener('click', () => {
          if (direction) [this.rows[index], this.rows[target]] = [this.rows[target], this.rows[index]];
          else this.rows.splice(index, 1);
          this.changed();
          this.render();
          const next = this.list.children[Math.min(target, this.rows.length - 1)];
          (next?.querySelector('input') || this.root.querySelector('[data-add]')).focus();
        });
        actions.append(button);
      }
      row.append(actions);
      this.list.append(row);
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
