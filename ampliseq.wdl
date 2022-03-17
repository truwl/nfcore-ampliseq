version 1.0

workflow ampliseq {
	input{
		File samplesheet
		String FW_primer
		String RV_primer
		String? metadata
		Boolean? pacbio
		Boolean? iontorrent
		Boolean? single_end
		Boolean? cut_its
		Boolean? multiple_sequencing_runs
		Boolean? illumina_pe_its
		Boolean? concatenate_reads
		String sample_inference = "independent"
		String? metadata_category
		String? qiime_adonis_formula
		String extension = "/*_R{1,2}_001.fastq.gz"
		Boolean? picrust
		Boolean? sbdiexport
		String outdir = "./results"
		String? email
		Boolean? retain_untrimmed
		Boolean? double_primer
		Int? trunclenf
		Int? trunclenr
		Int trunc_qmin = 25
		Float trunc_rmin = 0.75
		Int max_ee = 2
		Int? max_len
		Int min_len = 50
		Int dada_tax_agglom_min = 2
		Int dada_tax_agglom_max = 7
		Int qiime_tax_agglom_min = 2
		Int qiime_tax_agglom_max = 6
		String dada_ref_taxonomy = "silva=138"
		Boolean? cut_dada_ref_taxonomy
		String? qiime_ref_taxonomy
		String? classifier
		Boolean? ignore_empty_input_files
		Boolean? ignore_failed_trimming
		String exclude_taxa = "mitochondria,chloroplast"
		Int min_frequency = 1
		Int min_samples = 1
		Boolean? skip_fastqc
		Boolean? skip_qiime
		Boolean? skip_taxonomy
		Boolean? skip_dada_addspecies
		Boolean? skip_barplot
		Boolean? skip_abundance_tables
		Boolean? skip_alpha_rarefaction
		Boolean? skip_diversity_indices
		Boolean? skip_ancom
		Boolean? skip_multiqc
		String custom_config_version = "master"
		String custom_config_base = "https://raw.githubusercontent.com/nf-core/configs/master"
		String? config_profile_name
		String? config_profile_description
		String? config_profile_contact
		String? config_profile_url
		String? multiqc_title
		Boolean? help
		String? email_on_fail
		Boolean? plaintext_email
		String max_multiqc_email_size = "25.MB"
		Boolean? monochrome_logs
		String? multiqc_config
		String tracedir = "./results/pipeline_info"
		Boolean validate_params = true
		Boolean? show_hidden_params
		Boolean? enable_conda
		Int max_cpus = 16
		String max_memory = "128.GB"
		String max_time = "240.h"

	}

	call make_uuid as mkuuid {}
	call touch_uuid as thuuid {
		input:
			outputbucket = mkuuid.uuid
	}
	call run_nfcoretask as nfcoretask {
		input:
			samplesheet = samplesheet,
			FW_primer = FW_primer,
			RV_primer = RV_primer,
			metadata = metadata,
			pacbio = pacbio,
			iontorrent = iontorrent,
			single_end = single_end,
			cut_its = cut_its,
			multiple_sequencing_runs = multiple_sequencing_runs,
			illumina_pe_its = illumina_pe_its,
			concatenate_reads = concatenate_reads,
			sample_inference = sample_inference,
			metadata_category = metadata_category,
			qiime_adonis_formula = qiime_adonis_formula,
			extension = extension,
			picrust = picrust,
			sbdiexport = sbdiexport,
			outdir = outdir,
			email = email,
			retain_untrimmed = retain_untrimmed,
			double_primer = double_primer,
			trunclenf = trunclenf,
			trunclenr = trunclenr,
			trunc_qmin = trunc_qmin,
			trunc_rmin = trunc_rmin,
			max_ee = max_ee,
			max_len = max_len,
			min_len = min_len,
			dada_tax_agglom_min = dada_tax_agglom_min,
			dada_tax_agglom_max = dada_tax_agglom_max,
			qiime_tax_agglom_min = qiime_tax_agglom_min,
			qiime_tax_agglom_max = qiime_tax_agglom_max,
			dada_ref_taxonomy = dada_ref_taxonomy,
			cut_dada_ref_taxonomy = cut_dada_ref_taxonomy,
			qiime_ref_taxonomy = qiime_ref_taxonomy,
			classifier = classifier,
			ignore_empty_input_files = ignore_empty_input_files,
			ignore_failed_trimming = ignore_failed_trimming,
			exclude_taxa = exclude_taxa,
			min_frequency = min_frequency,
			min_samples = min_samples,
			skip_fastqc = skip_fastqc,
			skip_qiime = skip_qiime,
			skip_taxonomy = skip_taxonomy,
			skip_dada_addspecies = skip_dada_addspecies,
			skip_barplot = skip_barplot,
			skip_abundance_tables = skip_abundance_tables,
			skip_alpha_rarefaction = skip_alpha_rarefaction,
			skip_diversity_indices = skip_diversity_indices,
			skip_ancom = skip_ancom,
			skip_multiqc = skip_multiqc,
			custom_config_version = custom_config_version,
			custom_config_base = custom_config_base,
			config_profile_name = config_profile_name,
			config_profile_description = config_profile_description,
			config_profile_contact = config_profile_contact,
			config_profile_url = config_profile_url,
			multiqc_title = multiqc_title,
			help = help,
			email_on_fail = email_on_fail,
			plaintext_email = plaintext_email,
			max_multiqc_email_size = max_multiqc_email_size,
			monochrome_logs = monochrome_logs,
			multiqc_config = multiqc_config,
			tracedir = tracedir,
			validate_params = validate_params,
			show_hidden_params = show_hidden_params,
			enable_conda = enable_conda,
			max_cpus = max_cpus,
			max_memory = max_memory,
			max_time = max_time,
			outputbucket = thuuid.touchedbucket
            }
		output {
			Array[File] results = nfcoretask.results
		}
	}
