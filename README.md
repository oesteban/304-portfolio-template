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

Edit `portfolio.yaml` to add new portfolio entries. Each entry lists 1–3
**competencies** from the enum below — the template auto-derives axis weights.

Entry format:

```yaml
  - title: "Short descriptive title"
    date: "2026-03-06"
    sprint: "W3"
    competencies:
      - implementer
      - valoriser
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

## Competency enum

Pick 1–3 from this list. The template maps each to its axis and computes
proportional weights automatically.

| Key | Axis | Competency |
|-----|------|------------|
| `analyser` | CS Engineer | Analyser un problème informatique complexe |
| `concevoir` | CS Engineer | Concevoir une solution théorique modélisée |
| `implementer` | CS Engineer | Implémenter une approche théorique modélisée |
| `evaluer` | CS Engineer | Évaluer un système informatique |
| `valoriser` | Data Engineer | Valoriser des ensembles de données hétérogènes et multimodales |
| `orchestrer` | Data Engineer | Orchestrer un processus et une infrastructure de traitement de données |
| `appliquer` | Data Engineer | Appliquer les compétences de l'ingénierie en informatique au domaine des données |
| `communiquer` | Professionalism | Communiquer clairement et efficacement |
| `faciliter` | Professionalism | Adopter une posture professionnelle facilitante |
| `argumenter` | Professionalism | Argumenter ses opinions et ses choix |
| `critiquer` | Professionalism | Critiquer le déroulement d'une production de manière auto-réflexive |

**Weight derivation example:**
- `[implementer, valoriser]` → CS 50%, Data 50%
- `[analyser, concevoir]` → CS 100%
- `[implementer, valoriser, communiquer]` → CS 33%, Data 33%, Soft-skills 33%

## Building the PDF locally

```bash
# Install Typst: https://typst.app
typst compile portfolio.typ portfolio.pdf
```

The PDF is also built automatically on every push via GitHub Actions.
