FROM debian:bullseye
RUN apt-get update && apt-get install -y wget default-jre procps
RUN wget https://github.com/nf-core/ampliseq/archive/refs/tags/2.2.0.tar.gz
RUN tar -xvf 2.2.0.tar.gz
RUN wget -qO- https://get.nextflow.io | bash
        