task make_uuid {
	meta {
		volatile: true
}

command <<<
        python <<CODE
        import uuid
        print("gs://truwl-internal-inputs/nf-ampliseq/{}".format(str(uuid.uuid4())))
        CODE
>>>

  output {
    String uuid = read_string(stdout())
  }
  
  runtime {
    docker: "python:3.8.12-buster"
  }
}

task touch_uuid {
    input {
        String outputbucket
    }

    command <<<
        echo "sentinel" > sentinelfile
        gsutil cp sentinelfile ~{outputbucket}/sentinelfile
    >>>

    output {
        String touchedbucket = outputbucket
    }

    runtime {
        docker: "google/cloud-sdk:latest"
    }
}

task fetch_results {
    input {
        String outputbucket
        File execution_trace
    }
    command <<<
        cat ~{execution_trace}
        echo ~{outputbucket}
        mkdir -p ./resultsdir
        gsutil cp -R ~{outputbucket} ./resultsdir
    >>>
    output {
        Array[File] results = glob("resultsdir/*")
    }
    runtime {
        docker: "google/cloud-sdk:latest"
    }
}

task run_nfcoretask {
    input {
        String outputbucket
		File samplesheet
		String FW_primer
		String RV_primer
		String? metadata
		Boolean? pacbio
		Boolean? iontorrent
		Boolean? single_end
		Boolean? cut_its
		Boolean? multiple_sequencing_runs
		Boolean? illumina_pe_its
		Boolean? concatenate_reads
		String sample_inference = "independent"
		String? metadata_category
		String? qiime_adonis_formula
		String extension = "/*_R{1,2}_001.fastq.gz"
		Boolean? picrust
		Boolean? sbdiexport
		String outdir = "./results"
		String? email
		Boolean? retain_untrimmed
		Boolean? double_primer
		Int? trunclenf
		Int? trunclenr
		Int trunc_qmin = 25
		Float trunc_rmin = 0.75
		Int max_ee = 2
		Int? max_len
		Int min_len = 50
		Int dada_tax_agglom_min = 2
		Int dada_tax_agglom_max = 7
		Int qiime_tax_agglom_min = 2
		Int qiime_tax_agglom_max = 6
		String dada_ref_taxonomy = "silva=138"
		Boolean? cut_dada_ref_taxonomy
		String? qiime_ref_taxonomy
		String? classifier
		Boolean? ignore_empty_input_files
		Boolean? ignore_failed_trimming
		String exclude_taxa = "mitochondria,chloroplast"
		Int min_frequency = 1
		Int min_samples = 1
		Boolean? skip_fastqc
		Boolean? skip_qiime
		Boolean? skip_taxonomy
		Boolean? skip_dada_addspecies
		Boolean? skip_barplot
		Boolean? skip_abundance_tables
		Boolean? skip_alpha_rarefaction
		Boolean? skip_diversity_indices
		Boolean? skip_ancom
		Boolean? skip_multiqc
		String custom_config_version = "master"
		String custom_config_base = "https://raw.githubusercontent.com/nf-core/configs/master"
		String? config_profile_name
		String? config_profile_description
		String? config_profile_contact
		String? config_profile_url
		String? multiqc_title
		Boolean? help
		String? email_on_fail
		Boolean? plaintext_email
		String max_multiqc_email_size = "25.MB"
		Boolean? monochrome_logs
		String? multiqc_config
		String tracedir = "./results/pipeline_info"
		Boolean validate_params = true
		Boolean? show_hidden_params
		Boolean? enable_conda
		Int max_cpus = 16
		String max_memory = "128.GB"
		String max_time = "240.h"

	}
	command <<<
		export NXF_VER=21.10.5
		export NXF_MODE=google
		echo ~{outputbucket}
		/nextflow -c /truwl.nf.config run /ampliseq-2.2.0  -profile truwl  --input ~{samplesheet} 	~{"--samplesheet " + samplesheet}	~{"--FW_primer " + FW_primer}	~{"--RV_primer " + RV_primer}	~{"--metadata " + metadata}	~{true="--pacbio  " false="" pacbio}	~{true="--iontorrent  " false="" iontorrent}	~{true="--single_end  " false="" single_end}	~{true="--cut_its  " false="" cut_its}	~{true="--multiple_sequencing_runs  " false="" multiple_sequencing_runs}	~{true="--illumina_pe_its  " false="" illumina_pe_its}	~{true="--concatenate_reads  " false="" concatenate_reads}	~{"--sample_inference " + sample_inference}	~{"--metadata_category " + metadata_category}	~{"--qiime_adonis_formula " + qiime_adonis_formula}	~{"--extension " + extension}	~{true="--picrust  " false="" picrust}	~{true="--sbdiexport  " false="" sbdiexport}	~{"--outdir " + outdir}	~{"--email " + email}	~{true="--retain_untrimmed  " false="" retain_untrimmed}	~{true="--double_primer  " false="" double_primer}	~{"--trunclenf " + trunclenf}	~{"--trunclenr " + trunclenr}	~{"--trunc_qmin " + trunc_qmin}	~{"--trunc_rmin " + trunc_rmin}	~{"--max_ee " + max_ee}	~{"--max_len " + max_len}	~{"--min_len " + min_len}	~{"--dada_tax_agglom_min " + dada_tax_agglom_min}	~{"--dada_tax_agglom_max " + dada_tax_agglom_max}	~{"--qiime_tax_agglom_min " + qiime_tax_agglom_min}	~{"--qiime_tax_agglom_max " + qiime_tax_agglom_max}	~{"--dada_ref_taxonomy " + dada_ref_taxonomy}	~{true="--cut_dada_ref_taxonomy  " false="" cut_dada_ref_taxonomy}	~{"--qiime_ref_taxonomy " + qiime_ref_taxonomy}	~{"--classifier " + classifier}	~{true="--ignore_empty_input_files  " false="" ignore_empty_input_files}	~{true="--ignore_failed_trimming  " false="" ignore_failed_trimming}	~{"--exclude_taxa " + exclude_taxa}	~{"--min_frequency " + min_frequency}	~{"--min_samples " + min_samples}	~{true="--skip_fastqc  " false="" skip_fastqc}	~{true="--skip_qiime  " false="" skip_qiime}	~{true="--skip_taxonomy  " false="" skip_taxonomy}	~{true="--skip_dada_addspecies  " false="" skip_dada_addspecies}	~{true="--skip_barplot  " false="" skip_barplot}	~{true="--skip_abundance_tables  " false="" skip_abundance_tables}	~{true="--skip_alpha_rarefaction  " false="" skip_alpha_rarefaction}	~{true="--skip_diversity_indices  " false="" skip_diversity_indices}	~{true="--skip_ancom  " false="" skip_ancom}	~{true="--skip_multiqc  " false="" skip_multiqc}	~{"--custom_config_version " + custom_config_version}	~{"--custom_config_base " + custom_config_base}	~{"--config_profile_name " + config_profile_name}	~{"--config_profile_description " + config_profile_description}	~{"--config_profile_contact " + config_profile_contact}	~{"--config_profile_url " + config_profile_url}	~{"--multiqc_title " + multiqc_title}	~{true="--help  " false="" help}	~{"--email_on_fail " + email_on_fail}	~{true="--plaintext_email  " false="" plaintext_email}	~{"--max_multiqc_email_size " + max_multiqc_email_size}	~{true="--monochrome_logs  " false="" monochrome_logs}	~{"--multiqc_config " + multiqc_config}	~{"--tracedir " + tracedir}	~{true="--validate_params  " false="" validate_params}	~{true="--show_hidden_params  " false="" show_hidden_params}	~{true="--enable_conda  " false="" enable_conda}	~{"--max_cpus " + max_cpus}	~{"--max_memory " + max_memory}	~{"--max_time " + max_time}	-w ~{outputbucket}
	>>>
        
    output {
        File execution_trace = "pipeline_execution_trace.txt"
        Array[File] results = glob("results/*/*html")
    }
    runtime {
        docker: "truwl/nfcore-ampliseq:2.2.0_0.1.0"
        memory: "2 GB"
        cpu: 1
    }
}
    