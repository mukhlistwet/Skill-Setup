-- PROPOSED schema v0.1, SQLite 3.37+ syntax (STRICT); patched runtime required.
-- This is a design fixture, not an applied application migration.
PRAGMA foreign_keys = ON;
BEGIN;
CREATE TABLE schema_migrations(version INTEGER PRIMARY KEY, applied_at_ms INTEGER NOT NULL) STRICT;
CREATE TABLE providers(
 id TEXT PRIMARY KEY, name TEXT NOT NULL, account_alias TEXT NOT NULL,
 surface TEXT NOT NULL CHECK(surface IN ('API','BROWSER','LOCAL','MCP')),
 adapter_key TEXT NOT NULL, adapter_version TEXT NOT NULL, base_url TEXT,
 credential_ref TEXT, enabled INTEGER NOT NULL DEFAULT 0 CHECK(enabled IN (0,1)),
 config_json TEXT NOT NULL DEFAULT '{}' CHECK(json_valid(config_json)),
 created_at_ms INTEGER NOT NULL
) STRICT;
CREATE TABLE model_routes(
 id TEXT PRIMARY KEY, provider_id TEXT NOT NULL REFERENCES providers(id),
 external_model_id TEXT NOT NULL, display_name TEXT NOT NULL,
 roles_json TEXT NOT NULL CHECK(json_valid(roles_json) AND json_type(roles_json)='array'),
 enabled INTEGER NOT NULL DEFAULT 0 CHECK(enabled IN (0,1)),
 UNIQUE(provider_id,external_model_id)
) STRICT;
CREATE TABLE connections(
 id TEXT PRIMARY KEY, provider_id TEXT REFERENCES providers(id),
 kind TEXT NOT NULL CHECK(kind IN ('MCP_STDIO','MCP_HTTP','CHROME','LOCAL_RENDERER')),
 state TEXT NOT NULL CHECK(state IN ('DISCONNECTED','PAIRING','CONNECTED','REVOKED','DEGRADED')),
 scope_json TEXT NOT NULL CHECK(json_valid(scope_json)),
 session_epoch INTEGER NOT NULL DEFAULT 0 CHECK(session_epoch>=0), observed_at_ms INTEGER
) STRICT;
CREATE TABLE capability_snapshots(
 id TEXT PRIMARY KEY, route_id TEXT NOT NULL REFERENCES model_routes(id),
 connection_id TEXT REFERENCES connections(id),
 source_kind TEXT NOT NULL CHECK(source_kind IN ('DECLARED','DOCUMENTED','FIXTURE','OBSERVED','LIVE_TESTED')),
 adapter_version TEXT NOT NULL, scope_json TEXT NOT NULL CHECK(json_valid(scope_json)),
 capability_json TEXT NOT NULL CHECK(json_valid(capability_json)),
 evidence_json TEXT NOT NULL CHECK(json_valid(evidence_json)),
 captured_at_ms INTEGER NOT NULL, expires_at_ms INTEGER,
 CHECK(expires_at_ms IS NULL OR expires_at_ms>captured_at_ms)
) STRICT;
CREATE TABLE skill_versions(
 id TEXT PRIMARY KEY, skill_key TEXT NOT NULL, revision TEXT NOT NULL,
 content_sha256 TEXT NOT NULL CHECK(length(content_sha256)=64 AND content_sha256 NOT GLOB '*[^0-9a-f]*'),
 origin TEXT NOT NULL, license_note TEXT NOT NULL, guidance_relpath TEXT NOT NULL,
 UNIQUE(skill_key,revision)
) STRICT;
CREATE TABLE workflow_versions(
 id TEXT PRIMARY KEY, workflow_key TEXT NOT NULL, revision INTEGER NOT NULL CHECK(revision>0),
 spec_json TEXT NOT NULL CHECK(json_valid(spec_json)),
 content_sha256 TEXT NOT NULL CHECK(length(content_sha256)=64 AND content_sha256 NOT GLOB '*[^0-9a-f]*'),
 UNIQUE(workflow_key,revision)
) STRICT;
CREATE TABLE workflow_skills(
 workflow_version_id TEXT NOT NULL REFERENCES workflow_versions(id),
 skill_version_id TEXT NOT NULL REFERENCES skill_versions(id),
 PRIMARY KEY(workflow_version_id,skill_version_id)
) STRICT;
CREATE TABLE template_versions(
 id TEXT PRIMARY KEY, template_key TEXT NOT NULL, revision INTEGER NOT NULL CHECK(revision>0),
 workflow_version_id TEXT NOT NULL REFERENCES workflow_versions(id),
 constraints_json TEXT NOT NULL CHECK(json_valid(constraints_json)),
 defaults_json TEXT NOT NULL CHECK(json_valid(defaults_json)),
 UNIQUE(template_key,revision)
) STRICT;
CREATE TABLE projects(
 id TEXT PRIMARY KEY, title TEXT NOT NULL CHECK(length(trim(title))>0),
 intent TEXT NOT NULL CHECK(intent IN ('AFFILIATE','EDUCATIONAL','STORYTELLING','GENERAL')),
 format TEXT NOT NULL CHECK(format IN ('SHORT','LONG','CUSTOM')),
 platform TEXT NOT NULL, production_style TEXT NOT NULL,
 template_version_id TEXT NOT NULL REFERENCES template_versions(id),
 settings_json TEXT NOT NULL CHECK(json_valid(settings_json)),
 revision INTEGER NOT NULL DEFAULT 1 CHECK(revision>0),
 created_at_ms INTEGER NOT NULL, archived_at_ms INTEGER
) STRICT;
CREATE TABLE products(
 id TEXT PRIMARY KEY, marketplace TEXT NOT NULL CHECK(marketplace='SHOPEE_ID'),
 canonical_url TEXT NOT NULL, external_item_id TEXT, external_shop_id TEXT,
 created_at_ms INTEGER NOT NULL
) STRICT;
CREATE TABLE product_versions(
 id TEXT PRIMARY KEY, product_id TEXT NOT NULL REFERENCES products(id),
 revision INTEGER NOT NULL CHECK(revision>0), title TEXT NOT NULL,
 seller_label TEXT NOT NULL, variant_key TEXT NOT NULL, variant_label TEXT NOT NULL,
 observed_at_ms INTEGER NOT NULL, facts_json TEXT NOT NULL CHECK(json_valid(facts_json)),
 price_minor INTEGER CHECK(price_minor IS NULL OR price_minor>=0), price_currency TEXT,
 price_expires_at_ms INTEGER,
 CHECK((price_minor IS NULL AND price_currency IS NULL) OR (price_minor IS NOT NULL AND price_currency IS NOT NULL AND length(price_currency)=3)),
 CHECK(price_expires_at_ms IS NULL OR price_expires_at_ms>observed_at_ms),
 UNIQUE(product_id,revision)
) STRICT;
CREATE TABLE project_products(
 project_id TEXT NOT NULL REFERENCES projects(id),
 product_version_id TEXT NOT NULL REFERENCES product_versions(id),
 role TEXT NOT NULL CHECK(role IN ('PRIMARY','COMPARISON')),
 attribution_mode TEXT NOT NULL DEFAULT 'PLATFORM_PRODUCT_TAG' CHECK(attribution_mode IN ('EXTERNAL_LINK','PLATFORM_PRODUCT_TAG')),
 affiliate_url TEXT, affiliate_link_source TEXT, affiliate_link_verified_at_ms INTEGER,
 PRIMARY KEY(project_id,product_version_id)
) STRICT;
CREATE UNIQUE INDEX one_primary_product ON project_products(project_id) WHERE role='PRIMARY';
CREATE TABLE evidence(
 id TEXT PRIMARY KEY, product_version_id TEXT REFERENCES product_versions(id),
 source_kind TEXT NOT NULL CHECK(source_kind IN ('ORIGINAL_FOOTAGE','SELLER_DOCUMENT','OFFICIAL_SPEC','USER_OBSERVATION','OTHER')),
 source_uri TEXT NOT NULL, captured_at_ms INTEGER NOT NULL,
 excerpt TEXT NOT NULL, content_sha256 TEXT,
 CHECK(content_sha256 IS NULL OR (length(content_sha256)=64 AND content_sha256 NOT GLOB '*[^0-9a-f]*'))
) STRICT;
CREATE TABLE claims(
 id TEXT PRIMARY KEY, product_version_id TEXT NOT NULL REFERENCES product_versions(id),
 claim_text TEXT NOT NULL, evidence_id TEXT REFERENCES evidence(id),
 review_state TEXT NOT NULL CHECK(review_state IN ('DRAFT','APPROVED','REJECTED','REVOKED')),
 reviewed_at_ms INTEGER,
 CHECK(review_state!='APPROVED' OR (evidence_id IS NOT NULL AND reviewed_at_ms IS NOT NULL))
) STRICT;
CREATE TABLE assets(id TEXT PRIMARY KEY,title TEXT NOT NULL,created_at_ms INTEGER NOT NULL) STRICT;
CREATE TABLE asset_versions(
 id TEXT PRIMARY KEY, asset_id TEXT NOT NULL REFERENCES assets(id),
 revision INTEGER NOT NULL CHECK(revision>0),
 product_version_id TEXT REFERENCES product_versions(id),
 media_kind TEXT NOT NULL CHECK(media_kind IN ('IMAGE','VIDEO','AUDIO','SCENE_3D','DOCUMENT')),
 relpath TEXT NOT NULL,
 content_sha256 TEXT NOT NULL CHECK(length(content_sha256)=64 AND content_sha256 NOT GLOB '*[^0-9a-f]*'),
 metadata_json TEXT NOT NULL CHECK(json_valid(metadata_json)),
 rights_state TEXT NOT NULL CHECK(rights_state IN ('REVIEW_REQUIRED','APPROVED','REVOKED')),
 rights_evidence TEXT, consent_json TEXT NOT NULL CHECK(json_valid(consent_json)),
 parent_version_id TEXT REFERENCES asset_versions(id), created_at_ms INTEGER NOT NULL,
 CHECK(rights_state!='APPROVED' OR length(trim(coalesce(rights_evidence,'')))>0),
 CHECK(length(relpath)>0 AND substr(relpath,1,1)!='/' AND instr(relpath,':')=0 AND instr(relpath,'\')=0 AND instr('/'||relpath||'/','/../')=0),
 UNIQUE(asset_id,revision)
) STRICT;
CREATE TABLE scenes(
 id TEXT PRIMARY KEY, project_id TEXT NOT NULL REFERENCES projects(id),
 scene_key TEXT NOT NULL, revision INTEGER NOT NULL CHECK(revision>0),
 spec_json TEXT NOT NULL CHECK(json_valid(spec_json)),
 content_sha256 TEXT NOT NULL CHECK(length(content_sha256)=64 AND content_sha256 NOT GLOB '*[^0-9a-f]*'),
 UNIQUE(project_id,scene_key,revision)
) STRICT;
CREATE TABLE scene_assets(
 scene_id TEXT NOT NULL REFERENCES scenes(id), slot_key TEXT NOT NULL,
 asset_version_id TEXT NOT NULL REFERENCES asset_versions(id),
 role TEXT NOT NULL CHECK(role IN ('PRODUCT','CHARACTER','LOCATION','PROP','STYLE','VOICE','FOOTAGE','MUSIC','FRAME')),
 required INTEGER NOT NULL CHECK(required IN (0,1)),
 PRIMARY KEY(scene_id,slot_key)
) STRICT;
CREATE TABLE scene_claims(
 scene_id TEXT NOT NULL REFERENCES scenes(id), claim_id TEXT NOT NULL REFERENCES claims(id),
 usage TEXT NOT NULL CHECK(usage IN ('NARRATION','ON_SCREEN','BOTH')),
 PRIMARY KEY(scene_id,claim_id)
) STRICT;
CREATE TABLE remote_asset_bindings(
 id TEXT PRIMARY KEY, asset_version_id TEXT NOT NULL REFERENCES asset_versions(id),
 provider_id TEXT NOT NULL REFERENCES providers(id), connection_id TEXT NOT NULL REFERENCES connections(id),
 project_id TEXT NOT NULL REFERENCES projects(id), remote_project_locator TEXT NOT NULL,
 route_id TEXT REFERENCES model_routes(id), remote_asset_id TEXT,
 observed_label TEXT, evidence_json TEXT NOT NULL CHECK(json_valid(evidence_json)),
 state TEXT NOT NULL CHECK(state IN ('UNRESOLVED','SELECTED_VISIBLE','STALE','AMBIGUOUS')),
 observed_at_ms INTEGER NOT NULL,
 UNIQUE(asset_version_id,provider_id,connection_id,project_id,remote_project_locator)
) STRICT;
CREATE TABLE runs(
 id TEXT PRIMARY KEY, project_id TEXT NOT NULL REFERENCES projects(id),
 template_version_id TEXT NOT NULL REFERENCES template_versions(id),
 workflow_version_id TEXT NOT NULL REFERENCES workflow_versions(id),
 snapshot_json TEXT NOT NULL CHECK(json_valid(snapshot_json)),
 request_sha256 TEXT NOT NULL CHECK(length(request_sha256)=64 AND request_sha256 NOT GLOB '*[^0-9a-f]*'),
 state TEXT NOT NULL CHECK(state IN ('PLANNED','RUNNING','PAUSED','BLOCKED','UNKNOWN','SUCCEEDED','FAILED','CANCELED')),
 created_at_ms INTEGER NOT NULL
) STRICT;
CREATE TABLE run_nodes(
 id TEXT PRIMARY KEY, run_id TEXT NOT NULL REFERENCES runs(id), node_key TEXT NOT NULL,
 effect TEXT NOT NULL CHECK(effect IN ('READ_LOCAL','READ_REMOTE','UPLOAD','PAID_GENERATION','LOCAL_RENDER','PUBLISH','ARBITRARY_EXEC')),
 route_id TEXT REFERENCES model_routes(id),
 state TEXT NOT NULL CHECK(state IN ('PENDING','BLOCKED','READY','WAITING_APPROVAL','RUNNING','SUCCEEDED','FAILED','UNKNOWN','CANCEL_REQUESTED','CANCELED')),
 revision INTEGER NOT NULL DEFAULT 1 CHECK(revision>0),
 UNIQUE(run_id,node_key)
) STRICT;
CREATE TABLE wallets(
 id TEXT PRIMARY KEY, provider_id TEXT NOT NULL REFERENCES providers(id),
 unit TEXT NOT NULL, unit_scale INTEGER NOT NULL CHECK(unit_scale>0),
 available_u INTEGER CHECK(available_u IS NULL OR available_u>=0), observed_at_ms INTEGER,
 UNIQUE(provider_id,unit,unit_scale)
) STRICT;
CREATE TABLE budgets(
 id TEXT PRIMARY KEY, project_id TEXT NOT NULL REFERENCES projects(id), wallet_id TEXT NOT NULL REFERENCES wallets(id),
 limit_u INTEGER NOT NULL CHECK(limit_u>=0), reserved_u INTEGER NOT NULL DEFAULT 0 CHECK(reserved_u>=0),
 spent_u INTEGER NOT NULL DEFAULT 0 CHECK(spent_u>=0),
 CHECK(reserved_u+spent_u<=limit_u), UNIQUE(project_id,wallet_id)
) STRICT;
CREATE TABLE prepared_receipts(
 id TEXT PRIMARY KEY, node_id TEXT NOT NULL REFERENCES run_nodes(id),
 route_id TEXT REFERENCES model_routes(id), connection_id TEXT REFERENCES connections(id),
 capability_snapshot_id TEXT REFERENCES capability_snapshots(id),
 body_json TEXT NOT NULL CHECK(json_valid(body_json)),
 request_sha256 TEXT NOT NULL CHECK(length(request_sha256)=64 AND request_sha256 NOT GLOB '*[^0-9a-f]*'),
 receipt_sha256 TEXT NOT NULL CHECK(length(receipt_sha256)=64 AND receipt_sha256 NOT GLOB '*[^0-9a-f]*'),
 prepared_at_ms INTEGER NOT NULL, expires_at_ms INTEGER NOT NULL,
 CHECK(expires_at_ms>prepared_at_ms)
) STRICT;
CREATE TABLE approvals(
 id TEXT PRIMARY KEY, node_id TEXT NOT NULL REFERENCES run_nodes(id),
 prepared_receipt_id TEXT NOT NULL REFERENCES prepared_receipts(id),
 request_sha256 TEXT NOT NULL CHECK(length(request_sha256)=64 AND request_sha256 NOT GLOB '*[^0-9a-f]*'),
 receipt_sha256 TEXT NOT NULL CHECK(length(receipt_sha256)=64 AND receipt_sha256 NOT GLOB '*[^0-9a-f]*'),
 effect TEXT NOT NULL CHECK(effect IN ('READ_REMOTE','UPLOAD','PAID_GENERATION','LOCAL_RENDER','PUBLISH','ARBITRARY_EXEC')),
 budget_id TEXT REFERENCES budgets(id), max_amount_u INTEGER NOT NULL CHECK(max_amount_u>=0),
 approved_at_ms INTEGER NOT NULL, expires_at_ms INTEGER NOT NULL,
 consumed_at_ms INTEGER, revoked_at_ms INTEGER,
 CHECK(expires_at_ms>approved_at_ms), CHECK(max_amount_u=0 OR budget_id IS NOT NULL)
) STRICT;
CREATE TABLE generation_intents(
 id TEXT PRIMARY KEY, node_id TEXT NOT NULL REFERENCES run_nodes(id),
 idempotency_key TEXT NOT NULL UNIQUE,
 request_sha256 TEXT NOT NULL CHECK(length(request_sha256)=64 AND request_sha256 NOT GLOB '*[^0-9a-f]*'),
 approval_id TEXT NOT NULL UNIQUE REFERENCES approvals(id),
 state TEXT NOT NULL CHECK(state IN ('RESERVED','DISPATCHING','ACKNOWLEDGED','UNKNOWN','SUCCEEDED','KNOWN_FAILED','CANCELED')),
 dispatch_recorded_at_ms INTEGER, created_at_ms INTEGER NOT NULL
) STRICT;
CREATE TABLE reservations(
 id TEXT PRIMARY KEY, intent_id TEXT NOT NULL UNIQUE REFERENCES generation_intents(id),
 budget_id TEXT NOT NULL REFERENCES budgets(id), amount_u INTEGER NOT NULL CHECK(amount_u>=0),
 state TEXT NOT NULL CHECK(state IN ('RESERVED','SETTLED','RELEASED')),
 actual_amount_u INTEGER CHECK(actual_amount_u IS NULL OR actual_amount_u>=0),
 CHECK(state!='SETTLED' OR actual_amount_u IS NOT NULL)
) STRICT;
CREATE TABLE external_jobs(
 id TEXT PRIMARY KEY, intent_id TEXT NOT NULL UNIQUE REFERENCES generation_intents(id),
 provider_id TEXT NOT NULL REFERENCES providers(id), remote_job_id TEXT,
 state TEXT NOT NULL CHECK(state IN ('RUNNING','SUCCEEDED','KNOWN_FAILED','UNKNOWN','CANCEL_REQUESTED','CANCELED')),
 evidence_json TEXT NOT NULL CHECK(json_valid(evidence_json)), observed_at_ms INTEGER NOT NULL,
 UNIQUE(provider_id,remote_job_id)
) STRICT;
CREATE TABLE artifacts(
 id TEXT PRIMARY KEY, node_id TEXT NOT NULL REFERENCES run_nodes(id),
 kind TEXT NOT NULL CHECK(kind IN ('SOURCE','INTERMEDIATE','VIDEO','AUDIO','CAPTIONS','REPORT')),
 relpath TEXT NOT NULL,
 content_sha256 TEXT NOT NULL CHECK(length(content_sha256)=64 AND content_sha256 NOT GLOB '*[^0-9a-f]*'),
 metadata_json TEXT NOT NULL CHECK(json_valid(metadata_json)), created_at_ms INTEGER NOT NULL,
 CHECK(length(relpath)>0 AND substr(relpath,1,1)!='/' AND instr(relpath,':')=0 AND instr(relpath,'\')=0 AND instr('/'||relpath||'/','/../')=0)
) STRICT;
CREATE TABLE reviews(
 id TEXT PRIMARY KEY, artifact_id TEXT NOT NULL REFERENCES artifacts(id),
 kind TEXT NOT NULL CHECK(kind IN ('TECHNICAL','PRODUCT_FIDELITY','AUDIOVISUAL','RELEASE')),
 decision TEXT NOT NULL CHECK(decision IN ('PENDING','PASS','FAIL','REVOKED')),
 evidence_json TEXT NOT NULL CHECK(json_valid(evidence_json)), reviewer_label TEXT NOT NULL, reviewed_at_ms INTEGER NOT NULL
) STRICT;
CREATE TABLE audit_events(
 id INTEGER PRIMARY KEY AUTOINCREMENT, run_id TEXT REFERENCES runs(id),
 node_id TEXT REFERENCES run_nodes(id), intent_id TEXT REFERENCES generation_intents(id),
 event_type TEXT NOT NULL, redacted_json TEXT NOT NULL CHECK(json_valid(redacted_json)), occurred_at_ms INTEGER NOT NULL
) STRICT;
CREATE TABLE app_settings(
 key TEXT PRIMARY KEY, value_json TEXT NOT NULL CHECK(json_valid(value_json)), revision INTEGER NOT NULL CHECK(revision>0)
) STRICT;
CREATE INDEX project_time_idx ON projects(created_at_ms,id);
CREATE INDEX product_version_idx ON product_versions(product_id,revision);
CREATE INDEX run_project_idx ON runs(project_id,created_at_ms,id);
CREATE INDEX node_state_idx ON run_nodes(state,run_id);
CREATE INDEX intent_state_idx ON generation_intents(state,created_at_ms);
CREATE INDEX events_run_idx ON audit_events(run_id,id);
CREATE INDEX asset_hash_idx ON asset_versions(content_sha256);
CREATE INDEX capabilities_route_idx ON capability_snapshots(route_id,captured_at_ms);
CREATE INDEX claims_product_idx ON claims(product_version_id,review_state);
CREATE TRIGGER product_version_no_update BEFORE UPDATE ON product_versions BEGIN SELECT RAISE(ABORT,'IMMUTABLE_PRODUCT_VERSION'); END;
CREATE TRIGGER evidence_no_update BEFORE UPDATE ON evidence BEGIN SELECT RAISE(ABORT,'IMMUTABLE_EVIDENCE'); END;
CREATE TRIGGER workflow_version_no_update BEFORE UPDATE ON workflow_versions BEGIN SELECT RAISE(ABORT,'IMMUTABLE_WORKFLOW_VERSION'); END;
CREATE TRIGGER skill_version_no_update BEFORE UPDATE ON skill_versions BEGIN SELECT RAISE(ABORT,'IMMUTABLE_SKILL_VERSION'); END;
CREATE TRIGGER template_version_no_update BEFORE UPDATE ON template_versions BEGIN SELECT RAISE(ABORT,'IMMUTABLE_TEMPLATE_VERSION'); END;
CREATE TRIGGER scene_no_update BEFORE UPDATE ON scenes BEGIN SELECT RAISE(ABORT,'IMMUTABLE_SCENE_VERSION'); END;
CREATE TRIGGER asset_bytes_no_update BEFORE UPDATE OF asset_id,revision,product_version_id,media_kind,relpath,content_sha256,metadata_json,parent_version_id ON asset_versions BEGIN SELECT RAISE(ABORT,'IMMUTABLE_ASSET_BYTES'); END;
CREATE TRIGGER run_snapshot_no_update BEFORE UPDATE OF project_id,template_version_id,workflow_version_id,snapshot_json,request_sha256 ON runs BEGIN SELECT RAISE(ABORT,'IMMUTABLE_RUN_SNAPSHOT'); END;
CREATE TRIGGER intent_request_no_update BEFORE UPDATE OF node_id,idempotency_key,request_sha256,approval_id ON generation_intents BEGIN SELECT RAISE(ABORT,'IMMUTABLE_INTENT'); END;
CREATE TRIGGER claim_content_no_update BEFORE UPDATE OF product_version_id,claim_text,evidence_id ON claims BEGIN SELECT RAISE(ABORT,'NEW_CLAIM_REQUIRED'); END;
CREATE TRIGGER claim_scope_insert BEFORE INSERT ON claims WHEN NEW.evidence_id IS NOT NULL BEGIN
 SELECT CASE WHEN NOT EXISTS(SELECT 1 FROM evidence e WHERE e.id=NEW.evidence_id AND e.product_version_id=NEW.product_version_id) THEN RAISE(ABORT,'EVIDENCE_PRODUCT_MISMATCH') END;
END;
CREATE TRIGGER product_scene_scope BEFORE INSERT ON scene_assets WHEN NEW.role='PRODUCT' BEGIN
 SELECT CASE WHEN NOT EXISTS(SELECT 1 FROM scenes s JOIN project_products pp ON pp.project_id=s.project_id JOIN asset_versions av ON av.product_version_id=pp.product_version_id WHERE s.id=NEW.scene_id AND av.id=NEW.asset_version_id) THEN RAISE(ABORT,'PRODUCT_ASSET_SCOPE_MISMATCH') END;
END;
CREATE TRIGGER run_template_match BEFORE INSERT ON runs BEGIN
 SELECT CASE WHEN NOT EXISTS(SELECT 1 FROM template_versions t WHERE t.id=NEW.template_version_id AND t.workflow_version_id=NEW.workflow_version_id) THEN RAISE(ABORT,'TEMPLATE_WORKFLOW_MISMATCH') END;
END;
CREATE TRIGGER intent_approval_match BEFORE INSERT ON generation_intents BEGIN
 SELECT CASE WHEN NOT EXISTS(SELECT 1 FROM approvals a JOIN run_nodes n ON n.id=NEW.node_id WHERE a.id=NEW.approval_id AND a.node_id=NEW.node_id AND a.request_sha256=NEW.request_sha256 AND a.effect=n.effect AND a.consumed_at_ms IS NULL AND a.revoked_at_ms IS NULL AND NEW.created_at_ms>=a.approved_at_ms AND NEW.created_at_ms<a.expires_at_ms) THEN RAISE(ABORT,'APPROVAL_INVALID') END;
END;
CREATE TRIGGER intent_consume_grant AFTER INSERT ON generation_intents BEGIN UPDATE approvals SET consumed_at_ms=NEW.created_at_ms WHERE id=NEW.approval_id; END;
CREATE TRIGGER reservation_match BEFORE INSERT ON reservations BEGIN
 SELECT CASE WHEN NOT EXISTS(SELECT 1 FROM generation_intents i JOIN approvals a ON a.id=i.approval_id JOIN run_nodes n ON n.id=i.node_id JOIN runs r ON r.id=n.run_id JOIN budgets b ON b.id=NEW.budget_id JOIN wallets w ON w.id=b.wallet_id JOIN model_routes m ON m.id=n.route_id WHERE i.id=NEW.intent_id AND a.budget_id=NEW.budget_id AND NEW.amount_u<=a.max_amount_u AND b.project_id=r.project_id AND w.provider_id=m.provider_id) THEN RAISE(ABORT,'RESERVATION_SCOPE_OR_AMOUNT_MISMATCH') END;
END;
CREATE TRIGGER scene_claim_scope BEFORE INSERT ON scene_claims BEGIN
 SELECT CASE WHEN NOT EXISTS(SELECT 1 FROM scenes s JOIN project_products pp ON pp.project_id=s.project_id JOIN claims c ON c.product_version_id=pp.product_version_id WHERE s.id=NEW.scene_id AND c.id=NEW.claim_id) THEN RAISE(ABORT,'SCENE_CLAIM_PRODUCT_MISMATCH') END;
END;
CREATE TRIGGER receipt_no_update BEFORE UPDATE ON prepared_receipts BEGIN SELECT RAISE(ABORT,'IMMUTABLE_RECEIPT'); END;
CREATE TRIGGER approval_receipt_match BEFORE INSERT ON approvals BEGIN
 SELECT CASE WHEN NOT EXISTS(SELECT 1 FROM prepared_receipts r WHERE r.id=NEW.prepared_receipt_id AND r.node_id=NEW.node_id AND r.request_sha256=NEW.request_sha256 AND r.receipt_sha256=NEW.receipt_sha256 AND r.prepared_at_ms<=NEW.approved_at_ms AND r.expires_at_ms>=NEW.expires_at_ms) THEN RAISE(ABORT,'APPROVAL_RECEIPT_MISMATCH') END;
END;
CREATE TRIGGER scene_binding_no_update BEFORE UPDATE ON scene_assets BEGIN SELECT RAISE(ABORT,'IMMUTABLE_SCENE_BINDING'); END;
CREATE TRIGGER approval_terms_no_update BEFORE UPDATE OF node_id,prepared_receipt_id,request_sha256,receipt_sha256,effect,budget_id,max_amount_u,approved_at_ms,expires_at_ms ON approvals BEGIN SELECT RAISE(ABORT,'IMMUTABLE_APPROVAL_TERMS'); END;
CREATE TRIGGER external_job_provider_match BEFORE INSERT ON external_jobs BEGIN
 SELECT CASE WHEN NOT EXISTS(SELECT 1 FROM generation_intents i JOIN run_nodes n ON n.id=i.node_id JOIN model_routes m ON m.id=n.route_id WHERE i.id=NEW.intent_id AND m.provider_id=NEW.provider_id) THEN RAISE(ABORT,'JOB_PROVIDER_MISMATCH') END;
END;
-- Budget counter updates + reservations MUST be in the same application transaction.
-- State transitions, graph policy, revocation/readback freshness and secret/path safety
-- are application invariants, not proven by this schema alone.
INSERT INTO schema_migrations VALUES(1,unixepoch('now')*1000);
COMMIT;
