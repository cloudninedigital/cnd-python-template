## Instructions

This folder is for shared resources that should not get replicated in multiple development stages. An example of this is when implementing static IP's, these should not have different versions in every development stage, and thus will be deployed in shared.

two important notes: 

* This folder will (for now) always be deployed manually
* The actual deployment can be done through `sh deploy.sh` in this folder (this is to ensure that deployment will always be done to the shared workspace). 

### Always be careful when deploying. If your apply plan says it's going to destroy a large number of resources, this means you're probably not in the right workspace and you should cancel your deployment!