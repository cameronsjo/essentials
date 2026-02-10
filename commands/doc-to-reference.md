---
description: Convert PDFs, URLs, or documents into structured markdown reference documentation
disable-model-invocation: true
---

# Convert Document to Reference

Convert PDFs, URLs, or documents into structured markdown reference documentation with proper frontmatter.

## Arguments

- `$ARGUMENTS` - Path to PDF file, URL, or document description

## Workflow

### 1. Determine Source Type

Based on `$ARGUMENTS`:

- **PDF file path** → Use `pdftotext` to extract, then read in chunks (600-1000 lines)
- **URL** → Use WebFetch to retrieve content
- **GitHub repo URL** → Fetch README and relevant specs from raw.githubusercontent.com

### 2. Analyze Content

Identify document type and extract:

- **Title and version**
- **Core concepts** (what problem does it solve?)
- **Architecture** (components, data flow)
- **Key specifications** (message types, APIs, protocols)
- **Security considerations** (if applicable)
- **Implementation guidance**
- **Code examples** (preserve with language hints)

### 3. Create Reference Document

Ask user for output location, or default to: `docs/references/<document-name>.md`

**Required structure:**

```markdown
---
title: "Document Title"
aliases:
  - short-name
  - alternative-name
tags:
  - relevant-tag
  - domain-tag
source: "URL or citation"
spec_version: "X.Y" (if applicable)
created: YYYY-MM-DD
status: active
---

# Document Title

> **One-line summary** - What this document covers.

---

## Overview

2-3 paragraphs explaining the document's purpose and relevance.

---

## [Core Sections]

Organize content logically. Use:

- **Mermaid diagrams** for architecture, sequences, state machines
- **GFM tables** for configuration options, API endpoints, comparisons
- **Code blocks** with language identifiers

---

## Key Takeaways

1. Numbered list
2. Of main insights
3. From this document

---

## References

- [Source Link](url)
- [Related Spec](url)
```

### 4. PDF Processing Strategy

For large PDFs that exceed read limits:

```bash
# Extract to text
pdftotext -layout "/path/to/document.pdf" "/tmp/document.txt"

# Check size
wc -l /tmp/document.txt
```

Then read in chunks:

- First pass: Lines 1-800 (overview, TOC, intro)
- Second pass: Lines 800-1600 (core content)
- Continue as needed...

## Quality Checklist

Before completing:

- [ ] Frontmatter complete with title, tags, source, created date
- [ ] Mermaid diagrams for any architecture/flow descriptions
- [ ] Tables for structured data (not prose lists)
- [ ] Code blocks have language identifiers
- [ ] No broken links

## Example Invocations

```
/doc-to-reference /path/to/security-spec.pdf
/doc-to-reference https://github.com/org/repo
/doc-to-reference https://example.com/whitepaper.html
```
