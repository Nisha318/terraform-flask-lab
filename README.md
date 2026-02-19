# GRC Flask Lab — EC2 Deployment with OpenTofu and GitHub Actions

## Overview
This project deploys a Flask web application on AWS EC2 using Infrastructure as Code 
and a fully automated CI/CD pipeline. It was built as an extension of the 
GRC Engineering Club's Flask on EC2 Lab, which bridges compliance knowledge 
with practical cloud engineering skills.

## What This Project Demonstrates
- EC2 provisioning and security group configuration
- SSH key management and secure access controls
- Flask web application deployment on Linux
- Infrastructure as Code with OpenTofu (Terraform-compatible)
- CI/CD pipeline automation with GitHub Actions
- OIDC-based AWS authentication (no static credentials)
- systemd service management for application reliability

## Architecture
```
GitHub Repository
       │
       ▼
GitHub Actions CI/CD Pipeline
       │
       ├── Lint & Validate (.tf files)
       ├── Plan (on pull requests)
       └── Apply (on push to main)
                    │
                    ▼
              AWS EC2 Instance
              ├── Security Group (ports 22, 5000)
              ├── SSH Key Pair
              └── Flask Application (port 5000)
```

## API Endpoints
| Endpoint | Description |
|----------|-------------|
| `/` | Main dashboard page |
| `/health` | Health check endpoint |
| `/api/controls` | NIST 800-53 control status |

## NIST 800-53 Control Mapping
| Control | Implementation |
|---------|---------------|
| AC-4 | Security group rules enforce information flow |
| AU-2 | systemd logging via journalctl |
| CM-2 | Infrastructure defined as code in .tf files |
| CM-3 | Git history provides configuration change audit trail |
| CM-8 | Terraform state tracks all provisioned resources |
| IA-2(1) | MFA enabled on AWS root account |
| IA-5 | SSH key pair managed via OpenTofu |
| SC-7 | Security group implements boundary protection |

## CI/CD Pipeline
The GitHub Actions workflow automates the following on every push to main:

1. **Lint and Validate** — checks HCL formatting and syntax
2. **Tofu Plan** — previews infrastructure changes (pull requests only)
3. **Tofu Apply** — provisions or updates AWS infrastructure

Authentication to AWS uses **OpenID Connect (OIDC)** — no long-lived 
credentials are stored in GitHub Secrets. GitHub Actions assumes an IAM 
role with temporary credentials scoped to each workflow run.

## Security Design Decisions
- S3 remote backend (`tfstate-flask-lab`) stores Terraform state, enabling 
  both local and GitHub Actions deployments to share the same state file
- OIDC used instead of static IAM access keys for GitHub Actions authentication
- SSH access restricted to deployer IP via dynamic CIDR in security group
- Private keys never stored in version control
- `.gitignore` excludes all state files, credentials, and key material
- EC2 volume encrypted at rest

## Project Structure
```
terraform-flask-lab/
├── main.tf              # Core infrastructure resources
├── variables.tf         # Input variable definitions
├── outputs.tf           # Output values (IP, URL, SSH command)
├── terraform.tfvars     # Environment-specific values
├── userdata.sh          # EC2 bootstrap script
├── .github/
│   └── workflows/
│       └── deploy.yml   # GitHub Actions CI/CD pipeline
└── .gitignore           # Excludes state files and credentials
```

## Prerequisites
- AWS account with free tier eligibility
- OpenTofu installed locally
- AWS CLI configured
- GitHub repository with OIDC IAM role configured

## Deployment
Infrastructure is deployed automatically via GitHub Actions on push to main.

To deploy manually:
```bash
tofu init
tofu plan
tofu apply
```

To destroy all resources:
```bash
tofu destroy
```

## Accessing the Application
After deployment, retrieve the public IP from the Tofu outputs:
```bash
tofu output flask_url
```

## Future Enhancements
- Separate deploy-app job for zero-downtime app updates
- HTTPS via ACM and Application Load Balancer
- CloudWatch logging and alerting
- RDS database integration
- Least-privilege IAM policy scoped to required resources only

## Built With
- [Flask](https://flask.palletsprojects.com/) - Python web framework
- [OpenTofu](https://opentofu.org/) - Infrastructure as Code
- [GitHub Actions](https://docs.github.com/en/actions) - CI/CD automation
- [AWS EC2](https://aws.amazon.com/ec2/) - Compute infrastructure

## Acknowledgements
Lab concept and foundation by [GRC Engineering Club](https://www.grcengineering.club) 
— bridging compliance and code.