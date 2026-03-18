# Portfolio — Module 304 (Medical Informatics)

This repository contains your competency portfolio for module 304.

## Structure

| File | Purpose |
|------|---------|
| `student.yaml` | Your name, program, module, project metadata |
| `portfolio.yaml` | All portfolio entries (single file) |
| `questions.yaml` | Weekly hiring-style questions |
| `broken_links.yaml` | Auto-detected broken evidence links |
| `portfolio.typ` | Typst template (do not edit) |
| `.github/workflows/build.yml` | Builds PDF on push |

## Adding entries

Edit `portfolio.yaml` to add new portfolio entries. Each entry specifies
weighted **skills** across three axes. Weights must sum to 1.0.

Entry format:

```yaml
  - title: "Short descriptive title"
    date: "2026-03-06"
    sprint: "W3"
    skills:
      cs_engineer: 0.5
      data_engineer: 0.5
      professionalism: 0.0
    what: >
      What you did — concrete, factual.
    why: >
      Why it matters — which competency it demonstrates.
    reflection: >
      What you learned, what you would do differently.
    evidence:
      - label: "Description of artifact"
        url: "https://github.com/..."
```

## Skill axes

Each entry distributes its weight across three axes. The weights must
sum to 1.0 — the template warns if they don't.

| Axis | Key | Covers |
|------|-----|--------|
| CS Engineer | `cs_engineer` | Analyser, concevoir, implémenter, évaluer |
| Data Engineer | `data_engineer` | Valoriser, orchestrer, appliquer |
| Professionalism | `professionalism` | Communiquer, faciliter, argumenter, critiquer |

## Building the PDF locally

This project uses [pixi](https://pixi.sh) to manage dependencies (Typst, Python).

```bash
# Install pixi (if not already installed): https://pixi.sh
# Then build the portfolio PDF:
pixi run build

# Or step by step:
pixi run check-links    # check evidence URLs → broken_links.yaml
pixi run -- typst compile portfolio.typ portfolio.pdf
```

The PDF is also built automatically on every push via GitHub Actions.
