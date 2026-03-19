// Portfolio CV Template — Module 304 (Medical Informatics)
// Reads structured YAML files and produces a professional A4 PDF.

#import "@preview/mmdr:0.2.1": mermaid

// ── Data loading ──────────────────────────────────────────────
#let student       = yaml("student.yaml")
#let portfolio     = yaml("_portfolio.yaml")
#let questions     = yaml("questions.yaml")
#let broken-links  = yaml("broken_links.yaml")

// ── Colour palette ────────────────────────────────────────────
#let accent-cs   = rgb("#2563eb")   // blue
#let accent-data = rgb("#059669")   // emerald
#let accent-prof = rgb("#9333ea")   // purple
#let accent-q    = rgb("#64748b")   // slate

// ── Axis colours & labels ────────────────────────────────────
#let axis-color = (cs: accent-cs, data: accent-data, prof: accent-prof)
#let axis-label = (cs: "CS", data: "Data", prof: "Soft-skills")

// ── Page & text setup ─────────────────────────────────────────
#set page(
  paper: "a4",
  margin: (top: 2cm, bottom: 2cm, left: 2cm, right: 2cm),
  footer: context [
    #set text(8pt, fill: luma(140))
    #student.name — Module #student.module
    #h(1fr)
    #counter(page).display("1 / 1", both: true)
  ],
)

#set text(font: ("Helvetica Neue", "Helvetica", "DejaVu Sans"), size: 10pt, lang: "en")
#set par(justify: true, leading: 0.65em)

// ── Helper: skill bar ─────────────────────────────────────────
#let skill-bar(skills) = {
  let raw = (
    ("CS",          skills.at("cs_engineer",    default: 0), accent-cs),
    ("Data",        skills.at("data_engineer",   default: 0), accent-data),
    ("Soft-skills", skills.at("professionalism", default: 0), accent-prof),
  )
  // Convert to fractions
  let segs = raw.map(((lbl, w, c)) => {
    let frac = if type(w) == ratio { w } else { float(w) * 100% }
    (lbl, frac, c)
  }).filter(((_, frac, _)) => frac > 0%)
  // Sort descending by weight
  let segs = segs.sorted(key: ((_, frac, _)) => -frac / 1%)

  set text(7pt, weight: "bold", fill: white)
  box(width: 100%, height: 12pt, radius: 3pt, clip: true,
    stack(dir: ltr,
      ..segs.map(((lbl, frac, c)) => {
        let pct = calc.round(frac / 1%)
        box(width: frac, height: 12pt, fill: c,
          align(center + horizon, text(lbl + " " + str(pct) + "%")))
      })
    )
  )
}

// ── Helper: render text with inline mermaid blocks ────────────
#let mermaid-re = regex("(?s)```mermaid[ \t]*\n(.*?)```")

#let render-field(content) = {
  if content == none or content == "" { return }
  let ms = content.matches(mermaid-re)
  if ms.len() == 0 {
    text(size: 9.5pt, content)
  } else {
    let pos = 0
    for m in ms {
      let before = content.slice(pos, m.start)
      if before.trim() != "" {
        text(size: 9.5pt, before.trim())
        v(4pt)
      }
      align(center,
        block(width: 85%, mermaid(m.captures.first()))
      )
      v(4pt)
      pos = m.end
    }
    let after = content.slice(pos)
    if after.trim() != "" {
      text(size: 9.5pt, after.trim())
    }
  }
}

