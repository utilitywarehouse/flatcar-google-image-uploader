# flatcar-google-image-uploader

This service periodically checks for new releases of [Flatcar Container Linux](https://www.flatcar-linux.org/) and
uploads new images to GCE.

## Requirements

- A google storage bucket
- A service account with at least the following permissions for the bucket:

  - `storage.objects.create`
  - `storage.objects.update`
  - `storage.objects.list`

  and for compute images:

  - `compute.globalOperations.get`
  - `compute.images.get`
  - `compute.images.create`
  - `compute.images.list`
  - `compute.images.delete`

## Configuration

The uploader can be configured via environment variables.

### Required

- `BUCKET_NAME` - the name of the google cloud storage bucket

### Optional

- `CHANNEL` - the release channel. Choose from `stable`, `beta`, `alpha` or
  `edge`. The default is `stable`.
- `SLEEP_DURATION` - the period of time, in seconds, to wait between each check
  for a new version. The default is `3600`.
- `GOOGLE_SA_KEY_FILE` - the path on disk of the file containing the service account
  credentials. The default is `./credentials.json`.

## Kustomize

Included is a Kustomize base for running the uploader in Kubernetes:

```
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
bases:
  - github.com/utilitywarehouse/flatcar-google-image-uploader//manifests/base?ref=master
```

and an [example patch](manifests/example).
