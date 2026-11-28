"""Executable design checks; all records are SYNTHETIC fixtures, no external calls."""
from pathlib import Path
import io
import json
import os
import sqlite3
import tempfile
import unittest

ROOT = Path(__file__).resolve().parent.parent
HASH = 'a' * 64
OTHER_HASH = 'b' * 64

def insert(db, table, **values):
    columns = ','.join(values)
    placeholders = ','.join('?' for _ in values)
    db.execute(f'INSERT INTO {table} ({columns}) VALUES ({placeholders})', tuple(values.values()))

def seed(db):
    insert(db, 'providers', id='p', name='Fixture', account_alias='test', surface='API', adapter_key='fixture', adapter_version='1', created_at_ms=1)
    insert(db, 'providers', id='other', name='Other fixture', account_alias='test2', surface='API', adapter_key='fixture', adapter_version='1', created_at_ms=1)
    insert(db, 'model_routes', id='m', provider_id='p', external_model_id='fixture-model', display_name='Not a real model', roles_json='["VIDEO"]')
    insert(db, 'workflow_versions', id='w', workflow_key='fixture', revision=1, spec_json='{}', content_sha256=HASH)
    insert(db, 'workflow_versions', id='w2', workflow_key='fixture2', revision=1, spec_json='{}', content_sha256=HASH)
    insert(db, 'template_versions', id='t', template_key='fixture', revision=1, workflow_version_id='w', constraints_json='{}', defaults_json='{}')
    insert(db, 'projects', id='pr', title='Synthetic project', intent='AFFILIATE', format='SHORT', platform='SHOPEE_VIDEO', production_style='REAL_FOOTAGE', template_version_id='t', settings_json='{}', created_at_ms=1)
    insert(db, 'products', id='pd', marketplace='SHOPEE_ID', canonical_url='https://example.invalid/product', created_at_ms=1)
    for version in ('v', 'v2'):
        insert(db, 'product_versions', id=version, product_id='pd', revision=1 if version=='v' else 2, title='Synthetic only', seller_label='Test', variant_key=version, variant_label=version, observed_at_ms=1, facts_json='{}')
    insert(db, 'project_products', project_id='pr', product_version_id='v', role='PRIMARY')
    insert(db, 'evidence', id='e', product_version_id='v', source_kind='ORIGINAL_FOOTAGE', source_uri='fixtures/source.txt', captured_at_ms=1, excerpt='Synthetic evidence')
    insert(db, 'assets', id='as', title='Synthetic asset', created_at_ms=1)
    for version in ('av', 'av2'):
        insert(db, 'asset_versions', id=version, asset_id='as', revision=1 if version=='av' else 2, product_version_id='v' if version=='av' else 'v2', media_kind='VIDEO', relpath='assets/fixture.mp4', content_sha256=HASH, metadata_json='{}', rights_state='APPROVED', rights_evidence='Synthetic fixture permission', consent_json='{}', created_at_ms=1)
    insert(db, 'scenes', id='s', project_id='pr', scene_key='one', revision=1, spec_json='{}', content_sha256=HASH)
    insert(db, 'runs', id='r', project_id='pr', template_version_id='t', workflow_version_id='w', snapshot_json='{}', request_sha256=HASH, state='PLANNED', created_at_ms=1)
    insert(db, 'run_nodes', id='n', run_id='r', node_key='generate', effect='PAID_GENERATION', route_id='m', state='WAITING_APPROVAL')
    insert(db, 'wallets', id='wl', provider_id='p', unit='FIXTURE_CREDIT', unit_scale=1000)
    insert(db, 'budgets', id='b', project_id='pr', wallet_id='wl', limit_u=100)
    db.commit()

def grant(db, identity='a', **overrides):
    data=dict(id=identity, node_id='n', prepared_receipt_id='receipt_'+identity, request_sha256=HASH, receipt_sha256=HASH, effect='PAID_GENERATION', budget_id='b', max_amount_u=80, approved_at_ms=10, expires_at_ms=100)
    data.update(overrides)
    insert(db, 'prepared_receipts', id='receipt_'+identity, node_id=data['node_id'], route_id='m', body_json='{}', request_sha256=data['request_sha256'], receipt_sha256=data['receipt_sha256'], prepared_at_ms=5, expires_at_ms=150)
    insert(db, 'approvals', **data)

