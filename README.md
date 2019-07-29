# <Site Name\> Build

## Get started

### Requirements

1. Docker
    * v18.06 and above
2. Pantheon
    * Create a Pantheon
    * Install terminus on your local machine:  https://github.com/pantheon-systems/terminus#installation
    * Create a machine token on Pantheon, and copy the token:  https://pantheon.io/docs/machine-tokens/
    * Use terminus to authenticate to Pantheon:  https://pantheon.io/docs/machine-tokens/#authenticate-into-terminus
    
      This will save your authentication credentials associated with your email address.
    
      NOTE: If you encounter a PHP Console Hightlighter conflict, revert to version 0.3 following the [readme](https://github.com/JakubOnderka/PHP-Console-Highlighter)
3. [Drush Launcher](https://github.com/drush-ops/drush-launcher). Follow the instructions there or try:
    * Run `which drush` to find the path of your drush installation
    * `curl -OL https://github.com/drush-ops/drush-launcher/releases/download/0.6.0/drush.phar`
    * `chmod +x drush.phar`
    * Move drush.phar to the location of your old drush executable and rename to drush with `mv drush.phar /path/to/executable/drush`
4. `pv` ([Pipe Viewer](http://www.ivarch.com/programs/pv.shtml))
5. Review this README and follow instructions for local development setup

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
```
