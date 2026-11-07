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

test('fork source is denied before trusted Docs route runner allocation', () => {
  const developer = workflow('developer-check');
  const route = job(developer, 'route');
  assert.match(route, /^    if:.*head\.repo\.full_name == github\.repository/m);
  assert.match(route, /runs-on: \[self-hosted,/);
  assert.match(route, /Source branch must use canonical KAORI issue-linked type/);
  assert.match(job(developer, 'targeted'), /needs: route/);
});

test('Docs promotion rejects untrusted pull requests at job-level', () => {
  const quality = workflow('quality');
  const promotion = job(quality, 'promotion-source');
  assert.match(promotion, /^    if:.*github\.event_name != 'pull_request'/m);
  assert.match(promotion, /head\.repo\.full_name == github\.repository/);
  assert.match(promotion, /head\.ref == 'kaori\/staging'/);
  assert.match(promotion, /base\.ref == 'main'/);
  assert.match(promotion, /runs-on: \[self-hosted,/);
  assert.match(job(quality, 'validation-profile'), /needs: promotion-source/);
  assert.match(job(quality, 'full-admission'), /needs: \[promotion-source, validation-profile\]/);
});
