# Test files creator

## Description

Creates files with random content using common bash expressions and tools. The size of the files is specified in **bytes**.

### Parameters

- [`REQUIRED`] -o, --output: folder where files will be saved;
- [`REQUIRED`] -s, --size: size of the files to be created;
- [`REQUIRED`] -n, --n_files: number of files to create;
- [`OPTIONAL`] -v, --verbose: prints verbose output;
- [`OPTIONAL`] -p, --progress: shows progress bar;
- [`OPTIONAL`] -l, --log: log file location;
- [`OPTIONAL`] -csv, --csv: log file output in csv format;
- [`OPTIONAL`] -h, --hash: includes hash in log file in csv format. Supported values: md5 and sha256;
- [`OPTIONAL`] --help: prints help.

### Example

Create 5 files in the folder 'test-folder', with 1 MB of size each.

```sh
./test-files-creator.sh -o=/tmp -s=1024 -c=5 -l=/tmp/log.csv -csv -h=md5 -p
```

---

## Dockerfile

An alpine-based docker image is available for using the script. To run the container, mount the path where files will be created in `/data` and the path for the log file (if necessary) in `/log`.

```sh
docker run \
  -e "size=1000" \
  -e "n_files=1" \
  -e "hash=sha256" \
  --mount type=bind,src=/src_data,dst=/data \
  --mount type=bind,src=/src_log,dst=/log \
  matuzalemmuller/test-files-creator:latest
```

### Supported environment varibles

| Key         | Description     |
|--------------|-----------|
| `size`    | Size of files to be created (in **bytes**) |
| `n_files` | Number of files to be created |
| `hash`    | Includes hash in the log file in csv format. Logs are not generated if `hash` is not present. |
