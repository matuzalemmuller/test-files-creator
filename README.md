# Test files creator

## Description

Creates files with random content using common bash expressions and tools. The size of the files is specified in **bytes**.

### Parameters

- [`REQUIRED`] -o, --output: folder where files will be saved
- [`REQUIRED`] -s, --size: size of the files to be created
- [`REQUIRED`] -c, --create: number of files to create
- [`OPTIONAL`] -l, --log: log file
- [`OPTIONAL`] --csv: log file output in csv format
- [`OPTIONAL`] --md5: includes md5 hash in log file. Only works is csv logging is enabled
- [`OPTIONAL`] --sha256: includes sha256 hash in log file. Only works if csv logging is enabled

### Example

Create 10 files in the folder 'test-folder', with 1 MB of size each.

```sh
./create.sh -o=test-folder -s=1024 -c=10
```
