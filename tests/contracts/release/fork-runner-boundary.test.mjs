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

test('Docs release jobs bind native approval environments before mutation', () => {
  const stable = job(workflow('quality'), 'stable-publication');
  const rc = job(workflow('publish-staging-image'), 'publish');
  const deploy = job(workflow('deploy-staging-host'), 'deploy');

  assert.match(stable, /environment:\n      name: production/);
  assert.match(stable, /github\.ref == 'refs\/heads\/main'/);
  assert.match(rc, /environment:\n      name: staging/);
  assert.match(rc, /refs\/heads\/kaori\/rc-request/);

  assert.match(deploy, /environment:\n      name:/);
  assert.match(deploy, /github\.event_name == 'workflow_run'/);
  assert.match(deploy, /github\.ref == 'refs\/heads\/main'/);
  assert.match(deploy, /&& 'production' \|\| 'staging'/);
  for (const name of [stable, rc, deploy]) {
    assert.ok(name.indexOf('    environment:') > -1);
    assert.ok(name.indexOf('    environment:') < name.indexOf('    steps:'));
  }

  assert.doesNotMatch(job(workflow('quality'), 'full-admission'), /^    environment:/m);
  assert.doesNotMatch(
    job(workflow('quality'), 'container-admission'),
    /^    environment:/m,
  );
});

test('opt-in staging publisher is admitted and rights-gated without an automatic host mutation', () => {
  const quality = workflow('quality');
  const publisher = job(quality, 'staging-rc-publish');
  const source = readFileSync('scripts/release/publish-candidate.sh', 'utf8');
  const deploy = readFileSync('scripts/release/deploy-release.sh', 'utf8');
  const stable = readFileSync('scripts/release/promote-stable.sh', 'utf8');

  assert.match(publisher, /name: Publish Accepted Staging RC \(Opt-in\)/);
  assert.match(publisher, /KAORI_DOCS_AUTO_STAGING_ENABLED == 'true'/);
  assert.match(publisher, /github\.event_name == 'push'/);
  assert.match(publisher, /github\.ref == 'refs\/heads\/kaori\/staging'/);
  assert.match(publisher, /needs\.admission-evidence\.result == 'success'/);
  assert.match(publisher, /needs\.browser-evidence\.result == 'success'/);
  assert.match(publisher, /needs\.container-admission\.result == 'success'/);
  assert.match(publisher, /environment:\n      name: staging/);
  assert.match(publisher, /group: kaori-docs-release-candidate/);
  assert.match(publisher, /contents: write/);
  assert.match(publisher, /id-token: write/);
  assert.match(publisher, /scripts\/release\/publish-candidate\.sh rights/);
  assert.match(publisher, /scripts\/release\/publish-candidate\.sh preflight/);
  assert.match(publisher, /scripts\/release\/publish-candidate\.sh publish/);
  assert.match(publisher, /stable v0\.3\.0 already exists/);
  assert.match(publisher, /candidate tag reserved or GitHub tag lookup unavailable/);
  assert.match(publisher, /reuse existing signed Docs RC/);
  assert.doesNotMatch(publisher, /deploy-release\.sh|HOST_SSH|deploy-staging-host\.yml/);

  assert.match(source, /KAORI_DOCS_STAGING_AUTO:-0/);
  assert.match(source, /mode" == rights/);
  assert.match(source, /Docs #74 standing publication rights not accepted/);
  assert.match(source, /KAORI_DOCS_PUBLICATION_GO:STANDING/);
  assert.match(source, /KAORI_DOCS_PUBLICATION_REVOKED:STANDING/);
  assert.match(source, /quality\.yml@refs\/heads\/kaori\/staging/);
  assert.match(source, /KAORI_DOCS_RC_APPROVED:\$sha:\$tag/);
  assert.match(deploy, /quality\.yml@refs\/heads\/kaori\/staging/);
  assert.match(deploy, /KAORI_DOCS_DEPLOY_APPROVED:\$ACCEPTED_SHA:\$RC_TAG:\$digest/);
  // The same accepted RC must remain usable for stable same-digest promotion.
  // Both consumers verify signatures under the identical exact signer set.
  const acceptedSigner = 'quality.yml@refs/heads/kaori/staging';
  assert.ok(deploy.includes(acceptedSigner));
  assert.ok(stable.includes(acceptedSigner));
  for (const script of [deploy, stable]) {
    assert.match(script, /publish-staging-image\.yml@\$allowed_ref/);
    assert.match(script, /certificate-identity "\$identity"/);
    assert.match(script, /refs\/heads\/kaori\/staging refs\/heads\/kaori\/rc-request/);
  }
  assert.match(stable, /git merge-base --is-ancestor "\$rc_sha" "\$GITHUB_SHA"/);
  assert.match(stable, /source or runtime drift since accepted RC/);
  assert.match(stable, /same signed.*RC|same signed|immutable RC image/);
  assert.doesNotMatch(
    stable,
    /--insecure-ignore-tlog|--insecure-ignore-sct|--allow-insecure-registry/,
  );
});
