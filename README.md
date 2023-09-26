# Inventory Hub IaC

Infrastructure as code for inventory hub. Pre-requisites - install Terraform.

## Manual steps

Some features are not supported by by `hashicorp/azurerm`` :(

Install the azure cli and login to your account. `az login`

### CDN

To map the CDN to the custom domain, follow the steps from [here](https://docs.microsoft.com/en-us/azure/cdn/cdn-map-content-to-custom-domain?tabs=azure-portal).

### Azure Communication Service

This service is so unused that Azure does not even have it in the default cli nor the extension!

The following steps require manual intervention from the Azure Portal.

#### Verify the domain

1. Open the Email Communication Service `inventory-hub-communication-email` in the Azure Portal.
2. In the **Settings -> Provision Domain** tab click **+ Add Domain** and then **Custom Domain**.
3. Enter the domain name `inventory-hub.space` and click **Add**. Wait for the domain to be added and then click **Verify Domain**.
4. Follow the instructions from [here](https://learn.microsoft.com/en-us/azure/communication-services/quickstarts/email/add-custom-verified-domains) and apply them on namecheap to verify the domain. This might take a while. Related video [here](https://www.youtube.com/watch?v=ybLaf1Y760A&ab_channel=Instantly).
5. Add the EmailFrom address `no-reply@inventory-hub.space`

#### Connect the domain to communication service

5. Open the Communication Service `inventory-hub-communication-service` in the Azure Portal.
6. In the **Email -> Domain** section click the **Connect Domain** button.
7. Complete the form with information from `inventory-hub-communication-email` and click **Connect**.
