# Configure the Azure Resource Manager Provider
provider "azurerm" {
  subscription_id = "2db6d261-2e79-4a72-bd34-21fe049260cc"
  client_id       = "62623c53-1c9b-4664-b3e1-4b23ae3f608d"
  client_secret   = "B2Kf/pCZzI1IRt1cOkL5mRVNkLQuHbW7j42iNv4bidQ="
  tenant_id       = "0c38db8e-0eec-4bba-829c-f9d7ae2bf8e0"
}

# Create a resource group
resource "azurerm_resource_group" "test" {
    name     = "test"
    location = "Japan West"
}
