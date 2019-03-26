# Test files creator
*Hosted at [GitLab](https://gitlab.com/matuzalemmuller/test-files-creator) and mirrored to [GitHub](https://github.com/matuzalemmuller/test-files-creator).*

## Description
Script to be used by [crontab](https://en.wikipedia.org/wiki/Cron) to create, delete and modify test files on a scheduled basis.

## Usage

### Script

```
./script.sh <folder> <file_size_KB> <files_created> <files_deleted> <files_modified> 
```

* `<folder>` is the path of where the test folder will be created and files will be saved. Default value is `$HOME/test`.
* `<file_size_KB>` is the size of the files that will be created, in KB. Default value is `50000` (which is 50MB).
* `<files_created>` is the number of files that will be created. Default value is `5`.
* `<files_deleted>` is the number of files that will be deleted. Default value is `1`.
* `<files_modified>` is the number of files that will be modified. Default value is `2`.


### Crontab

Check the [docs](https://linux.die.net/man/1/crontab) for instructions on how to use `crontab`. 

### Example of usage

Crontab file:
```
0 * * * * $HOME/scripts/script.sh $HOME/tests
```

Script from folder `$HOME/scripts/script.sh` will be run hourly and test files will be created at `$HOME/tests`.