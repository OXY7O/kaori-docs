import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import test from 'node:test';

const workflow = (name) => readFileSync(`.github/workflows/${name}.yml`, 'utf8');

function job(source, name) {
  const lines = source.split('\n');
  const start = lines.findIndex((line) => line === `  ${name}:`);
  assert.notEqual(start, -1, `missing job ${name}`);
  const end = lines.findIndex(
    (line, index) => index > start && /^  [a-z][a-z0-9-]*:$/.test(line),
  );
  return lines.slice(start, end === -1 ? undefined : end).join('\n');
}

test('external fork proposals only receive unprivileged hosted feedback', () => {
  const fork = workflow('community-fork-check');
  const validation = job(fork, 'fork-validation');
  assert.match(fork, /pull_request:/);
  assert.match(fork, /contents: read/);
  assert.doesNotMatch(fork, /pull_request_target:|workflow_run:|secrets\./);
  assert.doesNotMatch(validation, /^\s+runs-on:\s*\[self-hosted/m);
  assert.match(validation, /head\.repo\.full_name != github\.repository/);
  assert.match(validation, /runs-on: ubuntu-24\.04/);
  assert.match(validation, /pull_request\.head\.sha/);
  assert.match(validation, /persist-credentials: false/);
  assert.match(validation, /npm ci --ignore-scripts/);
});

test('required Docs Route Checks must fail untrusted forks on a hosted runner', () => {
  const developer = workflow('developer-check');
  const route = job(developer, 'route');
  assert.match(route, /name: Route Checks/);
  assert.ok(route.includes('runs-on: ubuntu-24.04'));
  assert.doesNotMatch(route, /^    if:/m);
  assert.ok(route.includes('HEAD_REPO:'));
  assert.ok(route.includes('head.repo.full_name'));
  assert.ok(route.includes('Fork PR cannot enter the trusted Developer Check'));
  const validation = route.indexOf(
    'Require same-repository issue-linked branch before checkout',
  );
  const checkout = route.indexOf('Checkout exact pull-request head');
  assert.ok(validation > -1 && checkout > validation);
  assert.match(job(developer, 'targeted'), /needs: route/);
});

test('Docs promotion fails untrusted PRs before allocating privileged jobs', () => {
  const quality = workflow('quality');
  const promotion = job(quality, 'promotion-source');
  assert.match(promotion, /name: Promotion Policy/);
  assert.ok(promotion.includes('runs-on: ubuntu-24.04'));
  assert.doesNotMatch(promotion, /^    if:/m);
  assert.ok(promotion.includes('HEAD_REPO:'));
  assert.ok(promotion.includes('head.repo.full_name'));
  assert.ok(promotion.includes('Only kaori/staging may open a promotion PR to main'));
  assert.match(job(quality, 'validation-profile'), /needs: promotion-source/);
  assert.match(
    job(quality, 'full-admission'),
    /needs: \[promotion-source, validation-profile\]/,
  );
});

test('Docs publisher requires approved Apache-2.0 source licensing without weakening RC gates', () => {
  const script = readFileSync('scripts/release/publish-candidate.sh', 'utf8');
  const publisher = workflow('publish-staging-image');
  const rootLicense = readFileSync('LICENSE', 'utf8');
  const contentLicense = readFileSync('CONTENT_LICENSE.md', 'utf8');
  assert.match(rootLicense, /^Apache License\nVersion 2\.0, January 2004/);
  assert.match(script, /\$\{APP_LICENSE:-\}" == Apache-2\.0/);
  assert.match(script, /grep -Fxq 'Apache License' LICENSE/);
  assert.match(script, /SPDXRef-KAORI-Docs-Source/);
  assert.match(script, /SPDX project source license unverified/);
  assert.match(script, /KAORI_DOCS_RC_APPROVED:\$sha:\$tag/);
  assert.match(publisher, /APP_LICENSE=Apache-2\.0/);
  assert.match(contentLicense, /creativecommons\.org\/licenses\/by\/4\.0\/legalcode\.en/);
});

test('approved legal notice files route as docs-only while unknown paths remain blocked', () => {
  const developer = workflow('developer-check');
  assert.match(developer, /README\.md\|LICENSE\|NOTICE\|CONTENT_LICENSE\.md/);
  assert.match(developer, /Unrecognized change path; fail closed/);
});