def intent(db, identity='i', **overrides):
    data=dict(id=identity, node_id='n', idempotency_key=identity, request_sha256=HASH, approval_id='a', state='RESERVED', created_at_ms=20)
    data.update(overrides)
    insert(db, 'generation_intents', **data)

class SchemaChecks(unittest.TestCase):
    def setUp(self):
        self.db=sqlite3.connect(':memory:')
        self.db.executescript((ROOT/'schema/001-initial.sql').read_text(encoding='utf-8'))
        seed(self.db)
    def tearDown(self): self.db.close()
    def rejected(self, sql, parameters=()):
        with self.assertRaises(sqlite3.IntegrityError): self.db.execute(sql,parameters)
    def test_integrity(self):
        self.assertEqual(self.db.execute('PRAGMA integrity_check').fetchone()[0],'ok')
        self.assertEqual(self.db.execute('PRAGMA foreign_key_check').fetchall(),[])
    def test_affiliate_can_be_short(self):
        self.assertEqual(self.db.execute('SELECT intent,format FROM projects').fetchone(),('AFFILIATE','SHORT'))
    def test_invalid_affiliate_attribution_mode(self): self.rejected("UPDATE project_products SET attribution_mode='AUTOMATIC_COMMISSION'")
    def test_invalid_taxonomy(self): self.rejected("UPDATE projects SET format='AFFILIATE'")
    def test_invalid_json(self): self.rejected("UPDATE projects SET settings_json='not-json'")
    def test_foreign_key_required(self): self.rejected("INSERT INTO project_products(project_id,product_version_id,role) VALUES('missing','v','COMPARISON')")
    def test_product_price_requires_currency(self):
        with self.assertRaises(sqlite3.IntegrityError):
            insert(self.db, 'product_versions', id='priced', product_id='pd', revision=3, title='Synthetic only', seller_label='Test', variant_key='priced', variant_label='priced', observed_at_ms=1, facts_json='{}', price_minor=100, price_currency=None)
    def test_product_price_can_be_unknown(self):
        insert(self.db, 'product_versions', id='priced', product_id='pd', revision=3, title='Synthetic only', seller_label='Test', variant_key='priced', variant_label='priced', observed_at_ms=1, facts_json='{}', price_minor=None, price_currency=None)
        self.assertEqual(self.db.execute("SELECT price_minor,price_currency FROM product_versions WHERE id='priced'").fetchone(), (None, None))
    def test_product_price_accepts_currency(self):
        insert(self.db, 'product_versions', id='priced', product_id='pd', revision=3, title='Synthetic only', seller_label='Test', variant_key='priced', variant_label='priced', observed_at_ms=1, facts_json='{}', price_minor=100, price_currency='IDR')
        self.assertEqual(self.db.execute("SELECT price_minor,price_currency FROM product_versions WHERE id='priced'").fetchone(), (100, 'IDR'))
    def test_product_currency_requires_price(self):
        with self.assertRaises(sqlite3.IntegrityError):
            insert(self.db, 'product_versions', id='priced', product_id='pd', revision=3, title='Synthetic only', seller_label='Test', variant_key='priced', variant_label='priced', observed_at_ms=1, facts_json='{}', price_minor=None, price_currency='IDR')
    def test_product_version_immutable(self): self.rejected("UPDATE product_versions SET title='changed' WHERE id='v'")
    def test_one_primary_product(self): self.rejected("INSERT INTO project_products(project_id,product_version_id,role) VALUES('pr','v2','PRIMARY')")
    def test_approved_claim_requires_evidence(self): self.rejected("INSERT INTO claims VALUES('c','v','Synthetic claim',NULL,'APPROVED',20)")
    def test_claim_evidence_product_match(self): self.rejected("INSERT INTO claims VALUES('c','v2','Synthetic claim','e','APPROVED',20)")
    def test_claim_can_be_approved(self):
        self.db.execute("INSERT INTO claims VALUES('c','v','Synthetic claim','e','APPROVED',20)")
        self.assertEqual(self.db.execute('SELECT review_state FROM claims').fetchone()[0],'APPROVED')
    def test_rights_approval_evidence_required(self): self.rejected("UPDATE asset_versions SET rights_evidence=NULL WHERE id='av'")
    def test_rights_can_be_revoked_without_mutating_source(self):
        self.db.execute("UPDATE asset_versions SET rights_state='REVOKED' WHERE id='av'")
        self.assertEqual(self.db.execute("SELECT content_sha256 FROM asset_versions WHERE id='av'").fetchone()[0],HASH)
    def test_asset_source_immutable(self): self.rejected("UPDATE asset_versions SET content_sha256=? WHERE id='av'",(OTHER_HASH,))
    def test_product_binding_matches_project_version(self): self.rejected("INSERT INTO scene_assets VALUES('s','product','av2','PRODUCT',1)")
    def test_duplicate_scene_slot(self):
        self.db.execute("INSERT INTO scene_assets VALUES('s','product','av','PRODUCT',1)")
        self.rejected("INSERT INTO scene_assets VALUES('s','product','av2','FOOTAGE',1)")
    def test_scene_binding_no_mutation(self):
        self.db.execute("INSERT INTO scene_assets VALUES('s','product','av','PRODUCT',1)")
        self.rejected("UPDATE scene_assets SET asset_version_id='av2'")
    def test_template_workflow_consistency(self): self.rejected("INSERT INTO runs VALUES('r2','pr','t','w2','{}',?,'PLANNED',1)",(HASH,))
    def test_run_snapshot_immutable(self): self.rejected("UPDATE runs SET snapshot_json='[]'")
    def test_approval_hash_match(self):
        grant(self.db)
        with self.assertRaises(sqlite3.IntegrityError): intent(self.db,request_sha256=OTHER_HASH)
    def test_expired_approval(self):
        grant(self.db)
        with self.assertRaises(sqlite3.IntegrityError): intent(self.db,created_at_ms=100)
    def test_revoked_approval(self):
        grant(self.db,revoked_at_ms=15)
        with self.assertRaises(sqlite3.IntegrityError): intent(self.db)
    def test_grant_consumed_once(self):
        grant(self.db);intent(self.db)
        self.assertEqual(self.db.execute("SELECT consumed_at_ms FROM approvals WHERE id='a'").fetchone()[0],20)
        with self.assertRaises(sqlite3.IntegrityError): intent(self.db,identity='i2')
    def test_duplicate_intent_key(self):
        grant(self.db);intent(self.db);grant(self.db,'a2')
        with self.assertRaises(sqlite3.IntegrityError): intent(self.db,identity='i2',approval_id='a2',idempotency_key='i')
    def test_approval_terms_immutable(self):
        grant(self.db);self.rejected("UPDATE approvals SET max_amount_u=99")
    def test_intent_request_immutable(self):
        grant(self.db);intent(self.db);self.rejected("UPDATE generation_intents SET request_sha256=?",(OTHER_HASH,))
    def test_budget_overspend_rejected(self): self.rejected('UPDATE budgets SET reserved_u=101')
    def test_reservation_within_grant(self):
        grant(self.db);intent(self.db)
        self.rejected("INSERT INTO reservations VALUES('rs','i','b',81,'RESERVED',NULL)")
    def test_unknown_keeps_reservation(self):
        grant(self.db);intent(self.db)
        self.db.execute('UPDATE budgets SET reserved_u=80')
        self.db.execute("INSERT INTO reservations VALUES('rs','i','b',80,'RESERVED',NULL)")
        self.db.execute("UPDATE generation_intents SET state='UNKNOWN'")
        self.assertEqual(self.db.execute('SELECT reserved_u FROM budgets').fetchone()[0],80)
        self.assertEqual(self.db.execute('SELECT state FROM reservations').fetchone()[0],'RESERVED')
    def test_budget_and_intent_rollback_together(self):
        grant(self.db);self.db.commit()
        self.db.execute('BEGIN IMMEDIATE')
        self.db.execute('UPDATE budgets SET reserved_u=80')
        intent(self.db)
        self.db.rollback()
        self.assertEqual(self.db.execute('SELECT reserved_u FROM budgets').fetchone()[0],0)
        self.assertIsNone(self.db.execute('SELECT consumed_at_ms FROM approvals').fetchone()[0])
        self.assertEqual(self.db.execute('SELECT count(*) FROM generation_intents').fetchone()[0],0)
    def test_wrong_external_provider_rejected(self):
        grant(self.db);intent(self.db)
        self.rejected("INSERT INTO external_jobs VALUES('j','i','other','remote','RUNNING','{}',20)")
    def test_bad_artifact_hash(self): self.rejected("INSERT INTO artifacts VALUES('ar','n','VIDEO','exports/out.mp4','bad','{}',20)")
    def test_artifact_path_rejected(self): self.rejected("INSERT INTO artifacts VALUES('ar','n','VIDEO','../outside.mp4',?,'{}',20)",(HASH,))
    def test_receipt_immutable(self):
        grant(self.db);self.rejected("UPDATE prepared_receipts SET body_json='[]'")
    def test_approval_receipt_scope(self):
        grant(self.db)
        with self.assertRaises(sqlite3.IntegrityError):
            insert(self.db,'approvals',id='wrong',node_id='n',prepared_receipt_id='receipt_a',request_sha256=OTHER_HASH,receipt_sha256=HASH,effect='PAID_GENERATION',budget_id='b',max_amount_u=80,approved_at_ms=10,expires_at_ms=100)
    def test_wrong_product_claim_cannot_bind_scene(self):
        insert(self.db,'evidence',id='e2',product_version_id='v2',source_kind='OFFICIAL_SPEC',source_uri='fixtures/spec',captured_at_ms=1,excerpt='Synthetic')
        insert(self.db,'claims',id='c2',product_version_id='v2',claim_text='Synthetic',evidence_id='e2',review_state='APPROVED',reviewed_at_ms=20)
        self.rejected("INSERT INTO scene_claims VALUES('s','c2','NARRATION')")
    def test_backup_restore(self):
        scratch=os.environ.get('CREATOR_PLAN_SCRATCH') or os.environ.get('TMPDIR') or str(Path.home()/'.cache/creator-plan-verification')
        Path(scratch).mkdir(parents=True,exist_ok=True)
        with tempfile.TemporaryDirectory(prefix='creator-schema-',dir=scratch) as temp:
            target=sqlite3.connect(str(Path(temp)/'snapshot.db'))
            self.db.backup(target)
            self.assertEqual(target.execute('PRAGMA integrity_check').fetchone()[0],'ok')
            self.assertEqual(target.execute('SELECT intent,format FROM projects').fetchone(),('AFFILIATE','SHORT'))
            target.close()

if __name__=='__main__':
    stream=io.StringIO()
    suite=unittest.defaultTestLoader.loadTestsFromTestCase(SchemaChecks)
    result=unittest.TextTestRunner(stream=stream,verbosity=2).run(suite)
    print(stream.getvalue())
    summary=dict(scope='SQLite schema design fixture only; not app/runtime acceptance',sqlite_version=sqlite3.sqlite_version,tests_run=result.testsRun,failures=len(result.failures),errors=len(result.errors),passed=result.wasSuccessful(),synthetic_fixtures=True,not_run=['Rust/Tauri build','UI E2E','Chrome/Flow live connection','MCP live handshake','real provider dispatch','video export/visual/audio QA','multi-process concurrency','full workspace assets backup/restore'])
    (ROOT/'verification').mkdir(exist_ok=True)
    # Evidence produced by a test run, not a hand-written claim of success.
    (ROOT/'verification/schema-tests.json').write_text(json.dumps(summary,indent=2)+'\n',encoding='utf-8')
    (ROOT/'verification/schema-tests.log').write_text(stream.getvalue(),encoding='utf-8')
    raise SystemExit(0 if result.wasSuccessful() else 1)
