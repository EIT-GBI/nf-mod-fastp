# nf-mod-fastp

Nextflow module for fastp (paired-end read trimming and QC). Used as a git submodule by pipelines.

Image: `ghcr.io/eit-gbi/nf-mod-fastp`

## Processes

Each subtool lives in its own folder (nf-core style), with a `main.nf`, a
`meta.yml` and an nf-test case under `tests/`.

| Process | Path | Inputs | Emits |
| --- | --- | --- | --- |
| `FASTP_TRIM` | `trim/main.nf` | `tuple val(meta), path(r1), path(r2)` | `reads`, `html`, `log` |

## Publishing

These processes do **not** publish their own outputs. Publishing is the
consuming pipeline's job, via a workflow `output {}` block. This keeps the
module reusable across pipelines that want different result layouts.

## Tool arguments

Flags are passed through `task.ext.args` (and `args2`/`args3` where a process
runs more than one command) rather than read from pipeline `params`, so the
module never depends on a particular pipeline's parameter names:

```groovy
process {
    withName: FASTP_TRIM {
        ext.args = '--some-flag'
    }
}
```

## Use as submodule

Pin to a release tag rather than a branch, so pipeline runs stay reproducible:

```bash
git submodule add https://github.com/EIT-GBI/nf-mod-fastp.git modules/fastp
git -C modules/fastp checkout v1.0.0
```

Then in your pipeline:

```groovy
include { FASTP_TRIM } from './modules/fastp/trim/main.nf'
```

## Requirements

Nextflow 26.04.4 or newer.

## Releasing

Merging a PR to `main` with exactly one `bump:patch`, `bump:minor` or
`bump:major` label bumps `manifest.version` in `nextflow.config`, tags the
release and publishes the container image.
