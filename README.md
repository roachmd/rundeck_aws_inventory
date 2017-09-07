## rundeck aws resources.xml builder

### Environment
ZONE          AWS Zone In Use
STACK         { PROD or NONPROD } NONPROD is everything not prod.
RUNDECKFILE   Directory and name to put the resources.xml file

### Useage
export ZONE="us-west-2" STACK="NONPROD" RUNDECKFILE="resources.xml"; ./createResourcesxml.rb

[![Codacy Badge](https://api.codacy.com/project/badge/Grade/b1fe8bbf3d104b36a6300d7568b7227c)](https://www.codacy.com/app/roachmd/rundeck_aws_inventory?utm_source=github.com&utm_medium=referral&utm_content=roachmd/rundeck_aws_inventory&utm_campaign=badger)

Ruby script designed to pull aws resources and build a resources.xml file for use in rundeck.

-- I hated create this file by scratch. So, I wrote something in ruby to make my life easier.


----
[![Codacy Badge](https://api.codacy.com/project/badge/Grade/b1fe8bbf3d104b36a6300d7568b7227c)](https://www.codacy.com/app/roachmd/rundeck_aws_inventory?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=roachmd/rundeck_aws_inventory&amp;utm_campaign=Badge_Grade)
