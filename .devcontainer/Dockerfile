FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    git \
    curl \
  && rm -rf /var/lib/apt/lists/*

ENV Version=1.10.5

# // install terraform
RUN wget --quiet https://releases.hashicorp.com/terraform/${Version}/terraform_${Version}_linux_amd64.zip \
  && unzip terraform_${Version}_linux_amd64.zip \
  && mv terraform /usr/bin \
  && rm terraform_${Version}_linux_amd64.zip

# // install aws cli
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
  && unzip awscliv2.zip \
  && ./aws/install \
  && rm awscliv2.zip \
  && rm -rf ./aws

WORKDIR /app

COPY . /app
