# Asset-conditioned video continuity and hybrid routing

Use when the brief requires repeated characters, locations/backgrounds, products/props, wardrobe, style or voices across generated clips, including Flow plus Seedance. Treat real attachment/reuse of authorized reference assets as a requirement; prompt repetition alone does not satisfy it.

## Reference contract

- Keep canonical local source assets, immutable revisions, computed hashes, role assignments, ownership/consent and derivation history. A generated frame is a reviewed derivative, not a replacement for the canonical identity/location baseline.
- Separate semantic role from media kind and provider-native feature. A location may be a generic image ingredient; a wardrobe role does not imply an independent native slot. Uploaded audio support does not imply arbitrary voice cloning.
- Scope remote asset/character/voice handles by provider, platform, account, project and model/mode where applicable. Do not transfer native IDs between providers or invent IDs absent from the UI.
- Compile reference labels only after the actual upload/selection order is known. Resolve filename collisions and same-name/different-content revisions explicitly.
- Clear stale references and read back the active model, settings, prompt and selected asset chips before requesting approval. A prepared receipt must reflect the current UI, not just intended inputs. Visible chips establish UI selection, not proof the model preserved identity.
- Unknown reference limits or combinations are UNKNOWN, not SUPPORTED. Check exact route/model/mode total limits and per-kind limits independently. Do not transfer API limits to a web product or infer that first/last frames can be combined with omni-reference.

## Hybrid controls

- Distinguish model family from service route: Flow UI, Dreamina/Jimeng web, ModelArk/Volcengine APIs and Higgsfield web/MCP/API may differ in input policy, entitlement, wallet, price and retention.
- Distinguish structured 3D from generative footage. A skill using Higgsfield to rent a Blender GPU is not evidence it uses Seedance for the rendered images. Reuse mesh/material/rig/camera/timing revisions for mechanical continuity, and preserve render settings and domain checks; an image reference is not a substitute for a structured scene.
- For a cost-minimizing Blender route, verify the installed coding worker's actual MCP support and current models, then inspect live CPU/RAM/GPU/VRAM and Blender discovery. Treat missing PATH/registry entries as incomplete installation discovery, not proof no portable Blender exists. Benchmark a representative local scene before quoting savings or renting GPUs.
- Use MCP for interactive scene authoring/inspection when it adds value, and saved versioned scripts/.blend plus batch rendering for long jobs. An MCP bridge does not accelerate rendering. Review loopback/authentication, arbitrary Python execution, telemetry defaults and optional paid asset APIs before adoption; a safe-mode validator is not an OS sandbox.
- Treat GPU rental as an ongoing paid resource, not a one-shot generation. Persist rental identity, measure elapsed-cost projection, verify shutdown state on success/failure/cancel and plan a watchdog independent of the conversation. Idle auto-pause and a budget instruction are not hard runtime spending caps. Shell stage markers must fail closed and propagate upload/encode/render failures before declaring DONE.
- Before cross-provider handoff, verify identity/face authorization, provider trust provenance/expiry, regional eligibility, upload consent and commercial rights. Vendor preset/reference-library assets can have narrower rights than user-owned assets. Never bypass input restrictions by cropping, screenshots, recompression or misleading synthetic labels.
- Do not assume native Character or voice bundles are portable. Default one dialogue/identity continuity group to one approved engine until a cross-engine handoff passes real audiovisual QA. Shared authorized narration in finishing is a separate option, not evidence of native cross-engine lip-sync.
- Route only among providers that meet hard asset/capability/rights constraints. Credit availability alone is insufficient. Present a new resolved route, exact model and quote for approval; no silent fallback, reference dropping, resolution downgrade, purchase or auto top-up.
- Track wallets separately, including credit unit, available balance, reserved amount, quota/concurrency, expiry/reset, observation time and confidence. Never add different vendor credits as one interchangeable balance. Do not assume manual-web Unlimited/free entitlements include automation, MCP or API.

## Submission and evidence

- Keep prepare separate from paid generation. Character/image creation, voice preview, extension, upscale and draft/finalize can incur auxiliary costs; classify before calling. Picker Enter/focus races can also accidentally submit: prove a pre-dispatch deny-generation gate before automated prepare. A post-send observer can detect an unwanted request but cannot guarantee it prevented charges; if prevention cannot be proven, use manual selection or BLOCKED rather than a zero-spend claim.
- Trace every required field from registry through resolver, provider adapter and actual submission. A location schema, reference_audio DTO or standalone multi-reference helper does not prove the scene path forwards it. Record any deliberate omissions/degradation and reject them when the role is required.
- Persist immutable intent/request hash, atomic local claim and budget reservation before dispatch. One writer per tab. A crash/timeout after click is UNKNOWN; reconcile existing provider jobs before any new request, including cross-provider reroutes. Local deduplication is not provider exactly-once delivery.
- Review full clips/audio and transitions for character, wardrobe, location landmarks/layout, product variant/geometry/labels, voice/speaker assignment and lip-sync. Automated similarity or sampled frames are triage, not full QA.
- Compare actual accepted-shot quality and all-attempt costs. More models, references or generations do not prove better output. Cost per accepted shot is undefined when no shots pass.
- Preserve source captures and retrieval dates. When hashing on Windows, state whether the digest is of raw file bytes or UTF-8 LF-normalized text; verify that exact representation rather than silently treating them as identical.
