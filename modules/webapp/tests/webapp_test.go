package test

import (
	"fmt"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestTerraformAzureWebApp(t *testing.T) {
	t.Parallel()

	// Generate a unique name for the resource group and web app
	uniqueId := random.UniqueId()
	expectedAppName := fmt.Sprintf("webapp-test-%s", strings.ToLower(uniqueId))
	expectedResourceGroupName := fmt.Sprintf("rg-test-%s", strings.ToLower(uniqueId))

	// Configure Terraform options
	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../",

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"app_name":              expectedAppName,
			"resource_group_name":   expectedResourceGroupName,
			"create_resource_group": true,
			"location":              "East US",
			"os_type":               "Linux",
			"sku_name":              "P1v2",
		},
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform output` to get the values of output variables
	actualWebAppUrl := terraform.Output(t, terraformOptions, "webapp_url")

	// Verify that the web app URL is constructed correctly
	expectedWebAppUrl := fmt.Sprintf("https://%s.azurewebsites.net", expectedAppName)
	assert.Equal(t, expectedWebAppUrl, actualWebAppUrl)
}
