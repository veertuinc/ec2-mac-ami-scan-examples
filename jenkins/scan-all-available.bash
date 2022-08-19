#!/usr/bin/env bash
set -exo pipefail
IFS=$'\n'

[[ -z "${1}" ]] && echo "you must include the pattern to use when searching for AMI names as ARG 1" && exit 1

for AMI_ID_AND_NAME in $(sudo aws ec2 describe-images --filters \
  "Name=name,Values=${1}" \
  "Name=state,Values=available" \
  "Name=owner-id,Values=930457884660" \
  --query "reverse(sort_by(Images, &CreationDate)[].[ImageId,Name])" --output text)
do
  echo "${AMI_ID_AND_NAME}"
  ID=$(echo "${AMI_ID_AND_NAME}" | xargs | cut -d" " -f1)
  NAME=$(echo "${AMI_ID_AND_NAME}" | xargs | cut -d" " -f2)
  sudo ec2-mac-ami-scan --config "${HOME}/config.yaml" --report-file "${NAME}-${ID}.scan.log" ${2} ${ID}
done