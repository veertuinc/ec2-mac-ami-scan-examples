#!/usr/bin/env bash
set -exo pipefail
IFS=$'\n'

[[ -z "${1}" ]] && echo "you must include the AMI ID as ARG 1" && exit 1

export AMI_ID_AND_NAME="$(sudo aws ec2 describe-images --filters \
  "Name=image-id,Values=${1}" \
  "Name=owner-id,Values=930457884660" \
  --query "reverse(sort_by(Images, &CreationDate)[].[ImageId,Name])" --output text)"

[[ -z "${AMI_ID_AND_NAME}" ]] && echo "cannot find AMI in account" && exit 2

echo "${AMI_ID_AND_NAME}"
ID=$(echo "${AMI_ID_AND_NAME}" | xargs | cut -d" " -f1)
NAME=$(echo "${AMI_ID_AND_NAME}" | xargs | cut -d" " -f2)
sudo ec2-mac-ami-scan --config "${HOME}/config.yaml" --report-file "${NAME}-${ID}.scan.log" ${2} ${1}
