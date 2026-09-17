// Adapter trimming

process FASTP_TRIM {
    tag "$meta.id"

    input:
    tuple val(meta), path(r1), path(r2)

    output:
    tuple val(meta), path("${meta.id}_R1.trimmed.fastq.gz"), path("${meta.id}_R2.trimmed.fastq.gz"), emit: reads
    path("${meta.id}.fastp.html"), emit: html
    path("${meta.id}.fastp.json"), emit: log

    script:
    // Trimming thresholds belong to the module rather than the consuming
    // pipeline: every pipeline sets the same params.trimming.* names and the
    // fastp flags are assembled here, once. Unset means fastp's own default.
    def qual_opt = params.trimming?.min_base_quality != null ? "-q ${params.trimming.min_base_quality}" : ''
    def len_opt  = params.trimming?.min_read_length  != null ? "-l ${params.trimming.min_read_length}"  : ''
    def args = task.ext.args ?: ''
    """
    fastp \\
      ${qual_opt} \\
      ${len_opt} \\
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