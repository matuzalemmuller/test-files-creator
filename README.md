# Test files creator

## Description
Script to be used by [crontab](https://en.wikipedia.org/wiki/Cron) to create, delete and modify test files on a scheduled basis. Script will create `x` files, delete 1 file and modify 1 file per run.

## Usage

### Script

```
./script.sh <folder> <number_of_files> <file_size_KB>
```

* `<folder>` is the path of where the test folder will be created and files will be saved.
* `<number_of_files>` is the number of files that will be created.
* `<file_size_KB>` is the size of the files that will be created, in KB.

If no arguments are given, the test folder will be created at `$HOME/test` and two files of 50MB will be created per run.

### Crontab

Check the [docs](https://linux.die.net/man/1/crontab) for instructions on how to use `crontab`. 

### Example of usage

Crontab file:
```
0 * * * * $HOME/scripts/script.sh $HOME/tests
```

Script from folder `$HOME/scripts/script.sh` will be run hourly and test files will be created at `$HOME/tests`.