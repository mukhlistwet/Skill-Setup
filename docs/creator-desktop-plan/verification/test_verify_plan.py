"""Regression probes run disposable mirrors, never published evidence."""
from pathlib import Path
import hashlib
import os
import shutil
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parent.parent


class OptimizedVerifierChecks(unittest.TestCase):
    def setUp(self):
        scratch = os.environ.get('CREATOR_PLAN_SCRATCH') or os.environ.get('TMPDIR')
        if not scratch:
            self.fail('Set CREATOR_PLAN_SCRATCH or TMPDIR to a disposable scratch directory')
        Path(scratch).mkdir(parents=True, exist_ok=True)
        self.temp = tempfile.TemporaryDirectory(prefix='creator-plan-regression-', dir=scratch)
        self.addCleanup(self.temp.cleanup)
        self.mirror = Path(self.temp.name) / 'plan'

    def prepare(self, missing_inputs=False):
        if missing_inputs:
            (self.mirror / 'verification').mkdir(parents=True)
            shutil.copy2(ROOT / 'verification/verify_plan.py', self.mirror / 'verification/verify_plan.py')
            (self.mirror / 'verification/plan-validation.json').write_text('sentinel\n', encoding='utf-8')
        else:
            shutil.copytree(ROOT, self.mirror, ignore=shutil.ignore_patterns('__pycache__', '*.log'))
            requirements = self.mirror / 'requirements.csv'
            text = requirements.read_text(encoding='utf-8')
            self.assertIn('FR-01,', text)
            requirements.write_text(text.replace('FR-01,', 'FR-99,', 1), encoding='utf-8')

    def evidence(self):
        return {
            str(path.relative_to(self.mirror)): (hashlib.sha256(path.read_bytes()).hexdigest(), path.stat().st_mtime_ns)
            for path in (self.mirror / 'verification').rglob('*') if path.is_file()
        }

    def run_verifier(self, flags=(), optimize=None):
        env = os.environ.copy()
        env.pop('PYTHONOPTIMIZE', None)
        env['PYTHONDONTWRITEBYTECODE'] = '1'
        if optimize is not None:
            env['PYTHONOPTIMIZE'] = optimize
        return subprocess.run(
            [sys.executable, '-B', *flags, str(self.mirror / 'verification/verify_plan.py')],
            capture_output=True, text=True, env=env, timeout=60,
        )

    def test_normal_interpreter_rejects_malformed_requirement(self):
        self.prepare()
        before = self.evidence()
        result = self.run_verifier()
        self.assertNotEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn('AssertionError', result.stderr)
        self.assertEqual(self.evidence(), before, 'Verifier changed evidence for invalid requirements')

    def check_optimized_mode(self, *, flags=(), optimize=None, missing_inputs=False):
        self.prepare(missing_inputs=missing_inputs)
        before = self.evidence()
        result = self.run_verifier(flags=flags, optimize=optimize)
        self.assertNotEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn('requires assertions', result.stderr)
        self.assertNotIn('"passed": true', result.stdout.lower())
        self.assertEqual(self.evidence(), before, 'Optimized verifier changed evidence')

    def test_optimized_flags_rejected_before_validation_or_evidence_writes(self):
        for flag in ('-O', '-OO'):
            for missing in (False, True):
                with self.subTest(flag=flag, missing_inputs=missing):
                    self.mirror = Path(self.temp.name) / (flag + str(missing))
                    self.check_optimized_mode(flags=(flag,), missing_inputs=missing)

    def test_pythonoptimize_rejected_before_validation_or_evidence_writes(self):
        for value in ('1', '2'):
            for missing in (False, True):
                with self.subTest(PYTHONOPTIMIZE=value, missing_inputs=missing):
                    self.mirror = Path(self.temp.name) / (value + str(missing))
                    self.check_optimized_mode(optimize=value, missing_inputs=missing)


if __name__ == '__main__':
    unittest.main(verbosity=2)
