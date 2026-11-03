import React from 'react';

export type DocsIconName =
  | 'arrow-right'
  | 'arrow-up-right'
  | 'book-open'
  | 'box'
  | 'check'
  | 'clock'
  | 'database'
  | 'file-text'
  | 'info'
  | 'layers'
  | 'network'
  | 'server'
  | 'shield-check'
  | 'terminal'
  | 'wrench';

interface Props {
  name: DocsIconName;
  size?: number;
  className?: string;
}

const paths: Record<DocsIconName, React.ReactNode> = {
  'arrow-right': <path d="M5 12h14m-7-7 7 7-7 7" />,
  'arrow-up-right': <path d="M7 17 17 7M7 7h10v10" />,
  'book-open': (
    <>
      <path d="M12 7v14" />
      <path d="M3 18V5a2 2 0 0 1 2-2h3a4 4 0 0 1 4 4 4 4 0 0 1 4-4h3a2 2 0 0 1 2 2v13a2 2 0 0 0-2-2h-3a4 4 0 0 0-4 4 4 4 0 0 0-4-4H5a2 2 0 0 0-2 2Z" />
    </>
  ),
  box: (
    <>
      <path d="m12 3 9 5-9 5-9-5 9-5Z" />
      <path d="M3 8v8l9 5 9-5V8M12 13v8" />
    </>
  ),
  check: <path d="m5 12 4 4L19 6" />,
  clock: (
    <>
      <circle cx="12" cy="12" r="10" />
      <path d="M12 6v6l4 2" />
    </>
  ),
  database: (
    <>
      <ellipse cx="12" cy="5" rx="9" ry="3" />
      <path d="M3 5v14c0 1.7 4 3 9 3s9-1.3 9-3V5M3 12c0 1.7 4 3 9 3s9-1.3 9-3" />
    </>
  ),
  'file-text': (
    <>
      <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8Z" />
      <path d="M14 2v6h6M8 13h8M8 17h6" />
    </>
  ),
  info: (
    <>
      <circle cx="12" cy="12" r="10" />
      <path d="M12 11v5M12 7h.01" />
    </>
  ),
  layers: <path d="m12 2 10 6-10 6L2 8l10-6ZM2 12l10 6 10-6M2 16l10 6 10-6" />,
  network: (
    <>
      <rect x="9" y="2" width="6" height="6" rx="1" />
      <rect x="2" y="16" width="6" height="6" rx="1" />
      <rect x="16" y="16" width="6" height="6" rx="1" />
      <path d="M12 8v4M5 16v-4h14v4" />
    </>
  ),
  server: (
    <>
      <rect x="3" y="2" width="18" height="8" rx="2" />
      <rect x="3" y="14" width="18" height="8" rx="2" />
      <path d="M7 6h.01M7 18h.01" />
    </>
  ),
  'shield-check': (
    <>
      <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10Z" />
      <path d="m9 12 2 2 4-4" />
    </>
  ),
  terminal: (
    <>
      <rect x="2" y="3" width="20" height="18" rx="2" />
      <path d="m6 9 4 3-4 3M12 16h5" />
    </>
  ),
  wrench: (
    <>
      <path d="M14.7 6.3a5 5 0 0 0-6.4 6.4L3 17.6V21h3.4l5.3-5.3a5 5 0 0 0 6.4-6.4L15 12l-3-3 2.7-2.7Z" />
    </>
  ),
};

export default function DocsIcon({name, size = 20, className}: Props): React.JSX.Element {
  return (
    <svg
      aria-hidden="true"
      className={className}
      fill="none"
      focusable="false"
      height={size}
      stroke="currentColor"
      strokeLinecap="round"
      strokeLinejoin="round"
      strokeWidth="1.7"
      viewBox="0 0 24 24"
      width={size}
    >
      {paths[name]}
    </svg>
  );
}
