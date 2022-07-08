# Azure-ODM-Automation-Deployment

This repo contains an az cli script to deploy all the infrastructure and neccasary components to automate the process of generating Orthophotos and 3d-modells from drone images using https://github.com/OpenDroneMap/ODM and Azure Compute. The function that orchestrate the actual processing job is allocated at:
https://github.com/reduards/Azure-ODM-Automation-Function

How to get going:

1. Fork or download the repo locally.

2. Edit the variables in script.sh to with necassary value and to your liking (however notice that you will have to change the environment variables to match that in the serverless function later).

3. Edit logicappcontent.json with your email address and an office365 connection.

4. Run the script.sh, you will need to have az cli installed.

5. Make sure everything have been deployed in your Azure environment.

6. Fork function code repository:

https://github.com/reduards/Azure-ODM-Automation-Function

7. Go to Azure --> Click on Function App just created --> Click on "Deployment Slot" --> Follow the steps and select the newly forked function repo from Github.

This will hook up your Azure Function App with functions from the repo and will make sure to it is synchronized whenever you make a change. Now you can make changes either via codespaces or by pulling the repo locally.

8. Go ahead and edit the local.setting.json to match your newly deployed infrastructure if you changed any of the variables in the script.sh

9. Finally add a secret to the Azure Key Vault called "function key" which you will find "Azure Function"-->"drone-httpstarter"-->"Function Key" or by running the az cli command:

az functionapp function keys list -g RESOURCEGROUPNAME -n AZUREFUNCTIONNAME --function-name drone-httpstarter --query 'default' -o tsv

---

* OpenDroneMap Mygla dataset *

---

Photos: Tomasz Nycz, on CC-BY license (http://creativecommons.org/licenses/by/3.0/deed.pl).

Dataset was created with DJI P3S on Tokarzonka site, 08.02.2012 
http://www.openstreetmap.org/#map=18/49.59361/18.87319


