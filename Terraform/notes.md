- [What is Terraform ?](#what-is-terraform-)
- [Ressources](#ressources)
  - [Syntax](#syntax)
  - [In a few words](#in-a-few-words)
  - [Ressource Blocks](#ressource-blocks)
- [Workflow](#workflow)
- [Provisioning Infrastructure](#provisioning-infrastructure)
  - [Planning](#planning)
  - [Applying](#applying)
  - [Destroying](#destroying)
- [Terraform language](#terraform-language)

# What is Terraform ?

It is an **infrastructure as code tool** allowing to build, change and version cloud 
ressources.\
*Infrastructure as Code (IaC)* tools allow to manage infrastructure with 
configuration files rather than through a graphical user interface (GUI).\
HashiCorp and Terraform community have written over 1000 providers to manage 
ressources on AWS, Azure, GCP, GitHub and many more.

# Ressources

## Syntax
A ``ressource block`` declares a resource of a **specific type** and a 
**specific local name**. Here let's create a *google_compute_instance* resource type
named *vm_instance*
````terraform
resource "google_compute_instance" "vm_instance" {
    name         = "terraform-instance"
    machine_type = "e2-micro"
}
````

## In a few words

They are the most important elements in Terraform language, each ressource block 
**describes one or more infrastructure objects** like virtual networks, compute
instances or even DNS and many others.

## Ressource Blocks


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
ressources it declares then compares that desired state to the real infrastructure 
object

## Applying

````bash
terraform apply
````
Like ``terraform plan`` it performs a plan then carries out the planned changes to 
each ressource using the relevant infrastructure provider's API.

## Destroying

````bash
terraform destroy
````

It destroys all of the ressources being managed by the current working directory and 
workspace using state data to determine which real world correspond to managed 
ressources.


# Terraform language