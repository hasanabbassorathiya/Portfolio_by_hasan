const form = document.getElementById('editor-form');
const editor = document.getElementById('editor');
const errorEl = document.getElementById('form-error');
const statusEl = document.getElementById('editor-status');
const titleEl = document.getElementById('editor-title');
const saveBtn = document.getElementById('save-btn');
const structured = new Map([...form.querySelectorAll('[data-structured]')].map((root) => [root.dataset.structured, new StructuredField(root)]));
let editingRef = null;
let dirty = false;
let busy = '';
let ready = false;
let loadVersion = 0;

if (sessionStorage.getItem('cms:saved') === ENTITY) {
  document.getElementById('page-status').textContent = 'Record saved. Changes are available on the next public page load.';
  sessionStorage.removeItem('cms:saved');
}

function setBusy(value) {
  busy = value;
  form.setAttribute('aria-busy', String(Boolean(value)));
  form.querySelectorAll('.field-group').forEach((group) => { group.disabled = Boolean(value) || !ready; });
  saveBtn.disabled = Boolean(value) || !ready;
  statusEl.textContent = value || (dirty ? 'Unsaved changes' : '');
}

function clearErrors() {
  errorEl.textContent = '';
  form.querySelectorAll('[data-field-error]').forEach((el) => { el.textContent = ''; });
  form.querySelectorAll('[aria-invalid]').forEach((el) => el.removeAttribute('aria-invalid'));
}

function showError(message, name) {
  errorEl.textContent = message;
  const named = form.elements.namedItem(name || '');
  if (!named) return;
  const field = named.closest('.field');
  const control = named.type === 'hidden' ? field.querySelector('input:not([type=hidden]):not([type=file]), button') : named;
  let note = field.querySelector('[data-field-error]');
  if (!note) {
    note = document.createElement('small');
    note.dataset.fieldError = name;
    note.id = `error-${name}`;
    note.className = 'form-error';
    field.append(note);
  }
  note.textContent = message;
  control.setAttribute('aria-invalid', 'true');
  control.setAttribute('aria-describedby', note.id);
  control.focus();
}

function markDirty() {
  dirty = true;
  if (!busy) statusEl.textContent = 'Unsaved changes';
}
form.addEventListener('input', markDirty);
form.addEventListener('change', markDirty);
window.addEventListener('beforeunload', (event) => {
  if (!dirty && !['Saving…', 'Uploading…'].includes(busy)) return;
  event.preventDefault();
  event.returnValue = '';
});

function canLeave() {
  if (busy === 'Saving…' || busy === 'Uploading…') {
    errorEl.textContent = 'Wait for the current operation to finish before switching records.';
    return false;
  }
  return !dirty || confirm('Discard your unsaved changes?');
}

function setValue(name, value) {
  const el = form.elements.namedItem(name);
  if (!el) return;
  if (structured.has(name)) structured.get(name).set(value);
  else if (el.type === 'checkbox') el.checked = String(value) === '1' || value === true;
  else el.value = value ?? '';
  if (el.dataset.image === '1') updatePreview(name, el.value);
  if (name === 'k') el.dataset.previous = value ?? '';
}

function updatePreview(name, value) {
  const img = form.querySelector(`[data-preview="${name}"]`);
  if (!img) return;
  const path = value.trim();
  const allowed = /^\/(?!\/)/.test(path) || /^https?:\/\//i.test(path);
  img.hidden = !allowed;
  if (allowed) img.src = path;
  else img.removeAttribute('src');
}

form.querySelectorAll('[data-image="1"]').forEach((input) => {
  input.setAttribute('aria-label', input.closest('.field').querySelector('span').textContent);
  input.addEventListener('input', () => updatePreview(input.name, input.value));
});

form.querySelectorAll('[data-upload]').forEach((button) => {
  const name = button.dataset.upload;
  const fileInput = form.querySelector(`[data-file="${name}"]`);
  button.addEventListener('click', () => fileInput.click());
  fileInput.addEventListener('change', async () => {
    const files = [...fileInput.files];
    if (!files.length || busy || !ready) return;
    clearErrors();
    setBusy('Uploading…');
    const failures = [];
    for (const file of files) {
      try {
        if (file.size === 0 || file.size > 8 * 1024 * 1024) throw new Error('Choose an image between 1 byte and 8 MB.');
        const body = new FormData();
        body.append('file', file);
        body.append('folder', ENTITY);
        const res = await fetch('../api/upload.php', { method: 'POST', headers: { 'X-CSRF-Token': CSRF }, body });
        const data = await res.json().catch(() => ({}));
        if (!res.ok) throw new Error(data.error || 'Upload failed. Try again.');
        if (typeof data.path !== 'string' || !data.path.startsWith('/media/uploads/')) throw new Error('The upload returned no usable image path.');
        if (structured.has(name)) structured.get(name).append(data.path);
        else { setValue(name, data.path); markDirty(); }
      } catch (error) {
        failures.push(`${file.name}: ${error.message}`);
      }
    }
    fileInput.value = '';
    setBusy('');
    if (failures.length) showError(failures.join(' '), name);
  });
});

