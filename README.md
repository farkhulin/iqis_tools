# IQIS TOOLS

**iqis** - This utility is intended for Drupal 7,8(or higher) developers to simplify everyday tasks, such as creating / restoring file system and database backups, with the ability to configure folder exclusions and / or table exclusions in the database.

For DB dump operations used https://github.com/ifsnop/mysqldump-php library.

## REQUIREMENTS

- PHP >5.4
- MySQL
- BASH

## INSTALLATION

Connect via SSH to your server and run the command:

```bash

composer global require farkhulin/iqis_tools

```
Next run the commands:

```bash

chmod ugo+x  ~/.composer/vendor/farkhulin/iqis_tools/iqis.sh

~/.composer/vendor/farkhulin/iqis_tools/iqis.sh -a selfinit

```

After that, log out of the SSH for the changes to take effect, and log in again. Next, go to the directory with your project and run:

```bash

iqis

```

## CUSTOMISATION

If you want set custom project name and backup suffix create **_iqis.conf** file and set variables PROJECT and BCKP_SUFFIX, also you may set custom DRUPAL_PATH and SCRIPT_PATH, example:

```bash
# _iqis.conf

# * CUSTOM VARIABLES
PROJECT="your_project_name"
BCKP_SUFFIX="backup"
CUSTOM_BCKP_SUFFIX="custom_backup"

# use absolute path example DRUPAL_PATH="/var/www/home/your-site.com/web/"
DRUPAL_PATH="./"

# use absolute path example SCRIPT_PATH="/var/www/home/your-site.com/"
SCRIPT_PATH="./"
# * EXCLUDED PATHS AND FILES
EXCLUDED_PATHS=(
    /sites/default/files
)
# * EXCLUDED TABLES FROM DB
EXCLUDED_TABLES=(
    cache_form
)
```

## USAGE IQIS

### CLI

```bash
iqis action_name

Avalibale actions:

backup             - Create full backup files and DB.
custom-backup      - Create custom backup files and DB.
restore            - Restore full backup files and DB.
custom-restore     - Restore custom backup files and DB.
cleanup            - Removes old / unnecessary backups.
pi                 - Shows project information.
reset-admin        - Change root admin password to 'admin'.
cc                 - Clear all cache tables.
```

### If you using Composer

You may include in composer (scripts section in "pre-update-cmd" part), although it can be executed separately.

Example:

```json
    "scripts": {
        "pre-update-cmd": [
            "iqis backup",
        ]
    }
```
This will create full backup of your site (database and files) before composer will executed.

## AUTHOR

* **Marat Farkhulin**
* **Site** [iQis.ru](https://iqis.ru/)
* **Email** [marat.farkhulin@gmail.com](mailto:marat.farkhulin@gmail.com)
