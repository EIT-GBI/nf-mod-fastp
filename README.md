# nf-mod-fastp

Nextflow module for fastp (paired-end read trimming and QC). Used as a git submodule by pipelines.

Image: `ghcr.io/eit-gbi/nf-mod-fastp:v0.0.0`

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

Flags are passed through `task.ext.args` rather than read from pipeline
`params`, so the module never depends on a particular pipeline's parameter
names:

```groovy
process {
    withName: FASTP_TRIM {
        ext.args = '-q 30 -l 100'
    }
}
```

## Use as submodule

Pin to a release tag rather than a branch, so pipeline runs stay reproducible:

```bash
git submodule add https://github.com/EIT-GBI/nf-mod-fastp.git modules/fastp
git -C modules/fastp checkout v0.0.0
```

Then include the module's container config from your `nextflow.config`. Nextflow
does not read a submodule's config on its own, so without this line the
processes have no image:

```groovy
includeConfig 'modules/fastp/conf/module.config'
```

`conf/module.config` pins the image to the version built from this same commit,
and carries no `manifest {}` block, so it will not overwrite your pipeline's
own manifest. Override it in your pipeline with a `withName` selector if needed.

And include the processes:

```groovy
include { FASTP_TRIM } from './modules/fastp/trim/main.nf'
```

## Requirements

Nextflow 26.04.4 or newer.

## Tests

`nf-test test`. There is a stub test covering wiring and output names, and tests
that run fastp for real against `ghcr.io/eit-gbi/nf-mod-fastp:latest` and
snapshot what comes out. The real tests need Docker, and `tests-args.config`
adds trimming flags through `ext.args`.

fastp writes no timestamp, so the trimmed FASTQs are stable and are snapshotted
directly. The JSON report is not snapshotted whole, because it carries
`fastp_version`, which moves whenever the image is rebuilt. Instead the tests
assert on its `command` field, which shows what reached the tool, and on
`filtering_result`, where `-l` shows up as `too_short_reads` and `-q` as
`low_quality_reads`.

## Releasing

Merging a PR to `main` with exactly one `bump:patch`, `bump:minor` or
`bump:major` label bumps `manifest.version` in `nextflow.config`, tags the
release and publishes the container image.
