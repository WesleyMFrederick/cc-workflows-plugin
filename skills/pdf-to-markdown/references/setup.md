# Marker Setup (One-Time)

## Prerequisites

- Python 3.10+
- Local marker repo at `/Users/wesleyfrederick/Documents/ObsidianVault/0_SoftwareDevelopment/marker`

## Create Virtual Environment

```bash
python3 -m venv ~/.venvs/marker
```

## Install Marker

```bash
source ~/.venvs/marker/bin/activate
cd /Users/wesleyfrederick/Documents/ObsidianVault/0_SoftwareDevelopment/marker
pip install -e .
```

**Note:** Heavy ML dependencies (torch, transformers, surya-ocr). Expect:
- Download: ~2-4GB
- Time: 5-10 minutes

## Verify Installation

```bash
source ~/.venvs/marker/bin/activate
marker_single --help
```

Should display usage information if installed correctly.
