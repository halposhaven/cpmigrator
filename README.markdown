# cpMigrator: An automated migration script for cPanel migrations #

_Info: This script is currently under development, so it is not quite ready for prime time. Updates will be made here as it progresses._

## How to install

If you have git, then this can be accomplished using:

 git clone git@github.com:jerius/cpmigrator.git

_Info: As of right now, for testing, this should be put on the source server, or server you are using to test with. Right now it can only migrate from the source server to the destination server. Soon this will be placed in a tar ball that can be downloaded._

If you don't have git, the install can be grabbed from:

http://git-scm.com/

## How to run

### Full Migration

_Info: This is the only one finished at this point. The other migration types will be finished as soon as possible.

 bash init.sh

Here you will be presented with some options, but only "Full migration" is available at this time.

From there it will walk you through the various steps of the migration.

_Info: Still working on getting this fully documented._

If you do run into any problems with it, please submit them to https://github.com/jerius/cpmigrator/issues . Alternatively, you can fix the code and submit a pull request to the Github repo.

### Partial Migration

This will be mostly the same as the full migration, only it will handle a specific list of users or domains. Also, it will be expecting to see accounts and domains setup on the source server, and set the default options accordingly.

### Single Migration

This will migrate a single cPanel account, but will have additional options available if they are needed.

### Resume Migration

This will resume a migration that has been stopped. It is planned that a migration can be resumed from any location as long as you copy the files. (ie You complete the initial migration from the source server, and then run the final sync from the destination server) 
