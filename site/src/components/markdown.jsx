import React from 'react';
import { parseBlocks, parseInline } from '../lib/markdown';

function Inline({ text }) {
  return parseInline(text).map((token, i) => {
    if (token.type === 'strong') return <strong key={i}>{token.text}</strong>;
    if (token.type === 'em') return <em key={i}>{token.text}</em>;
    if (token.type === 'code') return <code key={i}>{token.text}</code>;
    if (token.type === 'link')
      return (
        <a key={i} href={token.href} rel="noreferrer" target={token.href.startsWith('http') ? '_blank' : undefined}>
          {token.text}
        </a>
      );
    return <React.Fragment key={i}>{token.text}</React.Fragment>;
  });
}

export function Markdown({ source }) {
  return parseBlocks(source).map((block, i) => {
    switch (block.type) {
      case 'h2':
        return (
          <h2 key={i} id={block.id}>
            <Inline text={block.text} />
          </h2>
        );
      case 'h3':
        return (
          <h3 key={i} id={block.id}>
            <Inline text={block.text} />
          </h3>
        );
      case 'p':
        return (
          <p key={i}>
            <Inline text={block.text} />
          </p>
        );
      case 'ul':
        return (
          <ul key={i}>
            {block.items.map((item, j) => (
              <li key={j}>
                <Inline text={item} />
              </li>
            ))}
          </ul>
        );
      case 'ol':
        return (
          <ol key={i}>
            {block.items.map((item, j) => (
              <li key={j}>
                <Inline text={item} />
              </li>
            ))}
          </ol>
        );
      case 'quote':
        return (
          <blockquote key={i}>
            <Inline text={block.text} />
          </blockquote>
        );
      case 'code':
        return (
          <pre key={i} tabIndex={0} role="region" aria-label="Code sample">
            <code>{block.code}</code>
          </pre>
        );
      case 'table':
        return (
          <div key={i} className="table-wrap" tabIndex={0} role="region" aria-label="Table">
            <table>
              <thead>
                <tr>
                  {block.head.map((cell, j) => (
                    <th key={j}>
                      <Inline text={cell} />
                    </th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {block.rows.map((row, j) => (
                  <tr key={j}>
                    {row.map((cell, k) => (
                      <td key={k}>
                        <Inline text={cell} />
                      </td>
                    ))}
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        );
      case 'hr':
        return <hr key={i} />;
      default:
        return null;
    }
  });
}