async function openEditor(ref) {
  if (!canLeave()) return;
  const version = ++loadVersion;
  editingRef = ref ?? null;
  dirty = false;
  ready = false;
  form.reset();
  for (const widget of structured.values()) widget.set(null);
  if (IS_KV) form.elements.k.dataset.previous = '';
  clearErrors();
  form.querySelectorAll('[data-preview]').forEach((img) => { img.hidden = true; img.removeAttribute('src'); });
  titleEl.textContent = editingRef !== null ? 'Edit ' + (IS_KV ? editingRef : '#' + editingRef) : 'New record';
  saveBtn.textContent = editingRef !== null ? 'Save changes' : 'Create';
  editor.hidden = false;
  setBusy('Loading…');
  try {
    if (editingRef !== null) {
      const query = IS_KV ? `entity=profile&k=${encodeURIComponent(editingRef)}` : `entity=${ENTITY}&id=${editingRef}`;
      const res = await fetch(`../api/crud.php?${query}`, { headers: { Accept: 'application/json' } });
      if (!res.ok) throw new Error('Could not load that record. Retry opening it; sign in again if your session expired.');
      const row = await res.json();
      if (version !== loadVersion) return;
      for (const [key, value] of Object.entries(row)) {
        try { setValue(key, value); }
        catch { throw new Error(`Could not load “${key}” safely. The saved data has not been changed.`); }
      }
    }
    ready = true;
  } catch (error) {
    if (version !== loadVersion) return;
    errorEl.textContent = error.message.startsWith('Could not load') ? error.message : 'Could not load the record. Check your connection and try opening it again.';
  } finally {
    if (version === loadVersion) setBusy('');
  }
  if (version !== loadVersion) return;
  editor.scrollIntoView({ behavior: matchMedia('(prefers-reduced-motion: reduce)').matches ? 'instant' : 'smooth', block: 'start' });
  if (ready) form.querySelector('input:not([type=hidden]), textarea')?.focus({ preventScroll: true });
}

function closeEditor() {
  if (!canLeave()) return;
  ++loadVersion;
  dirty = false;
  ready = false;
  setBusy('');
  editor.hidden = true;
  editingRef = null;
  document.querySelector('.page-head button').focus();
}

form.addEventListener('submit', async (event) => {
  event.preventDefault();
  if (busy || !ready) return;
  clearErrors();
  for (const [name, widget] of structured) {
    const problem = widget.validate();
    if (problem) { showError(problem, name); return; }
  }
  const payload = {};
  for (const el of form.querySelectorAll('[name]')) {
    if (el.type === 'checkbox') { payload[el.name] = el.checked ? 1 : 0; continue; }
    const value = el.value.trim();
    payload[el.name] = (el.dataset.json === '1' || el.type === 'number') && value === '' ? null : value;
  }
  if (IS_KV) payload.previous_k = form.elements.k.dataset.previous || payload.k;
  const id = !IS_KV && editingRef !== null ? `&id=${editingRef}` : '';
  setBusy('Saving…');
  try {
    const res = await fetch(`../api/crud.php?entity=${ENTITY}${id}`, {
      method: editingRef !== null ? 'PUT' : 'POST',
      headers: { 'Content-Type': 'application/json', Accept: 'application/json', 'X-CSRF-Token': CSRF },
      body: JSON.stringify(payload),
    });
    if (res.ok) {
      dirty = false;
      setBusy('');
      sessionStorage.setItem('cms:saved', ENTITY);
      location.reload();
      return;
    }
    const data = await res.json().catch(() => ({}));
    setBusy('');
    showError(data.detail || data.error || 'Save failed. Your draft is still here; try again.', data.field);
  } catch {
    setBusy('');
    showError('Network error — your draft is still here. Check the connection and try again.');
  }
});
