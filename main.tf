variable domain {
  type = string
  description = "domain that points to this box (note: caddy uses this to create a cert)"
}
variable secret_key {
  type = string
  description = "for signing cookie"
}
variable sentry_dsn {
  type = string
  default = ""
}
variable posthog_version {
  type = string
  default = "1.43.0"
}
variable docker_compose_version {
  type = string
  default = "2.13.0"
}

terraform {
  required_version = ">= 0.12.0"
  required_providers {
    template = ">= 2.2.0"
    cloudinit = ">= 2.2.0"
  }
}

data template_file posthog-cloudconfig {
  template = file("${path.module}/cloudinit.yaml")
  vars = {
    DOMAIN = var.domain
    POSTHOG_SECRET = var.secret_key
    SENTRY_DSN = var.sentry_dsn
    POSTHOG_VERSION = var.posthog_version
    DOCKER_COMPOSE_VERSION = var.docker_compose_version
    path_module = path.module
  }
}

data cloudinit_config posthog {
  gzip = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    content = data.template_file.posthog-cloudconfig.rendered
    filename = "conf.yaml"
  }
}

output raw_template { value = data.template_file.posthog-cloudconfig }
output cloudinit { value = data.cloudinit_config.posthog }
