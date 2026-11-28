"""Dry-run-first skill sync. No packages, account data or external services."""
import argparse
import hashlib
import json
import os
from pathlib import Path, PurePosixPath
import shutil


def safe_relative(value):
    if not isinstance(value, str) or not value or '\\' in value or ':' in value:
        raise ValueError('Unsafe bundle path')
    p = PurePosixPath(value)
    if p.is_absolute() or any(x in ('..', '.') or x.endswith((' ', '.')) for x in p.parts) or p.as_posix() != value:
        raise ValueError('Unsafe bundle path: ' + value)
    return p


def no_links(path):
    for p in (Path(path), *Path(path).parents):
        if p.is_symlink() or (hasattr(p, 'is_junction') and p.is_junction()):
            raise ValueError('Symlink/junction paths are not allowed: ' + str(p))


def required_directory(path):
    no_links(path)
    for p in (path, *path.parents):
        if p.exists() and not p.is_dir():
            raise ValueError('Required directory is obstructed: ' + str(p))


def verified_payload(bundle):
    no_links(bundle)
    bundle = Path(bundle).resolve()
    no_links(bundle / 'manifest.json')
    manifest = json.loads((bundle / 'manifest.json').read_text(encoding='utf-8'))
    if manifest.get('schema_version') != 1 or not isinstance(manifest.get('managed_skill_roots'), list):
        raise ValueError('Unsupported bundle manifest')
    roots = manifest['managed_skill_roots']
    for root in roots:
        parts = safe_relative(root).parts
        if len(parts) != 3 or parts[0] != 'skills':
            raise ValueError('Invalid managed skill root')
    payload = []
    seen = set()
    for item in manifest['files']:
        rel = item['path']
        safe_relative(rel)
        if rel in seen:
            raise ValueError('Duplicate bundle path: ' + rel)
        seen.add(rel)
        source = bundle / rel
        no_links(source)
        data = source.read_bytes() if source.is_file() else b''
        if not source.is_file() or hashlib.sha256(data).hexdigest() != item['sha256']:
            raise ValueError('Bundle checksum mismatch: ' + rel)
        if rel.startswith('skills/') and not any(rel.startswith(r + '/') for r in roots):
            raise ValueError('Skill is outside managed roots')
        payload.append((rel, data))
    return manifest, payload


def sync(bundle, home, apply=False):
    home = Path(home)
    if '..' in home.parts:
        raise ValueError('Parent components are not allowed in the destination')
    manifest, payload = verified_payload(bundle)
    home = home.absolute()
    no_links(home)
    home = home.resolve()
    if 'profiles' in [x.lower() for x in home.parts] or home == Path(home.anchor) or home == Path.home().resolve():
        raise ValueError('Only an explicit default Hermes home is allowed')
    expected = {rel for rel, _ in payload if rel.startswith('skills/')}
    for root in manifest['managed_skill_roots']:
        dest_root = home / root
        required_directory(dest_root)
        if dest_root.exists():
            for existing in dest_root.rglob('*'):
                no_links(existing)
                if existing.is_file() and existing.relative_to(home).as_posix() not in expected:
                    raise ValueError('Extra managed-skill file requires manual review: ' + str(existing))
    actions = []
    for rel, data in payload:
        if not rel.startswith('skills/'):
            continue
        dest = home / rel
        no_links(dest)
        required_directory(dest.parent)
        if dest.exists() and (not dest.is_file() or dest.read_bytes() != data):
            raise ValueError('Existing skill differs; review/backup manually: ' + rel)
        actions.append({'path': rel, 'action': 'UNCHANGED' if dest.exists() else 'ADD'})
    if apply:
        for rel, data in payload:
            if rel.startswith('skills/') and not (home / rel).exists():
                dest = home / rel
                dest.parent.mkdir(parents=True, exist_ok=True)
                no_links(dest)
                with dest.open('xb') as out:
                    out.write(data)
    return {'mode': 'APPLY_SKILLS' if apply else 'DRY_RUN', 'actions': actions}


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--bundle', type=Path, default=Path(__file__).resolve().parents[1])
    p.add_argument('--home', type=Path, default=Path(os.environ.get('HERMES_HOME', str(Path(os.environ.get('LOCALAPPDATA', str(Path.home() / 'AppData/Local'))) / 'hermes') if os.name == 'nt' else str(Path.home() / '.hermes'))))
    p.add_argument('--apply', action='store_true', help='Copy bundled missing skills only; never apply settings or install apps')
    args = p.parse_args()
    print(json.dumps(sync(args.bundle, args.home, apply=args.apply), indent=2))


if __name__ == '__main__':
    main()
