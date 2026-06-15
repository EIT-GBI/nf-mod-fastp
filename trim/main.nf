// Adapter trimming

process TRIM {
    tag "$sample"
    cpus params.alignment.threads
    publishDir "${params.outdir}/trimmed", mode: 'link', pattern: '*.{html,json}'

    input:
    tuple val(sample), path(r1), path(r2)

    output:
    tuple val(sample), path("${sample}_R1.trimmed.fastq.gz"), path("${sample}_R2.trimmed.fastq.gz"), emit: reads
    path("${sample}.fastp.html"), emit: html
    path("${sample}.fastp.json"), emit: log

    script:
    def args = task.ext.args ?: ''
    """
    fastp \\
      ${args} \\
      -w ${task.cpus} \\
      -i ${r1} -I ${r2} \\
      -o ${sample}_R1.trimmed.fastq.gz -O ${sample}_R2.trimmed.fastq.gz \\
      -h ${sample}.fastp.html \\
      -j ${sample}.fastp.json
    """

    stub:
    """
    touch ${sample}_R1.trimmed.fastq.gz ${sample}_R2.trimmed.fastq.gz
    touch ${sample}.fastp.html ${sample}.fastp.json
    """
}
