# Eureka mascot — generation prompt

Intended output: `docs/assets/eureka-mascot-4x.png`, square, referenced from
`README.md` the way Epiphany's avatar is referenced from its own.

Model: OpenAI image model, operator-run, 2026-09-17. **Record the exact model
identifier here** — it is the one piece of provenance still missing.

## What actually shipped, and how to rebuild it

1. **The render**, `eureka-mascot-source.png`, 1254×1254, straight from the
   model on the prompt below. Kept because a render without its prompt has lost
   its provenance, and a prompt without its render cannot be checked.
2. **Repixelized** to a true lattice at 627×627. The render is fake pixel art:
   it looks pixelated without committing to one grid. Rebuild it with:

   ```
   F:\Projects\repixelizer\.venv\Scripts\python.exe -c "from repixelizer.pipeline import run_pipeline; run_pipeline(r'eureka-mascot-source.png', r'out.png', seed=7, steps=48, device='cuda', max_inferred_target_size=1024)"
   ```

   **Do not use `repixelize run` with its defaults for this.** The command line
   is the same pipeline as the hosted service minus two things the service sets:
   it never passes `max_inferred_target_size`, so a large source infers whatever
   it likes, and it defaults to 200 steps where the service uses 48. Configured
   as above it takes about 87 seconds on a GTX 1070; configured by the command
   line's defaults it was still running after four minutes. The service's own
   numbers are in `gui.py`'s `HostedDemoConfig`.

   Also note `python -m repixelizer.cli` does nothing and exits zero: that module
   has no main guard. Use the console script or call the API.
3. **Cropped and lettered by the operator** in Krita, to 441×441. The crop drops
   the tombstones and the balance scale and keeps the specimen case, the
   character and the panel — less busy, and it survives being displayed with big
   chunky pixels. The wordmark is **Ubuntu Light in small caps**, which is the
   brand's prose face rather than its display face; that is deliberate.
   `eureka-mascot.kra` is the editable original.
4. **`eureka-mascot-4x.png`** is `eureka-mascot.png` upscaled ×4 with nearest
   neighbour, to 1764×1764. GitHub's markdown cannot ask a browser for hard
   pixel edges, so the only way to show chunky pixels in a README is to ship an
   image that is already large. Epiphany's avatar uses the same convention.

The intermediate uncropped 627×627 repixelization is not kept, because step 2
rebuilds it exactly.

## The two crops

- **`eureka-mascot.png`** carries the wordmark burned in, and is what the README
  shows through `eureka-mascot-4x.png`. Use it where the surface cannot set
  type: a README, a repository card, anywhere the image has to arrive as one
  thing.
- **`eureka-mascot-clean.png`** is the same crop with **no wordmark**, for
  surfaces that set their own type — the site, a header that wants the name in
  live Ubuntu Light small caps rather than in pixels. Live type there is better
  than burned-in: it stays selectable, it scales without the mascot's lattice
  fighting the text's antialiasing, and it will track the brand if the brand
  moves.

Each has its editable Krita original beside it. **When one crop changes, change
the other**, or the two will drift and the site will quietly disagree with the
README about what Eureka looks like.

Style anchor: `F:\Projects\Epiphany\docs\assets\epiphany-avatar-4x.png` —
detailed pixel art, anime-styled figure, dense labelled environment, one HUD
panel of typed state, a single saturated accent doing the lighting. Eureka is
the same world seen from a different job, so it should read as a sibling image
and not a reskin: Epiphany governs, Eureka disbelieves.

Palette from the GameCult brand (`gamecult-site/site/quartz.config.ts`): ground
`#07111a`, panels `#16212c`, body text `#b7c7d9`, headings `#eef5ff`, accent
`#ff8a2a`, secondary `#59b7ff`. The accent is orange here, deliberately, so the
two images do not sit in the same colour.

Rendered afresh each iteration. Carry ideas forward by rewriting this prompt,
never by feeding a previous render back as a reference.

## Prompt

```
Detailed pixel art illustration, square composition, anime-styled character in a
dense labelled environment, dark techno-gothic mood, crisp dithering and visible
pixel grid, in the style of high-detail 2D game key art.

A small, scrappy inspector — a young figure with sharp narrowed eyes and messy
hair, wearing a heavy dark work coat with glowing orange piping and rolled
sleeves, utility harness, scuffed boots — crouches low on top of a toppled stone
monument. The monument's carved face reads "ALL TESTS PASSING" in large letters,
cracked straight through the middle. She has pried up a floor panel in front of
her with a short orange crowbar held in one hand, and is peering down through
the opening into the machinery beneath: a tangle of pipes, wiring and half-built
mechanism, clearly broken, lit from below with cold blue light that catches her
face from underneath. She is not alarmed. She looks satisfied, like someone who
expected exactly this.

In her other hand, held up and slightly behind her, is a warm orange lantern
that lights the scene above the floor.

Mounted on the wall behind her is an entomologist's specimen case, glass-fronted,
containing a grid of pinned mechanical insects, each with a small handwritten
label beneath it. Most are dead and still. One, near the middle of the case, is
very much alive: struggling against its pin, legs moving, outlined in bright
orange, its label reading "SURVIVED".

Scattered across the scene, on plaques, banners, tags and broken signage, in
weathered readable lettering:
"GREEN" stencilled across the floor panel she has lifted;
"LGTM" on a torn ribbon;
"SELF-REPORTED" on a hanging placard;
"HARNESS NOT FOUND" on a rusted empty bracket where a tool should hang;
"CONSTANT PINNING CONSTANT" on a pair of identical weights on a balance scale
that is obviously level and obviously wrong;
"HONEST GAP" on a tombstone with a fresh crowbar mark across it.

Floating beside her at eye level, a small semi-transparent heads-up panel with a
thin orange border and monospaced text:

  entry: L3
  control: green
  verdict: SURVIVED

Behind everything, receding into the dark, a vast wall of identical green
checkmarks stretching up out of frame, slightly out of focus, their uniformity
faintly menacing.

Colour: near-black blue-green ground (#07111a), dark slate panels (#16212c),
pale blue-white highlights (#eef5ff), cool blue secondary light (#59b7ff), and
one saturated orange accent (#ff8a2a) carrying the lantern, the piping, the
crowbar, the living specimen and the panel border. Orange and cold blue only;
no red, and the green appears solely in the checkmark wall behind.

No modern logos, no watermark, no signature.
```

## Notes for the next iteration

- If the specimen case reads as cruel rather than clinical, make the pinned
  insects obviously mechanical — rivets, hinged plating — rather than organic.
- If "ALL TESTS PASSING" crowds the frame, it can move to the monument's base
  and shrink; the crack through it is the load-bearing detail, not the size.
- The satisfied expression matters. A worried or heroic face makes it a warning
  poster. This character enjoys being right about the floor.
