# Conversation Summary for Continuation

## Project: Momi's Adventure (Godot 4.5 GDScript Action RPG)

**Project location:** `C:\Users\major\momi-chronicles`
**Planning system:** `.planning/` directory with GSD framework
**Config:** `.planning/config.json` — yolo_mode: true, autonomous_execution: true, skip_confirmations: true, auto_commit: false, profile: "quality"

---

## What Was Done This Session

### 1. Committed API Generator Script
- `tools/gemini_api_generate.py` — fully automated image generator using google-genai SDK
- Fixed bugs: Windows unicode encoding (replaced em-dashes, checkmarks, arrows with ASCII), `global` scope error, model compatibility
- **Commit:** `088ab22` — `feat: add Gemini API image generator for automated sprite generation`

### 2. Discovered API Limitations
- **Imagen 3.0** (`imagen-3.0-generate-001`) — does NOT exist in the API anymore (404)
- **Imagen 4** (`imagen-4.0-*`) — requires billing ("only accessible to billed users")
- **Gemini image models** (Flash exp, 2.5 Flash Image, 3 Pro Image) — free tier daily quota exhausted (limit: 0)
- **Text models work fine** — only image generation quota is at 0

### 3. Researched Correct API Usage
- Imagen 4 uses `client.models.generate_images()` (NOT `generate_content()`)
- Gemini image models use `client.models.generate_content()` with `response_modalities=['IMAGE']` or `['TEXT', 'IMAGE']`
- The script was updated to use `generate_content()` for Gemini models, but...

### 4. KEY DECISION PENDING: Switch to Imagen 4 Fast
- User researched pricing and is considering enabling billing
- **Imagen 4 Fast** = `$0.02/image` × 96 images = **$1.92 total** (cheapest option)
- Script needs to be switched BACK to `generate_images()` API with model `imagen-4.0-fast-generate-001`
- User showed interest, asked for code examples, then needed to restart PC

---

## IMMEDIATE NEXT STEP

**Switch the script to Imagen 4 Fast and run it.** Here's exactly what to do:

### Step 1: Update `tools/gemini_api_generate.py`
The script currently uses `generate_content()` with Gemini models. It needs to be switched to:

```python
# Change DEFAULT_MODEL to:
DEFAULT_MODEL = "imagen-4.0-fast-generate-001"

# Change generate_image() function to use:
response = client.models.generate_images(
    model=model,
    prompt=prompt,
    config=types.GenerateImagesConfig(
        number_of_images=1,
        aspect_ratio="1:1",
        output_mime_type="image/png",
    ),
)
# Save with:
response.generated_images[0].image.save(str(output_path))
```

### Step 2: User must enable billing
- Go to https://aistudio.google.com
- Enable billing on their Google AI project
- Same API key should then work: `AIzaSyAYVZjfBwfFF55N9wGhEF20Qdq8S8DKdVU`

### Step 3: Run the generator
```bash
python tools/gemini_api_generate.py --api-key AIzaSyAYVZjfBwfFF55N9wGhEF20Qdq8S8DKdVU
```
- 96 images, ~6s between requests = ~10 minutes
- Skip-existing means it can resume if interrupted
- Cost: ~$1.92

### Step 4: Post-generation
```bash
python art/rip_sprites.py   # background removal + downscale
```

### Step 5: Mark Phase 31 complete, proceed to Phase 32

---

## Key Files

| File | Purpose |
|------|---------|
| `tools/gemini_api_generate.py` | API-based image generator (needs Imagen 4 Fast switch) |
| `tools/gemini_automation.py` | Browser-based generator (fallback, no billing needed) |
| `art/prompts.json` | 96 structured prompts across 8 categories |
| `art/rip_sprites.py` | Background removal + downscale pipeline |
| `art/generated/` | Output directory (8 subdirs, currently empty except 2 test PNGs) |
| `.planning/STATE.md` | Currently at Phase 31 (user-driven checkpoint) |
| `.planning/ROADMAP.md` | Phase 30 ✅, Phases 31-35 pending |

## Git Log (Recent)
```
088ab22 feat: add Gemini API image generator for automated sprite generation
7d702f2 docs(30): complete Art Pipeline Tooling phase
39e2987 docs(30-01): complete Gemini art automation plan
6d81868 feat(30-01): create Gemini art automation tool
9689618 docs(30): create phase plan
4353784 docs: create v1.6 Visual Polish roadmap (phases 30-35)
6698a27 feat: add DebugLogger, equipment levels, item drops, new items, effects params
```

## User's API Key
`AIzaSyAYVZjfBwfFF55N9wGhEF20Qdq8S8DKdVU`

## Pricing Reference (Imagen 4)
| Model | Per Image | 96 Images |
|-------|-----------|-----------|
| Imagen 4 Fast | $0.02 | $1.92 |
| Imagen 4 Standard | $0.04 | $3.84 |
| Imagen 4 Ultra | $0.06 | $5.76 |

## User Preferences
- Wants things **fully automated** — "run it for me"
- yolo_mode: true — don't ask, just do
- Was about to enable billing before restarting PC
