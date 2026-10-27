# Household fork of Immich

This is a personal fork of [immich-app/immich](https://github.com/immich-app/immich)
for one household's server. It exists only to build **linux/arm64** images
(for a Raspberry Pi) with a few small household changes on top of an upstream
**stable release**. It is not a general-purpose distribution; use upstream Immich.

## Branches and tags

- `household` (default branch): upstream release tag + household commits on top.
  It is always based on a stable upstream tag (never `main`, never an `-rc`).
  The base tag is recorded in `household/BASE_TAG`.
- Image tags: `vX.Y.Z-hh.N`, where `vX.Y.Z` is the upstream base and `N` counts
  household builds on that base. Pushing such a tag runs
  `.github/workflows/household-build.yml`, which publishes
  `ghcr.io/singh-taranjeet/immich-server:vX.Y.Z-hh.N` and
  `ghcr.io/singh-taranjeet/immich-machine-learning:vX.Y.Z-hh.N` (arm64, ML = CPU).
- Version strings (`server/package.json` etc.) are never changed: the mobile apps
  decide compatibility from them, so the server must report the upstream version.

## Rules

- **No database migrations.** Nothing under `server/src/schema/migrations/` may
  differ from the base tag (`household-guard.yml` enforces this). The database must
  always be able to move to a plain upstream release.
- **Never downgrade.** Only move forward to a newer upstream stable release. Immich
  migrations are one-way; running an older image against a newer database is unsafe.
- Only `household-*` workflows run in this fork; upstream workflows are disabled.

## Updating to a new upstream release

`household-upstream-watch.yml` opens an issue "Upstream release vX.Y.Z available"
when upstream publishes a newer stable release. Then:

```sh
git fetch upstream --tags
git rebase --onto vNEW vOLD household       # vOLD = contents of household/BASE_TAG
echo vNEW > household/BASE_TAG && git commit -am "household: base on vNEW"
git push --force-with-lease origin household
household/disable-upstream-workflows.sh     # new upstream workflows may have appeared
git tag vNEW-hh.1 && git push origin vNEW-hh.1   # CI builds and pushes the images
```

Read the upstream release notes (especially breaking changes) before deploying.

## Licence

Immich is licensed under the GNU AGPL v3 (see `LICENSE`). This fork is public and
its source, including all household changes, is available here, as the AGPL
requires for software offered over a network.
