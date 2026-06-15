// Adapter trimming

process TRIM {
    tag "$meta.id"
    cpus params.alignment.threads
    publishDir "${params.outdir}/trimmed", mode: 'link', pattern: '*.{html,json}'

    input:
    tuple val(meta), path(r1), path(r2)

    output:
    tuple val(meta), path("${meta.id}_R1.trimmed.fastq.gz"), path("${meta.id}_R2.trimmed.fastq.gz"), emit: reads
    path("${meta.id}.fastp.html"), emit: html
    path("${meta.id}.fastp.json"), emit: log

    script:
    def args = task.ext.args ?: ''
    """
    fastp \\
      ${args} \\
      -w ${task.cpus} \\
      -i ${r1} -I ${r2} \\
      -o ${meta.id}_R1.trimmed.fastq.gz -O ${meta.id}_R2.trimmed.fastq.gz \\
      -h ${meta.id}.fastp.html \\
      -j ${meta.id}.fastp.json
    """

    stub:
    """
    touch ${meta.id}_R1.trimmed.fastq.gz ${meta.id}_R2.trimmed.fastq.gz
    touch ${meta.id}.fastp.html ${meta.id}.fastp.json
    """
}