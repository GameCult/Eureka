# Eureka mascot — generation prompt

Intended output: `docs/assets/eureka-mascot-4x.png`, square, referenced from
`README.md` the way Epiphany's avatar is referenced from its own.

Model: OpenAI image model (operator-run). Record the exact model identifier here
when the render lands, beside the render actually chosen.

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
