---
name: pdf-to-markdown
description: Use when converting PDFs to markdown with image extraction using marker - handles single files with automatic image extraction and OCR
---

# PDF to Markdown Conversion

Convert PDFs to markdown with automatic image extraction using marker.

## Quick Start

```bash
source ~/.venvs/marker/bin/activate
marker_single "input.pdf" --output_dir "./output"
```

**First time?** See [setup.md](references/setup.md) to install marker.

## Command Syntax

```bash
marker_single "<pdf_path>" --output_dir "<output_dir>"
```

## Output Structure

```text
{output_dir}/
└── {pdf_name}/
    ├── {pdf_name}.md              # Markdown output
    ├── {pdf_name}_meta.json       # Metadata
    ├── _page_1_Figure_1.jpeg      # Extracted images
    └── _page_N_Picture_X.jpeg     # More images
```

## Key Behaviors

- Images extracted **by default** (no flag needed)
- Images saved in same folder as markdown
- Markdown uses relative image paths: `![](_page_1_Figure_1.jpeg)`
- Output folder auto-created from PDF filename
- Processing time: ~5-10 min for 20-page PDF (first run downloads models)

## Verification

1. Check markdown file exists: `ls {output_dir}/{pdf_name}/`
2. Verify images extracted
3. Open markdown and confirm image references work
