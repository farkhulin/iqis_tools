# IQIS

**iqis** - contains instructions for creating a database dump and full files archive.

## If you using Composer
You may include in composer (scripts section in "pre-update-cmd" part), although it can be executed separately.

Example:

```json
    "scripts": {
        "pre-update-cmd": [
            "iqis -a backup",
        ]
    }
```
This will create full backup of your site (database and files) before composer will executed.

If you want set custom project name and backup suffix create **iqis.conf** file and set variables PROJECT and BCKP_SUFFIX, also you may set custom DRUPAL_PATH and SCRIPT_PATH, example:

```bash
# iqis.conf
# * CUSTOM VARIABLES
PROJECT="devoutfofame"
BCKP_SUFFIX="backup"
DRUPAL_PATH="./"
SCRIPT_PATH="./"
```

## USAGE IQIS

```bash
iqis [ -a ACTION (backup/restore/cleanup) ]
```

## Author

* **Marat Farkhulin**
* **Site** [iQis.ru](https://iqis.ru/)
* **Email** [marat.farkhulin@gmail.com](mailto:marat.farkhulin@gmail.com)
