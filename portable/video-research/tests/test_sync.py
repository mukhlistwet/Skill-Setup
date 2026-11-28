import importlib.util
import json
import os
from pathlib import Path
import tempfile
import unittest

SCRIPT = Path(__file__).resolve().parents[1] / 'tools' / 'sync_video_setup.py'
SCRATCH = Path(os.environ.get('HERMES_TEST_TMPDIR', str(Path(os.environ.get('HERMES_HOME', str(Path.home() / '.hermes'))) / 'cache/scratch')))
SCRATCH.mkdir(parents=True, exist_ok=True)


class PortableSetupTests(unittest.TestCase):
    def test_default_dry_run_does_not_create_target(self):
        self.assertTrue(SCRIPT.is_file(), 'Portable sync helper has not been implemented')
        spec = importlib.util.spec_from_file_location('portable_sync', SCRIPT)
        assert spec is not None and spec.loader is not None
        mod = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(mod)
        with tempfile.TemporaryDirectory(dir=SCRATCH) as tmp:
            base = Path(tmp)
            package = base / 'package'
            payload = package / 'skills/media/example/SKILL.md'
            payload.parent.mkdir(parents=True)
            payload.write_text('---\nname: example\n---\nExample skill.\n', encoding='utf-8')
            import hashlib
            manifest = {'schema_version': 1, 'managed_skill_roots': ['skills/media/example'], 'files': [{'path': 'skills/media/example/SKILL.md', 'sha256': hashlib.sha256(payload.read_bytes()).hexdigest()}]}
            (package / 'manifest.json').write_text(json.dumps(manifest), encoding='utf-8')
            target = base / 'target'
            result = mod.sync(package, target, apply=False)
            self.assertFalse(target.exists())
            self.assertEqual(result['mode'], 'DRY_RUN')
    def fixture(self, base):
        spec = importlib.util.spec_from_file_location('portable_sync', SCRIPT)
        assert spec is not None and spec.loader is not None
        mod = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(mod)
        package = base / 'package'
        payload = package / 'skills/media/example/SKILL.md'
        payload.parent.mkdir(parents=True)
        payload.write_text('---\nname: example\n---\nExample skill.\n', encoding='utf-8')
        import hashlib
        manifest = {'schema_version': 1, 'managed_skill_roots': ['skills/media/example'], 'files': [{'path': 'skills/media/example/SKILL.md', 'sha256': hashlib.sha256(payload.read_bytes()).hexdigest()}]}
        (package / 'manifest.json').write_text(json.dumps(manifest), encoding='utf-8')
        return mod, package, payload, manifest

    def test_tampered_payload_refuses_before_target_writes(self):
        with tempfile.TemporaryDirectory(dir=SCRATCH) as tmp:
            base = Path(tmp)
            mod, package, payload, manifest = self.fixture(base)
            payload.write_text('Changed after manifest', encoding='utf-8')
            with self.assertRaises(ValueError):
                mod.sync(package, base / 'target', apply=True)
            self.assertFalse((base / 'target').exists())
    def test_manifest_paths_cannot_escape_bundle(self):
        for bad in ['../outside.txt', '/absolute.txt', 'C:/absolute.txt', 'skills/../outside.txt', 'skills\\\\escape.txt']:
            with self.subTest(path=bad), tempfile.TemporaryDirectory(dir=SCRATCH) as tmp:
                base = Path(tmp)
                mod, package, payload, manifest = self.fixture(base)
                manifest['files'][0]['path'] = bad
                (package / 'manifest.json').write_text(json.dumps(manifest), encoding='utf-8')
                with self.assertRaises(ValueError):
                    mod.sync(package, base / 'target', apply=True)
                self.assertFalse((base / 'target').exists())
    def test_existing_modified_skill_refuses_without_overwrite(self):
        with tempfile.TemporaryDirectory(dir=SCRATCH) as tmp:
            base = Path(tmp)
            mod, package, payload, manifest = self.fixture(base)
            dest = base / 'target/skills/media/example/SKILL.md'
            dest.parent.mkdir(parents=True)
            dest.write_text('User changes', encoding='utf-8')
            with self.assertRaises(ValueError):
                mod.sync(package, base / 'target', apply=True)
            self.assertEqual(dest.read_text(encoding='utf-8'), 'User changes')

    def test_apply_is_idempotent_and_preserves_unrelated_config(self):
        with tempfile.TemporaryDirectory(dir=SCRATCH) as tmp:
            base = Path(tmp)
            mod, package, payload, manifest = self.fixture(base)
            target = base / 'target'
            target.mkdir()
            config = target / 'config.yaml'
            config.write_text('unrelated: retain\n', encoding='utf-8')
            mod.sync(package, target, apply=True)
            result = mod.sync(package, target, apply=True)
            self.assertEqual((target / 'skills/media/example/SKILL.md').read_bytes(), payload.read_bytes())
            self.assertEqual(config.read_text(encoding='utf-8'), 'unrelated: retain\n')
            self.assertTrue(all(x['action'] == 'UNCHANGED' for x in result['actions']))
    def test_named_profile_target_refused(self):
        with tempfile.TemporaryDirectory(dir=SCRATCH) as tmp:
            base = Path(tmp)
            mod, package, payload, manifest = self.fixture(base)
            with self.assertRaises(ValueError):
                mod.sync(package, base / 'profiles/other', apply=True)
            self.assertFalse((base / 'profiles').exists())

    def test_extra_existing_managed_file_requires_manual_review(self):
        with tempfile.TemporaryDirectory(dir=SCRATCH) as tmp:
            base = Path(tmp)
            mod, package, payload, manifest = self.fixture(base)
            note = base / 'target/skills/media/example/user-note.md'
            note.parent.mkdir(parents=True)
            note.write_text('Keep user file', encoding='utf-8')
            with self.assertRaises(ValueError):
                mod.sync(package, base / 'target', apply=True)
            self.assertEqual(note.read_text(encoding='utf-8'), 'Keep user file')
            self.assertFalse((note.parent / 'SKILL.md').exists())
    def test_manifest_symlink_is_checked_before_read(self):
        from unittest import mock
        with tempfile.TemporaryDirectory(dir=SCRATCH) as tmp:
            base = Path(tmp)
            mod, package, payload, manifest = self.fixture(base)
            manifest_path = package / 'manifest.json'
            # Simulate a file symlink because Windows may deny creating one without privileges.
            with mock.patch.object(mod.Path, 'is_symlink', new=lambda path: path == manifest_path):
                with self.assertRaises(ValueError):
                    mod.sync(package, base / 'target', apply=False)

    def test_destination_parent_components_rejected_even_in_dry_run(self):
        from unittest import mock
        with tempfile.TemporaryDirectory(dir=SCRATCH) as tmp:
            base = Path(tmp)
            mod, package, payload, manifest = self.fixture(base)
            target = base / 'target'
            (target / 'child').mkdir(parents=True)
            with mock.patch.object(mod.Path, 'home', return_value=target):
                with self.assertRaises(ValueError):
                    mod.sync(package, target / 'child/..', apply=False)

    def test_directory_obstruction_rejected_during_dry_run(self):
        for blocked in ['skills', 'skills/media', 'skills/media/example']:
            with self.subTest(blocked=blocked), tempfile.TemporaryDirectory(dir=SCRATCH) as tmp:
                base = Path(tmp)
                mod, package, payload, manifest = self.fixture(base)
                obstruction = base / 'target' / blocked
                obstruction.parent.mkdir(parents=True)
                obstruction.write_text('Existing ordinary file', encoding='utf-8')
                with self.assertRaises(ValueError):
                    mod.sync(package, base / 'target', apply=False)

    def test_later_directory_obstruction_cannot_partially_apply_earlier_skill(self):
        import hashlib
        with tempfile.TemporaryDirectory(dir=SCRATCH) as tmp:
            base = Path(tmp)
            mod, package, payload, manifest = self.fixture(base)
            rel = 'skills/media/blocked/SKILL.md'
            second = package / rel
            second.parent.mkdir(parents=True)
            second.write_bytes(payload.read_bytes())
            manifest['managed_skill_roots'].append('skills/media/blocked')
            manifest['files'].append({'path': rel, 'sha256': hashlib.sha256(second.read_bytes()).hexdigest()})
            (package / 'manifest.json').write_text(json.dumps(manifest), encoding='utf-8')
            obstruction = base / 'target/skills/media/blocked'
            obstruction.parent.mkdir(parents=True)
            obstruction.write_text('Keep this file', encoding='utf-8')
            with self.assertRaises((ValueError, OSError)):
                mod.sync(package, base / 'target', apply=True)
            self.assertFalse((base / 'target/skills/media/example/SKILL.md').exists())
            self.assertEqual(obstruction.read_text(encoding='utf-8'), 'Keep this file')
    def test_non_skill_payload_tamper_also_refused(self):
        import hashlib
        with tempfile.TemporaryDirectory(dir=SCRATCH) as tmp:
            base = Path(tmp)
            mod, package, payload, manifest = self.fixture(base)
            settings = package / 'settings.json'
            settings.write_text('{"mode":"setup"}', encoding='utf-8')
            manifest['files'].append({'path': 'settings.json', 'sha256': hashlib.sha256(settings.read_bytes()).hexdigest()})
            (package / 'manifest.json').write_text(json.dumps(manifest), encoding='utf-8')
            settings.write_text('{"mode":"changed"}', encoding='utf-8')
            with self.assertRaises(ValueError):
                mod.sync(package, base / 'target', apply=False)
            self.assertFalse((base / 'target').exists())

    def test_named_profile_refused_in_default_dry_run(self):
        with tempfile.TemporaryDirectory(dir=SCRATCH) as tmp:
            base = Path(tmp)
            mod, package, payload, manifest = self.fixture(base)
            with self.assertRaises(ValueError):
                mod.sync(package, base / 'profiles/other')
            self.assertFalse((base / 'profiles').exists())

    def test_source_and_destination_link_checks(self):
        from unittest import mock
        for role in ['source', 'destination']:
            with self.subTest(role=role), tempfile.TemporaryDirectory(dir=SCRATCH) as tmp:
                base = Path(tmp)
                mod, package, payload, manifest = self.fixture(base)
                target = base / 'target'
                link = payload if role == 'source' else target / 'skills/media/example'
                with mock.patch.object(mod.Path, 'is_symlink', new=lambda path: path == link):
                    with self.assertRaises(ValueError):
                        mod.sync(package, target, apply=True)
                self.assertFalse(target.exists())


if __name__ == '__main__':
    unittest.main()
