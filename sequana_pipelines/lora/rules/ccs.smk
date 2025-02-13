"""Parallelized Pacbio CCS"""
CCS_MAX_CHUNKS = config['ccs']['max-chunks']


checkpoint index_bam:
    input:
        get_raw_data
    output:
        directory("{sample}/pbindex")
    run:
        for i, file in enumerate(input):
            shell(
                "mkdir -p {output}"
                " && ln -sfn {file} {output}/{wildcards.sample}_{i}.bam"
                " && pbindex {output}/{wildcards.sample}_{i}.bam"
            )


# intermediate files are needed to parallelize ccs computation ( ͡° ͜ʖ ͡°)
rule setup_ccs_chunk:
    input:
        "{sample}/pbindex/{sample}_{flowcell}.bam"
    output:
        temp(expand("{{sample}}/ccs/{{sample}}_{{flowcell}}.{chunk}.txt", chunk=range(1, CCS_MAX_CHUNKS + 1)))
    shell:
        """
        touch {output}
        """


rule ccs:
    input:
        "{sample}/ccs/{sample}_{flowcell}.{chunk}.txt",
        bam = "{sample}/pbindex/{sample}_{flowcell}.bam"
    output:
        bam = temp("{sample}/ccs/{sample}_{flowcell}.ccs.{chunk}.bam"),
        pbi = temp("{sample}/ccs/{sample}_{flowcell}.ccs.{chunk}.bam.pbi"),
        report = "{sample}/ccs/{sample}_{flowcell}.{chunk}_report.txt"
    params:
        max_chunks = CCS_MAX_CHUNKS,
        min_rq = config['ccs']['min-rq'],
        min_passes = config['ccs']['min-passes'],
        options = config['ccs']['options']
    threads:
        config['ccs']['threads']
    resources:
        **config["ccs"]["resources"],
    shell:
        """
        ccs {input.bam} {output.bam} --chunk {wildcards.chunk}/{params.max_chunks} --min-rq {params.min_rq}\
            --min-passes {params.min_passes} --num-threads {threads} --report-file {output.report} {params.options}
        """


rule ccs_merge:
    input:
        expand("{{sample}}/ccs/{{sample}}_{{flowcell}}.ccs.{chunk}.bam", chunk=range(1, CCS_MAX_CHUNKS + 1))
    output:
        "{sample}/ccs/{sample}_{flowcell}.ccs.bam"
    params:
        config['samtools_merge']['options']
    threads:
        config['samtools_merge']['threads']
    shell:
        """
        samtools merge -@ $(({threads} - 1)) {params} {output} {input}
        """


rule flowcell_merge:
    input:
        aggregate_flowcell
    output:
        "{sample}/ccs/{sample}.ccs.bam"
    threads:
        config['samtools_merge']['threads']
    shell:
        """
        samtools merge -@ $(({threads} - 1)) {params} {output} {input}
        """


rule bam_to_fastq:
    input:
        get_bam
    output:
        fastq = "{sample}/bam_to_fastq/{sample}.fastq"
    params:
        config['bam_to_fastq']['options']
    threads:
        config['bam_to_fastq']['threads']
    resources:
        **config["canu"]["resources"],
    shell:
        """
        samtools bam2fq -@ $(({threads} - 1)) {params} {input} > {output.fastq}
        """
