- [What is Terraform ?](#what-is-terraform-)
- [Resource Blocks](#resource-blocks)
  - [In a few words](#in-a-few-words)
  - [Syntax](#syntax)
- [Resource Types](#resource-types)
  - [Definition](#definition)
  - [Providers](#providers)
    - [Definition](#definition-1)
    - [Requirements](#requirements)
- [Workflow](#workflow)
- [Provisioning Infrastructure](#provisioning-infrastructure)
  - [Planning](#planning)
  - [Applying](#applying)
  - [Destroying](#destroying)
- [Terraform language](#terraform-language)

# What is Terraform ?

It is an **infrastructure as code tool** allowing to build, change and version cloud 
resources.\
*Infrastructure as Code (IaC)* tools allow to manage infrastructure with 
configuration files rather than through a graphical user interface (GUI).\
HashiCorp and Terraform community have written over 1000 providers to manage 
resources on AWS, Azure, GCP, GitHub and many more.

# Resource Blocks

## In a few words

They are the most important elements in Terraform language, each resource block 
**describes one or more infrastructure objects** like virtual networks, compute
instances or even DNS and many others.


## Syntax
A ``resource block`` declares a resource of a **specific type** and a 
**specific local name**. Here let's create a *google_compute_instance* resource type
named *vm_instance*
````terraform
resource "google_compute_instance" "vm_instance" {
    name         = "terraform-instance"
    machine_type = "e2-micro"
}
````
We put the configuration arguments for the resource between the curly brackets ``{}``.

# Resource Types

## Definition

It **determines the kind of infrastructure object the resource manages** and what
arguments and other attributes the resource supports.

## Providers

### Definition
It is a **plugin for Terraform offering a collection of resource types**. 

### Requirements

Each Terraform module declares which providers it requires, so that Terraform can 
install them. A provider requirement consists of:
- *local name*
- *source location*
- *version constraint*

````terraform
terraform {
  required_providers {
    hashicorp-htpp = {            # local name of 
      source  = "hashicorp/http"  # source location
      version = "~> 1.0"          # version, '~>' convenient shorthand for allowing the rightmost component of a version to increment
    }
    mycloud = {                    
      source  = "mycorp/mycloud"  
      version = "~> 1.0"
    }
  }
}

provider "mycloud" {
  # ...
}

data "http" "example" {
  provider = hashicorp-http
}
````

# Workflow

- **Scope**: identify the infrastructure for your project
- **Author**: Write the configuration for your infrastructure
- **Initialize**: Install the plugins Terraform needs to manage the infrastructure
- **Plan**: Preview the changes Terraform will make to match your configuration
- **Apply**: Make the planned changes


# Provisioning Infrastructure 

## Planning

````bash
terraform plan
````
It evaluates a Terraform configuration to determine the desired state of all the 
resources it declares then compares that desired state to the real infrastructure 
object

## Applying

````bash
terraform apply
````
Like ``terraform plan`` it performs a plan then carries out the planned changes to 
each resource using the relevant infrastructure provider's API.

## Destroying

````bash
terraform destroy
````

It destroys all of the resources being managed by the current working directory and 
workspace using state data to determine which real world correspond to managed 
resources.


# Terraform language