const INLINE_RE = /(\*\*[^*]+\*\*|\*[^*]+\*|`[^`]+`|\[[^\]]+\]\([^)]+\))/g;

export function parseInline(text) {
  const tokens = [];
  let last = 0;
  let match;
  INLINE_RE.lastIndex = 0;
  while ((match = INLINE_RE.exec(text)) !== null) {
    if (match.index > last) tokens.push({ type: 'text', text: text.slice(last, match.index) });
    const raw = match[0];
    if (raw.startsWith('**')) {
      tokens.push({ type: 'strong', text: raw.slice(2, -2) });
    } else if (raw.startsWith('`')) {
      tokens.push({ type: 'code', text: raw.slice(1, -1) });
    } else if (raw.startsWith('[')) {
      const m = raw.match(/^\[([^\]]+)\]\(([^)]+)\)$/);
      tokens.push({ type: 'link', text: m[1], href: m[2] });
    } else {
      tokens.push({ type: 'em', text: raw.slice(1, -1) });
    }
    last = match.index + raw.length;
  }
  if (last < text.length) tokens.push({ type: 'text', text: text.slice(last) });
  return tokens;
}

export function slugify(text) {
  return text
    .toLowerCase()
    .replace(/[^a-z0-9\s-]/g, '')
    .trim()
    .replace(/\s+/g, '-');
}

const splitRow = (line) =>
  line
    .trim()
    .replace(/^\|/, '')
    .replace(/\|$/, '')
    .split('|')
    .map((cell) => cell.trim());

const isDividerRow = (line) =>
  line.includes('-') && splitRow(line).every((cell) => /^:?-{3,}:?$/.test(cell));

export function parseBlocks(md) {
  const lines = md.replace(/\r\n/g, '\n').split('\n');
  const blocks = [];
  let i = 0;

  while (i < lines.length) {
    const line = lines[i];

    if (!line.trim()) {
      i++;
      continue;
    }

    if (line.trim().startsWith('|') && lines[i + 1] && isDividerRow(lines[i + 1])) {
      const head = splitRow(line);
      const rows = [];
      i += 2;
      while (i < lines.length && lines[i].trim().startsWith('|')) {
        rows.push(splitRow(lines[i]));
        i++;
      }
      blocks.push({ type: 'table', head, rows });
      continue;
    }

    if (line.startsWith('```')) {
      const lang = line.slice(3).trim();
      const code = [];
      i++;
      while (i < lines.length && !lines[i].startsWith('```')) {
        code.push(lines[i]);
        i++;
      }
      i++;
      blocks.push({ type: 'code', lang, code: code.join('\n') });
      continue;
    }

    if (line.startsWith('### ')) {
      blocks.push({ type: 'h3', text: line.slice(4), id: slugify(line.slice(4)) });
      i++;
      continue;
    }
    if (line.startsWith('## ')) {
      blocks.push({ type: 'h2', text: line.slice(3), id: slugify(line.slice(3)) });
      i++;
      continue;
    }

    if (line.startsWith('> ')) {
      const quote = [];
      while (i < lines.length && lines[i].startsWith('> ')) {
        quote.push(lines[i].slice(2));
        i++;
      }
      blocks.push({ type: 'quote', text: quote.join(' ') });
      continue;
    }

    if (line.startsWith('- ')) {
      const items = [];
      while (i < lines.length && lines[i].startsWith('- ')) {
        items.push(lines[i].slice(2));
        i++;
      }
      blocks.push({ type: 'ul', items });
      continue;
    }

    if (/^\d+\.\s/.test(line)) {
      const items = [];
      while (i < lines.length && /^\d+\.\s/.test(lines[i])) {
        items.push(lines[i].replace(/^\d+\.\s/, ''));
        i++;
      }
      blocks.push({ type: 'ol', items });
      continue;
    }

    if (line.trim() === '---') {
      blocks.push({ type: 'hr' });
      i++;
      continue;
    }

    const para = [];
    while (
      i < lines.length &&
      lines[i].trim() &&
      !lines[i].startsWith('#') &&
      !lines[i].startsWith('- ') &&
      !lines[i].startsWith('> ') &&
      !lines[i].startsWith('|') &&
      !lines[i].startsWith('```') &&
      !/^\d+\.\s/.test(lines[i]) &&
      lines[i].trim() !== '---'
    ) {
      para.push(lines[i]);
      i++;
    }
    blocks.push({ type: 'p', text: para.join(' ') });
  }

  return blocks;
}

export function plainText(md) {
  return md
    .replace(/```[\s\S]*?```/g, ' ')
    .replace(/[#>*`_-]/g, ' ')
    .replace(/\[([^\]]+)\]\([^)]+\)/g, '$1')
    .replace(/\s+/g, ' ')
    .trim();
}

export function readingTime(md) {
  const words = plainText(md).split(' ').filter(Boolean).length;
  return Math.max(3, Math.round(words / 220));
}

export function escapeHtml(value) {
  return String(value)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

export function inlineToHtml(text) {
  return parseInline(text)
    .map((t) => {
      if (t.type === 'strong') return `<strong>${escapeHtml(t.text)}</strong>`;
      if (t.type === 'em') return `<em>${escapeHtml(t.text)}</em>`;
      if (t.type === 'code') return `<code>${escapeHtml(t.text)}</code>`;
      if (t.type === 'link')
        return `<a href="${escapeHtml(t.href)}" rel="noreferrer">${escapeHtml(t.text)}</a>`;
      return escapeHtml(t.text);
    })
    .join('');
}

export function blocksToHtml(md) {
  return parseBlocks(md)
    .map((b) => {
      switch (b.type) {
        case 'h2':
          return `<h2 id="${b.id}">${inlineToHtml(b.text)}</h2>`;
        case 'h3':
          return `<h3 id="${b.id}">${inlineToHtml(b.text)}</h3>`;
        case 'p':
          return `<p>${inlineToHtml(b.text)}</p>`;
        case 'ul':
          return `<ul>${b.items.map((it) => `<li>${inlineToHtml(it)}</li>`).join('')}</ul>`;
        case 'ol':
          return `<ol>${b.items.map((it) => `<li>${inlineToHtml(it)}</li>`).join('')}</ol>`;
        case 'quote':
          return `<blockquote>${inlineToHtml(b.text)}</blockquote>`;
        case 'table': {
          const head = `<thead><tr>${b.head.map((c) => `<th>${inlineToHtml(c)}</th>`).join('')}</tr></thead>`;
          const body = b.rows.length
            ? `<tbody>${b.rows
                .map((row) => `<tr>${row.map((c) => `<td>${inlineToHtml(c)}</td>`).join('')}</tr>`)
                .join('')}</tbody>`
            : '';
          return `<div class="table-wrap" tabindex="0" role="region" aria-label="Table"><table>${head}${body}</table></div>`;
        }
        case 'code':
          return `<pre tabindex="0" role="region" aria-label="Code sample"><code>${escapeHtml(b.code)}</code></pre>`;
        case 'hr':
          return '<hr />';
        default:
          return '';
      }
    })
    .join('\n');
}
