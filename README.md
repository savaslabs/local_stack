# <site name> Build

## Set up

### Base theme

Follow the instructions in the base theme (`web/themes/custom/*`) README.

### Docksal

In the `.docksal/docksal.env` file:
1. Replace `<stack>` with a supported Docksal stack or remove the `DOCKSAL_STACK` line for a custom configuration. Docksal ships with a set of default configurations (stacks), which are yml files stored in `$HOME/.docksal/stacks/`. See [https://docs.docksal.io/stack/zero-configuration/]() for more information.
    1. Acquia hosted sites: `acquia`
    1. Pantheon hosted sites: `pantheon`
    1. Sites hosted elsewhere: `default` or custom configuration in the `.docksal/docksal.yml` file. See [https://docs.docksal.io/stack/custom-configuration/]() for more information.
1. Replace `<hosting platform>` with
1. Replace `<hosting site name>` with
1. Replace `<hosting environment>` with
1. Replace `<virtual host>` with the desired virtual hostname.
1. Replace `<theme>` with the machine name of the theme created in step 1.

### Project README

In the `README.md` file:
1. Replace `<site name>` with the name of the site.
1. Replace `<repo>` with the GitHub repository name.
1. Replace `<virtual host>` with the desired virtual hostname.

### Finished

Delete the `Set up` section of the README.

## Getting started

### Requirements

1. Docksal
    * Install Docksal: ([Linux](https://docs.docksal.io/getting-started/setup/#install-linux)) ([Mac](https://docs.docksal.io/getting-started/setup/#install-macos-docker-for-mac))
1. Pantheon
    * Create a Pantheon account.
    * Add an SSH Key to your Pantheon account: https://pantheon.io/docs/ssh-keys/
    * Create a machine token on Pantheon: https://pantheon.io/docs/machine-tokens/
      * Make sure you copy down your machine token once it is displayed. You will need this later, and it will not be displayed again.
1. Review this README and follow instructions for local development setup.

### Site installation

* Clone this project: `git clone git@github.com:savaslabs/<repo>.git` ([GitHub repo](https://github.com/savaslabs/<repo>))
* `cd <repo>`
* Create a new file called `docksal-local.env` in the `.docksal` directory of the project.
* Add the following contents, replacing `my-machine-token` with the machine token you created:
  ````
  SECRET_TERMINUS_TOKEN="my-machine-token"
  ````
* `fin init` - build your local development environment

### Troubleshooting

If you had any issues with the site installation, see the common errors below:
> ERROR: for cli  Cannot start service cli: OCI runtime create failed: container_linux.go:346: starting container process caused "process_linux.go:449: container init caused \"rootfs_linux.go:58: mounting \\\"/var/lib/docker/volumes/project_root/_data\\\" to rootfs \\\"/var/lib/docker/overlay2/c611dc00713e30ede5999960959d21583ecc7f3a7736e29a12ce30922e753a76/merged\\\" at \\\"/var/www\\\" caused \\\"stat /var/lib/docker/volumes/project_root/_data: stale NFS file handle\\\"\"": unknown
ERROR: Encountered errors while bringing up the project.

Go to `System Preferences > Security & Privacy > Privacy > Full Disk Access`, click on the plus sign and press `Command-Shift-G` to search for and then add the `/sbin/nfsd` folder.

## Local development

### Get Local web address:

Go to [http://<virtual host>.docksal/]()

### Docksal commands

`fin help` - to list all available commands.

Initialize or reset your environment:
* `fin init` to initially create the local environment and pull a seed database and assets
  * Optional parameters
    * `--skip-files` or `-sf` - skip syncing the files directory
    * `--skip-theme` or `-st` - skip installing npm dependencies and building the theme files

`fin init` works without any parameters. By default, it will sync the files directory and build the theme files. To skip one or both see the examples below:
* `fin init -sf` - initialize, but skip syncing the files directory
* `fin init -sf -st` - initialize, but skip syncing the files directory and building the theme files


Standard commands:
* `fin pull db` - to pull latest database from Pantheon
* `fin pull files` - to rsync the files from Pantheon
* `fin start` or `fin up` - to bring the environment up
* `fin stop` - to bring the environment down
* `fin system stop` - to stop and shutdown Docksal

Custom site-specific commands:
* `fin npm-install` - install npm dependencies for the custom theme
* `fin build-theme` - build CSS and JS bundle files for production
* `fin watch-theme` - hot-reload CSS and JS bundle files for development
* `fin phpcs` - PHP Code Sniffer

### Run Drush commands

Remember that you need to install Drush Launcher before attempting these commands.

`fin drush <command>`

See a list of most common Drush commands below:

* `fin drush cr` - clear cache
* `fin drush cim` - import configuration
* `fin drush cex` - export configuration
* `fin drush updb` - run database updates
* `fin drush uli` - generate login link for user 1

### Run Composer commands

Please use composer commands defined within Makefile:

Run composer within the container `fin composer <command>`

Examples below:

* `fin composer install`
* `fin composer update`

### Adding new contributed modules

Run `fin composer require drupal/<module_name> -n --prefer-dist -v`
to add it to the list of requirements in composer.json. Then, use drush to
enable the module by running `fin drush en <module_name>`. Be sure to export
the site configuration and commit that as well.

### Patching contributed module

If you need to apply patches (depending on the project being modified, a pull
request is often a better solution), you can do so with the
[composer-patches](https://github.com/cweagans/composer-patches) plugin.

To add a patch to drupal module foobar insert the patches section in the extra
section of composer.json:
```json
"extra": {
    "patches": {
        "drupal/foobar": {
            "Patch description": "URL or local path to patch"
        }
    }
}
```

### Access to MySQL

The Docksal environment is configured to expose MySQL on port 33306 of the host machine. It can be accessed with the following command:

mysql -u root -proot default -h 127.0.0.1 -P 33306

### Performance tuning

If the site is running slowly for you locally (i.e pages take more than a few seconds to load on average),
you may be able to improve performance by allocating additional OS resources to Docker. This is particularly relevant on Mac OS.
Specifically, we recommend the suggestions in Step 1 [of this article](https://markshust.com/2018/01/30/performance-tuning-docker-mac/):

> Once you have (at the very least) a quad-core MacBook Pro with 16GB RAM and an SSD, go to Docker > Preferences > Advanced. Set the “computing resources dedicated to Docker” to at least 4 CPUs and 8.0 GB RAM.

Alternatively, set your RAM usage to half of what your computer has available.

Also note that disabling caching or enabling Xdebug locally will both decrease performance.

For more information, see Redmine task [#9605](https://pm.savaslabs.com/issues/9605).

## FAQ

### I forgot my SSH key passphrase, what should I do?

Refer to the [Recovering your SSH key passphrase](https://help.github.com/en/github/authenticating-to-github/recovering-your-ssh-key-passphrase) guide from Github.

### Should I commit the contrib modules I download?

Composer recommends **no**. They provide [argumentation against but also
workrounds if a project decides to do it anyway](https://getcomposer.org/doc/faqs/should-i-commit-the-dependencies-in-my-vendor-directory.md).

### How can I apply patches to downloaded modules?

If you need to apply patches (depending on the project being modified, a pull
request is often a better solution), you can do so with the
[composer-patches](https://github.com/cweagans/composer-patches) plugin.

To add a patch to drupal module foobar insert the patches section in the extra
section of composer.json:
```json
"extra": {
    "patches": {
        "drupal/foobar": {
            "Patch description": "URL or local path to patch"
        }
    }
}
```

### How do I switch from packagist.drupal-composer.org to packages.drupal.org?

Follow the instructions in the [documentation on drupal.org](https://www.drupal.org/docs/develop/using-composer/using-packagesdrupalorg).

### How do I specify a PHP version ?

This project supports PHP 5.6 as minimum version (see [Drupal 8 PHP requirements](https://www.drupal.org/docs/8/system-requirements/drupal-8-php-requirements)), however it's possible that a `composer update` will upgrade some package that will then require PHP 7+.

To prevent this you can add this code to specify the PHP version you want to use in the `config` section of `composer.json`:
```json
"config": {
    "sort-packages": true,
    "platform": {
        "php": "5.6.40"
    }
},
```
