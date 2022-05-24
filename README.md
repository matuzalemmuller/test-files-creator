# Test files creator

## Description

Creates files with random content using common bash expressions and tools. The size of the files is specified in **bytes**.

### Parameters

- [`REQUIRED`] -o, --output: folder where files will be saved;
- [`REQUIRED`] -s, --size: size of the files to be created;
- [`REQUIRED`] -n, --n_files: number of files to create;
- [`OPTIONAL`] -v, --verbose: prints verbose output. Affects performance;
- [`OPTIONAL`] -p, --progress: shows progress bar. Affects performance;
- [`OPTIONAL`] -l, --log: saves a log file in the location provided. Affects performance;
- [`OPTIONAL`] -csv, --csv: saves log file in csv format;
- [`OPTIONAL`] -h, --hash: includes hash in log file when `--csv` is enabled. Supported values: `md5` and `sha256`;
- [`OPTIONAL`] --help: prints help.

### Example

Create 5 files in the folder `/tmp`, with 1 MB of size each.

```sh
./test-files-creator.sh -o=/tmp -s=1024 -n=5 -l=/tmp/log.csv -csv -h=md5 -p
```

---

## Dockerfile

An alpine-based docker image is available with the script. To run the container, mount the path where files will be created in `/data` and provide the necessary environment variables. To save the logs, also mount a folder to `/log`.

```sh
docker run \
  --mount type=bind,src=/tmp,dst=/log \
  --mount type=bind,src=/tmp,dst=/data \
  -e "size=1000" \
  -e "n_files=10" \
  -e "csv=true" \
  -e "hash=sha256" \
  -e "progressbar=true" \
  -e "verbose=true" \
  matuzalemmuller/test-files-creator:latest
```

### Supported environment variables

| Key         | Description     |
|--------------|-----------|
| `size`    | Size of the files to be created (in **bytes**) |
| `n_files` | Number of files to be created |
| `csv` | `true` saves the log output in csv |
| `hash`    | Includes hash in log file when `csv` is enabled. Supported values: `md5` and `sha256` |
| `verbose` | `true` enables verbose output |
| `progressbar` | `true` enables the progress bar |
