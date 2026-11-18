terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.4"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.12"
    }
  }

  required_version = ">= 1.3.0"
}

provider "aws" {
  region = "us-east-1"
}

# Demo only: S3 traffic for this alias goes to a non-routable IP, so every
# call hangs until the SDK gives up. Configuring it makes no network calls;
# it only bites when failure_mode = "provider_timeout".
provider "aws" {
  alias       = "blackhole"
  region      = "us-east-1"
  max_retries = 1

  # Path-style keeps the host as the bare IP. Virtual-hosted style would fail
  # fast on DNS instead of timing out.
  s3_use_path_style = true

  endpoints {
    s3 = "https://10.255.255.1"
  }
}
