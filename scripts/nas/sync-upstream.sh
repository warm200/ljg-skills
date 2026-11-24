#!/usr/bin/env bash
# Pull the latest lijigang/ljg-skills `md` branch into this fork's `md` branch and re-apply
# the NAS notes patch. Result: upstream's files exactly, plus scripts/nas/, skills/ljg-weekly/
# and the generated patch. Upstream history is recorded as a merge, so this never conflicts.
#
# Usage (from anywhere in the repo, on branch md, clean tree):
#   scripts/nas/sync-upstream.sh          # merge + patch + commit
#   git push origin md                    # then reinstall the skills
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

[ "$(git branch --show-current)" = md ] || { echo "switch to branch md first" >&2; exit 1; }
git diff --quiet && git diff --cached --quiet || { echo "working tree not clean" >&2; exit 1; }
git remote get-url upstream >/dev/null 2>&1 || git remote add upstream https://github.com/lijigang/ljg-skills.git
git fetch -q upstream md

if git merge-base --is-ancestor upstream/md HEAD; then
  echo "already up to date with upstream/md ($(git rev-parse --short upstream/md))"
  python3 scripts/nas/patch.py --check && exit 0
  python3 scripts/nas/patch.py
  git add -A && git commit -q -m "nas: re-apply notes patch" && echo "committed re-patch"
  exit 0
fi

# Record upstream as merged but keep our tree, then rebuild the tree from upstream + our files.
git merge -q --no-commit -s ours upstream/md
git rm -rq --cached --ignore-unmatch skills
rm -rf skills.nas-keep && mkdir skills.nas-keep && cp -R skills/ljg-weekly skills.nas-keep/
rm -rf skills
git checkout upstream/md -- .
cp -R skills.nas-keep/ljg-weekly skills/ && rm -rf skills.nas-keep

python3 scripts/nas/patch.py
git add -A
git commit -q -m "Merge upstream md $(git rev-parse --short upstream/md) and re-apply NAS notes patch"
echo "merged upstream/md $(git rev-parse --short upstream/md); review with: git show --stat HEAD"
