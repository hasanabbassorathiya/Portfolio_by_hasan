A RAG demo takes a weekend. A RAG feature that survives a year of real users takes a different discipline, because the failure modes have nothing to do with the model. They are about what you put in the context window, what happens when the answer is not there, and whether anyone notices when retrieval quietly gets worse.

I build these systems for products with actual support queues — WordPress-backed sites, internal knowledge bases, mobile apps with offline content — and the pattern is always the same. The generation step is the easy part. Everything below is what I do before and around it.

## Retrieval is the product

Users do not judge a RAG system on its prose. They judge it on whether the right paragraph was in the context window. When an answer is wrong, the prompt is almost never the cause; the retrieval was.

So the first thing I instrument is not the LLM call, it is the retrieval: which chunks were returned, at what rank, and whether a human would have picked them. If recall is bad, no prompt engineering saves the feature.

## Chunk by structure, not by token count

Fixed-size chunking with overlap is the default in every tutorial, and it is the fastest way to produce fragments that answer half a question. Documentation has structure — headings, sections, tables, code blocks. Use it.

```python
def chunk_markdown(doc):
    # keep each heading section intact; split only when it exceeds the limit
    for section in split_on_headings(doc):
        header = section.heading_path  # e.g. "Billing > Refunds > Partial refunds"
        for part in pack(section.body, max_tokens=450, overlap=40):
            yield {
                "text": part,
                "title": header,          # prepended to the embedding input
                "source": section.url,
                "updated_at": section.updated_at,
            }
```

Two details matter more than the size itself. First, embed the heading path with the text — a chunk that says "the window is 14 days" is useless without "Refunds" attached to it. Second, keep the source URL and the last-updated timestamp in the payload, because you will need both later, for citations and for freshness.

Tables, pricing grids, and error-code lists should never be split. A half of a rate table is worse than no table.

## Hybrid retrieval, not vibes

Embeddings are excellent at meaning and surprisingly bad at identifiers. Ask for "error E4021" or "the Enterprise plan" and pure vector search will return conceptually similar passages that do not contain the string. Keyword search has the opposite problem.

I run both and merge:

```python
def retrieve(query, k=8):
    dense = vector_search(embed(query), limit=20)
    sparse = keyword_search(query, limit=20)   # BM25 / Postgres tsvector
    fused = reciprocal_rank_fusion(dense, sparse, k=60)
    return rerank(query, fused)[:k]
```

Reciprocal rank fusion is a dozen lines and needs no tuning. It consistently beats either retriever alone on the queries real users type: product names, plan tiers, SKUs, error codes, and typos.

## Rerank before you generate

A cheap cross-encoder reranker over the top 20 candidates is the highest-leverage upgrade in the whole pipeline. Retrieval returns things that are topically close; reranking orders them by whether they actually answer the question. In my experience it fixes more bad answers than switching to a larger generation model, and it costs a fraction of the difference.

If you only have budget for one quality improvement, make it this one.

## Citations are a contract, not a UI feature

Every answer carries the sources it used, and the model must return them as structured data, not prose:

```json
{
  "answer": "Partial refunds are available within 14 days of purchase.",
  "citations": [{ "id": "refunds-partial", "title": "Billing > Refunds" }],
  "confidence": "high"
}
```

Then validate: every citation id must exist in the retrieved set, and an answer with no citations is treated as a failure, not a success. This one rule catches most hallucinations before a user sees them — a model that cannot point at a source is usually making something up.

## Build the eval set before the prompt

The most common mistake I see is prompt-tuning against a handful of examples the developer already knows the answer to. Instead, collect 30 to 50 real questions from support tickets, search logs, or the sales team. For each one, record the correct source document, not just the correct answer.

Then measure two numbers separately:

| Metric | Question it answers | Fix when it fails |
|--------|--------------------|-------------------|
| Retrieval recall@k | Was the right document in the context? | Chunking, hybrid search, reranking |
| Answer accuracy | Was the final answer correct and cited? | Prompt, model, refusal threshold |

If recall is below roughly 90 percent on your golden set, stop touching the prompt. You are optimizing the wrong stage.

## Freshness is an operations problem

Models do not go stale; indexes do. A RAG system without an ingestion pipeline is a snapshot of your documentation from the day it was built, and it will confidently answer with last quarter's pricing.

What I put in place from day one:

- Content hashing per document, so re-ingestion only re-embeds what changed.
- Hard deletes propagated to the index — removed pages are the worst kind of stale, because the model still cites them.
- A visible `updated_at` on every chunk, surfaced in citations when the source is older than the product's change cadence.
- A nightly job that reports document count, embedding failures, and the age of the oldest chunk per source.

None of this is glamorous. All of it is what separates a demo from something you can leave running.

## The refusal path is a feature

Real users ask questions your knowledge base cannot answer. The system has to say so, cleanly and without inventing a plausible paragraph.

I gate on three signals: the top reranked score, whether any citation validated, and whether the question is in scope at all. When the gate fails, the response is a short, honest sentence plus a handoff — a link to contact support, or a form pre-filled with the question. Users forgive "I don't know" far more readily than a confident wrong answer, and the handoff turns a dead end into a lead.

## Budget latency like a product requirement

Streaming hides generation time but not retrieval. My rough budgets for an interactive assistant:

- Retrieval and reranking: under 400 ms.
- Time to first token: under 1.2 s.
- Full answer: under 6 s for a paragraph-length response.

If retrieval is slow, it is usually a missing index or an unnecessary re-embed of the query. Cache embeddings for repeated questions, cap the context at the smallest size that preserves recall, and never let the reranker see more than a few dozen candidates.

## The checklist I actually use

- Chunk by document structure, with headings embedded alongside the text.
- Hybrid retrieval with rank fusion; never pure vector search on product content.
- Rerank the top candidates before generation.
- Citations as validated structured output, not prose.
- A golden set of real questions, with recall measured separately from answer quality.
- Incremental ingestion, hard deletes, and a visible freshness signal.
- A deliberate refusal path with a human handoff.
- Latency budgets written down and tested like any other requirement.

The model will change every few months. These decisions will not. That is the point: a RAG system that survives real users is mostly a retrieval and operations system, with a language model at the end of it.

If you are building one and want a second opinion on the retrieval layer, [send me the details](mailto:hasanabbassorathiya12@gmail.com?subject=RAG%20system). I have broken enough of these to know where they fail.