// ── Helper: entry block ───────────────────────────────────────
#let entry-block(e) = {
  // Title row
  grid(
    columns: (1fr, auto),
    align: (left, right),
    text(weight: "bold", size: 11pt, e.title),
    text(size: 9pt, fill: luma(100),
      [#e.at("sprint", default: "") — #e.date]),
  )
  v(3pt)

  // Skill weights
  {
    let skills = if "skills" in e { e.skills } else { none }
    if skills != none {
      skill-bar(skills)
      // Warn if weights don't sum to 1.0 (tolerance ±0.05)
      let total = (float(skills.at("cs_engineer", default: 0))
               + float(skills.at("data_engineer", default: 0))
               + float(skills.at("professionalism", default: 0)))
      if calc.abs(total - 1.0) > 0.05 {
        v(2pt)
        text(size: 9pt, fill: rgb("#dc2626"),
          [⚠ #text(size: 8pt, weight: "semibold")[(skills sum to #calc.round(total, digits: 2) instead of 1.0)]])
      }
    }
  }
  v(2pt)

  // What
  if "what" in e and e.what != none and e.what != "" {
    text(weight: "semibold", size: 9pt, fill: luma(80), [What: ])
    render-field(e.what)
    v(3pt)
  } else {
    text(size: 9pt, fill: rgb("#dc2626"),
      [⚠ #text(size: 8pt, weight: "semibold")[(missing what)]])
    v(3pt)
  }

  // Why
  if "why" in e and e.why != none and e.why != "" {
    text(weight: "semibold", size: 9pt, fill: luma(80), [Why: ])
    render-field(e.why)
    v(3pt)
  } else {
    text(size: 9pt, fill: rgb("#dc2626"),
      [⚠ #text(size: 8pt, weight: "semibold")[(missing why)]])
    v(3pt)
  }

  // Reflection
  if "reflection" in e and e.reflection != none and e.reflection != "" {
    text(weight: "semibold", size: 9pt, fill: luma(80), [Reflection: ])
    render-field(e.reflection)
    v(3pt)
  } else {
    text(size: 9pt, fill: rgb("#dc2626"),
      [⚠ #text(size: 8pt, weight: "semibold")[(missing reflection)]])
    v(3pt)
  }

  // Evidence links
  if "evidence" in e and e.evidence != none and e.evidence.len() > 0 {
    text(weight: "semibold", size: 9pt, fill: luma(80), [Evidence: ])
    for ev in e.evidence {
      let target = ev.at("url", default: ev.at("path", default: ""))
      if target != "" and broken-links != none and target in broken-links {
        text(size: 9pt, fill: rgb("#dc2626"),
          [⚠ #ev.label #text(size: 8pt, weight: "semibold")[(broken link)]])
        [ ]
      } else if target != "" {
        [#link(target)[#text(size: 9pt, fill: accent-cs, ev.label)]  ]
      } else {
        text(size: 9pt, ev.label)
        [ ]
      }
    }
    v(2pt)
  } else {
    text(size: 9pt, fill: rgb("#dc2626"),
      [⚠ #text(size: 8pt, weight: "semibold")[(missing evidence)]])
    v(2pt)
  }

  // Inline figures
  if "figures" in e and e.figures != none and e.figures.len() > 0 {
    v(4pt)
    for fig in e.figures {
      align(center,
        block(width: 85%, {
          image(fig.path, width: 100%)
          if "caption" in fig and fig.caption != none and fig.caption != "" {
            v(2pt)
            text(size: 8pt, fill: luma(100), style: "italic", fig.caption)
          }
        })
      )
      v(4pt)
    }
  }
}


// ── Header ────────────────────────────────────────────────────
#align(center)[
  #text(size: 22pt, weight: "bold", student.name)
  #v(2pt)
  #text(size: 10pt, fill: luma(80), student.program)
  #v(1pt)
  #text(size: 10pt, fill: luma(80), [Module #student.module])
  #v(1pt)
  #text(size: 10pt, fill: luma(80), [Project: #student.project])
  #v(1pt)
  #text(size: 9pt, fill: luma(120), student.semester)
]

// ── Portfolio entries (flat, no section headings) ───────────
#let entries = portfolio.at("entries", default: ())
#if entries == none { entries = () }

#for (i, e) in entries.enumerate() {
  entry-block(e)
  if i < entries.len() - 1 {
    v(4pt)
    line(length: 100%, stroke: 0.3pt + luma(200))
    v(4pt)
  }
}

#if entries.len() == 0 {
  text(size: 9pt, fill: luma(140), style: "italic", [No entries yet.])
}

// ── Questions section ─────────────────────────────────────────
#v(8pt)
#line(length: 100%, stroke: 0.5pt + accent-q)
#v(4pt)
#text(size: 14pt, weight: "bold", fill: accent-q, "Hiring-Style Questions")
#v(6pt)

#let weeks = questions.at("weeks", default: ())
#if weeks == none { weeks = () }
#for w in weeks {
  text(weight: "bold", size: 10pt, [Week #w.week])
  v(2pt)
  let items = w.at("items", default: ())
  if items == none { items = () }
  for (i, item) in items.enumerate() {
    if type(item) == str {
      text(size: 9.5pt, [#{i + 1}. *Q:* #item])
      v(1pt)
      text(size: 9pt, fill: rgb("#dc2626"), [   ⚠ #text(size: 8pt, weight: "semibold")[(missing answer)]])
      v(1pt)
    } else {
      // Question with answer
      text(size: 9.5pt, [#{i + 1}. *Q:* #item.question])
      v(1pt)
      if "answer" in item and item.answer != none and item.answer != "" {
        text(size: 9pt, fill: luma(60), [   _A:_ #item.answer])
      } else {
        text(size: 9pt, fill: rgb("#dc2626"), [   ⚠ #text(size: 8pt, weight: "semibold")[(missing answer)]])
      }
      v(1pt)
    }
  }
  v(4pt)
}
