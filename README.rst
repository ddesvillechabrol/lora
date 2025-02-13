This is is the **lora** pipeline from the `Sequana <https://sequana.readthedocs.org>`_ project

:Overview: Run assembler (Canu, flye, hifiasm) on a set of long read files
:Input: A set of BAM files from Pacbio sequencers, or FastQ files.
:Output: HTML reports with assemblies for each sample.
:Status: draft
:Citation: Cokelaer et al, (2017), ‘Sequana’: a Set of Snakemake NGS pipelines, Journal of Open Source Software, 2(16), 352, JOSS DOI doi:10.21105/joss.00352


Installation
~~~~~~~~~~~~

You must install Sequana first::

    pip install sequana --upgrade

Then, just install this package::

    pip install sequana_lora


Usage
~~~~~

::

    sequana_lora --help
    sequana_lora --input-directory DATAPATH 

This creates a directory with the pipeline and configuration file. You will then need 
to execute the pipeline::

    cd lora
    sh lora.sh  # for a local run

This launch a snakemake pipeline. If you are familiar with snakemake, you can 
retrieve the pipeline itself and its configuration files and then execute the pipeline yourself with specific parameters::

    snakemake -s lora.rules -c config.yaml --cores 4 --stats stats.txt

Or use `sequanix <https://sequana.readthedocs.io/en/master/sequanix.html>`_ interface.

Requirements
~~~~~~~~~~~~

This pipelines requires the following executable(s):

- canu
- hifiasm
- flye
- blastn
- busco
- bwa
- ccs
- circlator
- minimap2
- pbindex
- prokka
- samtools
- sequana


.. image:: https://raw.githubusercontent.com/sequana/lora/master/sequana_pipelines/lora/dag.png


Details
~~~~~~~~~

This pipeline runs **lora** in parallel on the input fastq files (paired or not). 
A brief sequana summary report is also produced. 

In practice, you may start from BAM files generated by Pacbio sequencers or
Fastq files, or CCS files. CCS files can be built by the pipeline. Then, an
assembler is used to build the draft assemblies (Canu, hifiasm, etc). From the
draft, circularisation may be applied to generate circularised genome (useful
for bacterial genomes). Finally, each contig is blasted and quality checks are
performed using Busco, quast, etc.


Rules and configuration details
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Here is the `latest documented configuration file <https://raw.githubusercontent.com/sequana/sequana_lora/master/sequana_pipelines/lora/config.yaml>`_
to be used with the pipeline. Each rule used in the pipeline may have a section in the configuration file. 

Changelog
~~~~~~~~~

========= ====================================================================
Version   Description
========= ====================================================================
0.1.0     **First release.**
========= ====================================================================


