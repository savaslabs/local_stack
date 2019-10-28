# <Site Name\> Build

## Get started

### Requirements

1. Docker
    * v18.06 and above
1. Pantheon
    * Create a Pantheon
    * Add an SSH Key to your Pantheon account. https://pantheon.io/docs/ssh-keys/
    * Install terminus on your local machine:  https://github.com/pantheon-systems/terminus#installation
    * Create a machine token on Pantheon, and copy the token:  https://pantheon.io/docs/machine-tokens/
    * Use terminus to authenticate to Pantheon:  https://pantheon.io/docs/machine-tokens/#authenticate-into-terminus
    
      This will save your authentication credentials associated with your email address.
    
      NOTE: If you encounter a PHP Console Hightlighter conflict, revert to version 0.3 following the [readme](https://github.com/JakubOnderka/PHP-Console-Highlighter)
1. [Terminus Rsync Plugin](https://github.com/pantheon-systems/terminus-rsync-plugin). Allows you to rsync
site files from Pantheon instead of fetching from a specific backup.
    * `mkdir -p ~/.terminus/plugins` (if the directory does not yet exist)
    * `composer create-project --no-dev -d ~/.terminus/plugins pantheon-systems/terminus-rsync-plugin:~1`
1. [Drush Launcher](https://github.com/drush-ops/drush-launcher). Follow the instructions there or try:
    * Run `which drush` to find the path of your drush installation
    * `curl -OL https://github.com/drush-ops/drush-launcher/releases/download/0.6.0/drush.phar`
    * `chmod +x drush.phar`
    * Move drush.phar to the location of your old drush executable and rename to drush with `mv drush.phar /path/to/executable/drush`
1. `pv` ([Pipe Viewer](http://www.ivarch.com/programs/pv.shtml))
1. Review this README and follow instructions for local development setup

### Site installation

Clone this project:
* `git clone git@github.com:savaslabs/<repo>.git` (GitHub repo)
* `cd <repo>`
* `make install` - build your development environment


## Local development

### Get Local web address:

Add `127.0.0.1 <site URL>` to your hosts file.

Go to [<site URL\>]()

### Make commands

Once local development is installed:

* `make install` to initially create the local environment and pull a seed database and assets.
* `make up` - to spin containers up
* `make down` - to spin them down

Refer to Makefile for available local development commands.

`make help` - to list all available commands.

### Run Drush commands

Remember that you need to install Drush Launcher before attempting these commands.

`make drush <command>`

See a list of most common Drush commands represented as Makefile targets below:

* `make cim` - import configuration
* `make cex` - export configuration
* `make updb` - run database updates
* `make entup` - run entity updates
* `make uli` - generate login link for user 1

### Drush aliases

`drush site:alias @self` will display a list of all available aliases.

### Run Composer commands

Please use composer commands defined within Makefile:

* `make compose-install`
* `make composer-update`

OR

run composer within the container `docker-compose exec -T php composer <command> -n --prefer-dist -v`

### Adding new contributed modules

Run `docker-compose exec -T php composer require drupal/<module_name> -n --prefer-dist -v`
to add it to the list of requirements in composer.json. Then, use drush to
enable the module by running `make drush en <module_name>`. Be sure to export
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

### Performance tuning

If the site is running slowly for you locally (i.e pages take more than a few seconds to load on average),
you may be able to improve performance by allocating additional OS resources to Docker. This is particularly relevant on Mac OS.
Specifically, we recommend the suggestions in Step 1 [of this article](https://markshust.com/2018/01/30/performance-tuning-docker-mac/):

> Once you have (at the very least) a quad-core MacBook Pro with 16GB RAM and an SSD, go to Docker > Preferences > Advanced. Set the “computing resources dedicated to Docker” to at least 4 CPUs and 8.0 GB RAM.

Alternatively, set your RAM usage to half of what your computer has available.

Also note that disabling caching or enabling Xdebug locally will both decrease performance.

For more information, see Redmine task [#9605](https://pm.savaslabs.com/issues/9605).

### Other

`make pull-db` - to pull latest seed database from the production environment

## Composer template for Drupal projects

This project is built using [Drupal Composer project](https://github.com/drupal-composer/drupal-project)  and [Acquia RA composer template](https://docs.acquia.com/ra/automation/composer/#template)

Docker containers for the project are configured using [Docker4Drupal](https://github.com/wodby/docker4drupal) - Docker-based Drupal stack.
If there's ever a need to add or modify containers, please refer to the project's documentation on GitHub.

## Working with Pantheon

### Deploying code

To deploy code to Pantheon environments, first create a new tag using
the Git Flow process. Push the tag to Pantheon and deploy it to whichever
environment you choose.

### Configuration management

To import configuration into Pantheon, use Terminus:

```
`terminus remote:drush <site>.<env> -- cim` 

# Composer template for Drupal projects

[![Build Status](https://travis-ci.org/drupal-composer/drupal-project.svg?branch=8.x)](https://travis-ci.org/drupal-composer/drupal-project)

This project template provides a starter kit for managing your site
dependencies with [Composer](https://getcomposer.org/).

If you want to know how to use it as replacement for
[Drush Make](https://github.com/drush-ops/drush/blob/8.x/docs/make.md) visit
the [Documentation on drupal.org](https://www.drupal.org/node/2471553).

## Usage

First you need to [install composer](https://getcomposer.org/doc/00-intro.md#installation-linux-unix-osx).

> Note: The instructions below refer to the [global composer installation](https://getcomposer.org/doc/00-intro.md#globally).
You might need to replace `composer` with `php composer.phar` (or similar) 
for your setup.

After that you can create the project:

```
composer create-project drupal-composer/drupal-project:8.x-dev some-dir --no-interaction
```

With `composer require ...` you can download new dependencies to your 
installation.

```
cd some-dir
composer require drupal/devel:~1.0
```

The `composer create-project` command passes ownership of all files to the 
project that is created. You should create a new git repository, and commit 
all files not excluded by the .gitignore file.

## What does the template do?

When installing the given `composer.json` some tasks are taken care of:

* Drupal will be installed in the `web`-directory.
* Autoloader is implemented to use the generated composer autoloader in `vendor/autoload.php`,
  instead of the one provided by Drupal (`web/vendor/autoload.php`).
* Modules (packages of type `drupal-module`) will be placed in `web/modules/contrib/`
* Theme (packages of type `drupal-theme`) will be placed in `web/themes/contrib/`
* Profiles (packages of type `drupal-profile`) will be placed in `web/profiles/contrib/`
* Creates default writable versions of `settings.php` and `services.yml`.
* Creates `web/sites/default/files`-directory.
* Latest version of drush is installed locally for use at `vendor/bin/drush`.
* Latest version of DrupalConsole is installed locally for use at `vendor/bin/drupal`.
* Creates environment variables based on your .env file. See [.env.example](.env.example).

## Updating Drupal Core

This project will attempt to keep all of your Drupal Core files up-to-date; the 
project [drupal-composer/drupal-scaffold](https://github.com/drupal-composer/drupal-scaffold) 
is used to ensure that your scaffold files are updated every time drupal/core is 
updated. If you customize any of the "scaffolding" files (commonly .htaccess), 
you may need to merge conflicts if any of your modified files are updated in a 
new release of Drupal core.

Follow the steps below to update your core files.

1. Run `composer update drupal/core webflo/drupal-core-require-dev "symfony/*" --with-dependencies` to update Drupal Core and its dependencies.
1. Run `git diff` to determine if any of the scaffolding files have changed. 
   Review the files for any changes and restore any customizations to 
  `.htaccess` or `robots.txt`.
1. Commit everything all together in a single commit, so `web` will remain in
   sync with the `core` when checking out branches or running `git bisect`.
1. In the event that there are non-trivial conflicts in step 2, you may wish 
   to perform these steps on a branch, and use `git merge` to combine the 
   updated core files with your customized files. This facilitates the use 
   of a [three-way merge tool such as kdiff3](http://www.gitshah.com/2010/12/how-to-setup-kdiff-as-diff-tool-for-git.html). This setup is not necessary if your changes are simple; 
   keeping all of your modifications at the beginning or end of the file is a 
   good strategy to keep merges easy.

## Generate composer.json from existing project

With using [the "Composer Generate" drush extension](https://www.drupal.org/project/composer_generate)
you can now generate a basic `composer.json` file from an existing project. Note
that the generated `composer.json` might differ from this project's file.


## FAQ

### Should I commit the contrib modules I download?

Composer recommends **no**. They provide [argumentation against but also 
workrounds if a project decides to do it anyway](https://getcomposer.org/doc/faqs/should-i-commit-the-dependencies-in-my-vendor-directory.md).

### Should I commit the scaffolding files?

The [drupal-scaffold](https://github.com/drupal-composer/drupal-scaffold) plugin can download the scaffold files (like
index.php, update.php, …) to the web/ directory of your project. If you have not customized those files you could choose
to not check them into your version control system (e.g. git). If that is the case for your project it might be
convenient to automatically run the drupal-scaffold plugin after every install or update of your project. You can
achieve that by registering `@composer drupal:scaffold` as post-install and post-update command in your composer.json:

```json
"scripts": {
    "post-install-cmd": [
        "@composer drupal:scaffold",
        "..."
    ],
    "post-update-cmd": [
        "@composer drupal:scaffold",
        "..."
    ]
},
```
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
