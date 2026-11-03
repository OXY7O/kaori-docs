import {existsSync, readFileSync, readdirSync, statSync} from 'node:fs';
import {join} from 'node:path';

export type PublishedApplicationLine = {
  line: string;
  application_release_tag: string;
  application_release_url: string;
  application_source_sha: string;
  application_image_digest: string;
  application_manifest_sha256: string;
  docs_accepted_snapshot_sha: string;
  docs_approval_url: string;
};

const shaPattern = /^[a-f0-9]{40}$/;
const digestPattern = /^sha256:[a-f0-9]{64}$/;
const approvalPattern =
  /^https:\/\/github\.com\/OXY7O\/kaori-docs\/issues\/15#issuecomment-[1-9][0-9]*$/;

function isObject(value: unknown): value is Record<string, unknown> {
  return value !== null && typeof value === 'object' && !Array.isArray(value);
}

function gate(condition: boolean, description: string): void {
  if (!condition) {
    throw new Error('Docs #15 publication gate: ' + description);
  }
}

function readJson(path: string): unknown {
  gate(existsSync(path), 'missing ' + path);
  return JSON.parse(readFileSync(path, 'utf8')) as unknown;
}

function containsDraft(folder: string): boolean {
  return readdirSync(folder).some((name) => {
    const file = join(folder, name);
    if (statSync(file).isDirectory()) {
      return containsDraft(file);
    }
    return (
      /\.(md|mdx)$/.test(file) && /^draft:\s*true\s*$/m.test(readFileSync(file, 'utf8'))
    );
  });
}

// Strict static checks run in the existing Docusaurus build gate.
// Actual stable app release/digest and Docs approval still need independent
// GitHub/OCI verification before any nonempty mapping is reviewed.
export function resolvePublishedApplicationDocs(
  root: string = process.cwd(),
): PublishedApplicationLine[] {
  const raw = readJson(join(root, 'docs', 'PUBLISHED_VERSIONS.json'));
  gate(isObject(raw), 'mapping must be an object');
  if (!isObject(raw)) {
    return [];
  }
  gate(raw.schema_version === 1, 'unsupported mapping schema');
  gate(
    raw.publication_state === 'awaiting-release' || raw.publication_state === 'published',
    'invalid publication state',
  );
  gate(Array.isArray(raw.published), 'published must be an array');
  if (!Array.isArray(raw.published)) {
    return [];
  }

  const versions = readJson(join(root, 'versions.json'));
  gate(
    Array.isArray(versions) &&
      versions.every((version: unknown) => typeof version === 'string'),
    'versions.json must contain native Docusaurus version names',
  );

  if (raw.published.length === 0) {
    gate(
      raw.publication_state === 'awaiting-release',
      'empty mapping cannot assert published state',
    );
    gate((versions as string[]).length === 0, 'unmapped versions are forbidden');
    const dir = join(root, 'versioned_docs');
    gate(
      !existsSync(dir) || readdirSync(dir).length === 0,
      'unaccepted snapshots cannot enter versioned_docs',
    );
    return [];
  }

  gate(raw.publication_state === 'published', 'approval state missing');
  const published: PublishedApplicationLine[] = [];
  const seen = new Set<string>();
  for (const candidate of raw.published) {
    gate(isObject(candidate), 'published mapping entry must be an object');
    const entry = candidate as PublishedApplicationLine;
    const match =
      typeof entry.application_release_tag === 'string'
        ? /^v([0-9]+)\.([0-9]+)\.([0-9]+)$/.exec(entry.application_release_tag)
        : null;
    gate(match !== null, 'stable product SemVer tag required');
    gate(
      typeof entry.line === 'string' &&
        entry.line === 'v' + match?.[1] + '.' + match?.[2] &&
        !seen.has(entry.line),
      'duplicate or inconsistent Major.Minor mapping',
    );
    gate(
      entry.application_release_url ===
        'https://github.com/OXY7O/KAORI/releases/tag/' + entry.application_release_tag,
      'canonical application release URL required',
    );
    gate(
      typeof entry.application_source_sha === 'string' &&
        shaPattern.test(entry.application_source_sha) &&
        typeof entry.docs_accepted_snapshot_sha === 'string' &&
        shaPattern.test(entry.docs_accepted_snapshot_sha),
      'exact application and Docs source SHAs required',
    );
    gate(
      typeof entry.application_image_digest === 'string' &&
        digestPattern.test(entry.application_image_digest) &&
        typeof entry.application_manifest_sha256 === 'string' &&
        digestPattern.test(entry.application_manifest_sha256),
      'signed product image and manifest digest references required',
    );
    gate(
      typeof entry.docs_approval_url === 'string' &&
        approvalPattern.test(entry.docs_approval_url),
      'write-authorized issue #15 approval reference required',
    );
    const dir = join(root, 'versioned_docs', 'version-' + entry.line);
    gate(existsSync(dir) && statSync(dir).isDirectory(), 'snapshot missing');
    gate(!containsDraft(dir), 'a published snapshot contains a draft');
    gate(
      existsSync(
        join(root, 'versioned_sidebars', 'version-' + entry.line + '-sidebars.json'),
      ),
      'native versioned sidebar missing',
    );
    seen.add(entry.line);
    published.push(entry);
  }

  gate(
    JSON.stringify(versions) === JSON.stringify(published.map((entry) => entry.line)),
    'versions.json differs from the accepted ordered mapping',
  );
  const folders = readdirSync(join(root, 'versioned_docs'))
    .filter((name) => name.startsWith('version-'))
    .sort();
  gate(
    JSON.stringify(folders) ===
      JSON.stringify(published.map((entry) => 'version-' + entry.line).sort()),
    'unmapped historical version snapshots are forbidden',
  );
  return published;
}
