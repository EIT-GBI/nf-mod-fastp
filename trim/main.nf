process TRIM {
    tag "$sample"
    cpus params.alignment.threads
    publishDir "${params.alignment.outdir}/trimmed", mode: 'link', pattern: '*.{html,json}'

    input:
    tuple val(sample), path(r1), path(r2)

    output:
    tuple val(sample),
          path("${sample}_R1.trimmed.fastq.gz"),
          path("${sample}_R2.trimmed.fastq.gz"),
          path("${sample}.fastp.html"),
          path("${sample}.fastp.json")

    script:
    """
    fastp -w ${task.cpus} -i ${r1} -I ${r2} \\
      -o ${sample}_R1.trimmed.fastq.gz -O ${sample}_R2.trimmed.fastq.gz \\
      -h ${sample}.fastp.html -j ${sample}.fastp.json
    """

    stub:
    """
    which fastp && fastp --version 2>&1 | head -1
    touch ${sample}_R1.trimmed.fastq.gz ${sample}_R2.trimmed.fastq.gz \\
          ${sample}.fastp.html ${sample}.fastp.json
    """
}
