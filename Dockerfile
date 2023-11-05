FROM golang:alpine3.10 as builder

RUN mkdir /app
COPY *.go /app/
WORKDIR /app
RUN go mod init main
RUN go get
RUN go build -o guide2go

FROM alpine:latest
RUN apk update
RUN apk upgrade

RUN apk add --no-cache ca-certificates

MAINTAINER nimarchetti nik@incorporation.co.uk

# Extras
RUN apk add --no-cache curl

# Add Bash shell & dependancies
RUN apk add --no-cache bash

# Volumes
VOLUME /guide2go
