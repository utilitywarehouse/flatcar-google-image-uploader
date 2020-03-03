#!/bin/bash
set -o errexit
set -o pipefail

BUCKET_NAME="${BUCKET_NAME:?"must be set"}"
CHANNEL="${CHANNEL:-"stable"}"
SLEEP_DURATION="${SLEEP_DURATION:-"3600"}"
GOOGLE_SA_KEY_FILE="${GOOGLE_SA_KEY_FILE:-"./credentials.json"}"

# configure auth with the provided service account key file
gcloud auth activate-service-account --key-file "${GOOGLE_SA_KEY_FILE}"

while true; do
  # retrieve the version number of the current release
  current_version=$(wget -O - "https://${CHANNEL}.release.flatcar-linux.net/amd64-usr/current/version.txt" 2> /dev/null \
    | grep "FLATCAR_VERSION=.*$" \
    | sed 's/.*=//g'
  )

  # validate the version number
  if [[ ! "${current_version}" =~ [0-9]{4}\.[0-9]+\.[0-9]+ ]]; then
    echo "error: unexpected version number format: ${current_version}" >&2
    exit 1
  fi

  # if an image doesn't already exist for this version, create it
  IMAGE_NAME=$(sed 's/\./-/g' <<<"flatcar-${CHANNEL}-${current_version}")
  if ! gcloud compute images describe -q "${IMAGE_NAME}" &>/dev/null; then
    IMAGE_FILENAME="flatcar_production_gce.tar.gz"
    BUCKET_OBJECT="gs://${BUCKET_NAME}/${CHANNEL}-${IMAGE_FILENAME}"

    echo "Downloading Flatcar Linux image for ${current_version}..."
    wget -O "${IMAGE_FILENAME}" \
      "https://${CHANNEL}.release.flatcar-linux.net/amd64-usr/${current_version}/${IMAGE_FILENAME}"

    echo "Uploading image to bucket..."
    gsutil -o GSUtil:parallel_composite_upload_threshold=150M cp "${IMAGE_FILENAME}" "${BUCKET_OBJECT}"
    rm "${IMAGE_FILENAME}"

    echo "Creating compute image..."
    gcloud compute images create "${IMAGE_NAME}" \
      --source-uri "${BUCKET_OBJECT}" \
      --family "flatcar-${CHANNEL}"

    old_images=$(gcloud compute images list \
      --format="value(NAME)" \
      --filter="name~'flatcar-${CHANNEL}-.*' AND name!='${IMAGE_NAME}'" \
      | xargs
    )
    if [[ -n "${old_images}" ]]; then
      echo "Cleaning up old compute images..."
      gcloud compute images delete $old_images
    fi

    echo "Done, ${current_version} uploaded."
  fi
  sleep "${SLEEP_DURATION}"
done
