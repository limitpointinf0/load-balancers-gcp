# Load Balancers in GCP Example
Experimenting with Cloud Load Balancer.

## How To Start the Project
- Step 1: Run the following commands to create the necessary VMs, instance groups, firewall configurations, etc. Three of the VMs will be running Nginx and listening on port 80. The test VM is reserved for Load Testing from Tokyo Japan. 
```bash
terraform init
terraform plan
terraform apply
```  

- Step 2: In the GCP console, go to Network Services and create a new HTTP(S) load balancer and configure it as follows:
    - Backend Service:
        - Backend Type: instance group
        - Add all of the instance groups to the backend
        - Healthcheck: check TCP
    - Frontend Service:
        - HTTP
    
- Step 3: You may at this point run a test by sending http traffic to the public IP of the load balancer from the test VM

## How to Remove the Project
- Step 1: Delete the load balancer created along with all backend services and healthchecks

-Step 2: Run the following command to remove all instances, instance groups, firewall configurations, etc.
```bash
terraform destroy
```  

## License

[MIT](https://choosealicense.com/licenses/mit/)
