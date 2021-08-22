# Maintenance for Drupal ^8 || ^9

## Update Core / Install modules

To update core or install/delete modules use composer!

### Update Core and Modules

```bash
composer update
```

**--ignore-platform-reqs**  - use this flag only on Timeweb servers, or if the PHP version in the command line does not match the PHP version in the "Status Report"

```bash
composer update --ignore-platform-reqs
```

### Install modules

```bash
composer require drupal/module_name
```

# IQIS.SH v0.1

**iqis.sh** - contains instructions for creating a database dump and full file archive.
This file is already included in composer (see scripts section in "pre-update-cmd" part), although it can be executed separately.

If you want set custom project name fnd backup suffix create **iqis.conf** file and set variables PROJECT and BCKP_SUFFIX, example:

```bash
# iqis.conf
# * CUSTOM VARIABLES
PROJECT="devoutfofame"
BCKP_SUFFIX="backup"
DRUPAL_PATH="./"
SCRIPT_PATH="./"
```

If the script does not run, give execution permission to the file

```bash
chmod ugo+x iqis.sh
```

## USAGE IQIS.SH
```bash
iqis.sh [ -a ACTION (backup/restore/cleanup) ]
```
or

```bash
bash iqis.sh [ -a ACTION (backup/restore/cleanup) ]
```

## Author

* **Marat Farkhulin**
* **Site** [iQis.ru](https://iqis.ru/)
* **Email** [marat.farkhulin@gmail.com](mailto:marat.farkhulin@gmail.com)
