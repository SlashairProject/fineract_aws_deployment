FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    git \
  && rm -rf /var/lib/apt/lists/*

ENV Version=1.10.5

RUN wget --quiet https://releases.hashicorp.com/terraform/${Version}/terraform_${Version}_linux_amd64.zip \
  && unzip terraform_${Version}_linux_amd64.zip \
  && mv terraform /usr/bin \
  && rm terraform_${Version}_linux_amd64.zip

WORKDIR /app

COPY . /app
