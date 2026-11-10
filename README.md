# Energy research knowledge graph

Curated Neo4j graph for the 35 documents in `corpus/` and the 10 questions in `queries.txt`. No LLM calls at runtime.

## Neo4j setup

Use local Neo4j via Docker Compose, or point the app at a remote Neo4j instance by setting `NEO4J_URI`, `NEO4J_USERNAME`, `NEO4J_PASSWORD`, and optionally `NEO4J_DATABASE`.

For local setup, create `.env` from `.env.example`, then start Neo4j:

```bash
uv sync
docker compose up -d --wait
```

For remote setup, put connection settings in a file such as `.env.remote`. Run the full pipeline with that file:

```bash
uv run kge --env .env.remote --output answers.csv
```

The `--env` option accepts any env file path, including `.txt` files containing `KEY=value` entries. Without `--env`, settings load from project-root `.env`.

## Run

Run full pipeline—rebuild graph, answer all questions, export CSV:

```bash
uv run kge --output answers.csv
```

Local mode requires Docker Compose; remote mode requires a reachable Neo4j instance. **The pipeline deletes all data in its configured database before rebuilding. Do not point it at a shared database.**

## Files and output

- `queries.cypher`: schema constraints, source documents, curated entities and relationships. All graph setup is here; no APOC or external import required.
- `questions.json`: `question_no`, `category` (from `queries.txt`), `question`, `llm_answer`, and one executable `query` per question. All question columns, including category, are retained in CSV export. Queries require no parameters and also run directly in Neo4j Browser.
- `app/settings.py`: Pydantic settings and automatic `.env` loading.
- `app/corpus.py`: question/setup file loading and validation.
- `app/database.py`: Neo4j connections, atomic graph loading, and read-only querying.
- `app/exports.py`: CSV generation.
- `main.py`: pipeline implementation, invoked via `uv run kge`.
- `answers.csv`: generated output with every `questions.json` column plus `graph_answer`. Nested graph results are JSON strings inside correctly quoted CSV cells. Existing output is overwritten. Excel can open this CSV; `.xlsx` is not generated.

`llm_answer` stays unchanged as the earlier corpus-based reference; `graph_answer` is produced independently by Cypher, not copied from that reference.

The loader understands this curated script's semicolon-separated statements and full-line `//` comments. Do not put semicolons inside string literals or comments, or add inline comments.

## Graph model

Nodes: `Researcher`, `Organization`, `Project`, `Publication`, `Site`, `Patent`, `Technology`, `Document`. Domain nodes also have the `Entity` label and a globally unique stable `id`. Funding agencies are organizations with `kind: funding_agency`; countries are organization properties.

```text
Researcher   -AFFILIATED_WITH {kind, current, dates}-> Organization
Researcher   -MOVED_TO {from_id, year, kind}-> Organization
Researcher   -SUPERVISED_BY-> Researcher
Researcher   -POSTDOC_UNDER-> Researcher
Researcher   -AUTHORED-> Publication
Organization -PARTICIPATES_IN {role}-> Project
Organization -FUNDS {amount, currency}-> Project
Publication  -OUTPUT_OF-> Project
Publication  -CITES-> Publication
Publication  -ABOUT-> Technology
Organization -HOLDS-> Patent
Researcher   -INVENTED-> Patent
Site         -USES_PATENT-> Patent
Site         -ESTABLISHED_UNDER-> Project
Organization -OPERATES-> Site
Patent       -LICENSED_IN-> Project
```

Co-authorship and collaboration are derived from shared papers/projects, not duplicated as stored edges. `MOVED_TO` records explicit transitions rather than guessing from unordered affiliations. Unknown dates remain absent and appear as JSON `null` in results.

All domain nodes and relationships have `sources`, a list of document IDs. `Document.filename` identifies the source file; graph metadata does not depend on its ingestion directory. Example evidence lookup:

```cypher
MATCH (organization:Organization)-[role:PARTICIPATES_IN]->(:Project {id: 'alpine'})
UNWIND role.sources AS source_id
MATCH (document:Document {id: source_id})
RETURN organization.name, role.role, document.filename;
```

The graph is question-focused, not an exhaustive representation of every sentence. Symposium details, laboratories, journal metadata, and unrelated staff roles are not modeled. Edit `queries.cypher` and reload when adding facts; extraction is curated, not automatic.

## Interpretation rules

1. **Affiliations/countries:** use corpus-current organizational affiliations, not nationality or unverified publication-time affiliations. Historical study and visits remain available for mobility. Multiple current countries would all be excluded from a researcher's foreign co-author count.
2. **Lineage:** student → doctoral supervisor; include current students and explicitly recorded completed doctorates. Postdoctoral mentorship is separate. A chain ends where the corpus supplies no further supervisor, not where an academic lineage is known to end.
3. **Mobility:** Priya's 2019 Canadian sabbatical is a temporary visit, not a permanent move. Hannah's employment start year is unknown; 2018 is her doctorate completion year.
4. **Funding:** exact amounts and original currencies; no exchange-rate conversion. Supplying cells does not make Lumen a MONSOON consortium member.
5. **Citations:** incoming direct and transitive citation paths to the 2022 cathode paper, excluding the target itself.
6. **Collaboration:** one hop means organization → project → organization. Return all simple paths within two hops, plus each destination's minimum distance. Funding, supply, and exchange relationships do not count.
7. **Patents:** explicitly recorded design use only. The MONSOON site uses the patent, but the only recorded project licence is ALPINE.
8. **Recommendations:** no co-authored paper *recorded in this corpus*, at least one shared co-author, and at least one shared topic in authored papers. Include explicitly supported secondary topics, as agreed. Return all 15 qualifying pairs with paper evidence; the five pairs in `llm_answer` are examples, not an exhaustive list.

The corpus places Vestfjord/Tiruvallur/Fraser Valley commissioning after some papers using their data. Preserve stated years; do not invent pre-commissioning activity or silently correct dates.

