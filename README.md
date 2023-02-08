# posthog cloudinit

This is a terraform module that generates a cloud-config yaml file for cloud-init targeting apt.

It's based on the [deploy-hobby](https://github.com/PostHog/posthog/blob/master/bin/deploy-hobby) script in the posthog repo. (If that file is substantially fresher than this repo, or gone, close this tab immediately and forget you were ever here).

I don't support this (morally or technically), I don't work at posthog, and you should assume this isn't up-to-date, secure etc. Check out [posthog hardening guidelines](https://posthog.com/docs/self-host/configure/securing-posthog) for the deprecated self-hosted kube setup. (This repo produces the docker-compose stack, but the security docs are still for kube). Proceed at your own risk.

## Example on GCP

```terraform
resource google_compute_address posthog {
  name = "posthog"
}

variable posthog_domain {}

resource google_dns_record_set posthog {
  name =  var.posthog_domain
  managed_zone = ...
  type = "A"
  ttl = 300
  rrdatas = [google_compute_address.posthog.address]
}

resource random_password posthog-secret {
  length = 56
  special = false
}

module posthog-init {
  source = "github.com/abe-winter/posthog-cloudinit"
  domain = var.posthog_domain
  secret_key = random_password.posthog-secret.result
}

resource google_compute_instance posthog {
  name = "posthog"
  machine_type = "e2-custom-2-4096"
  zone = "us-central1-a"
  tags = ["posthog"]

  boot_disk {
    initialize_params {
      size = 100
      image = "ubuntu-2204-jammy-v20230114"
    }
  }

  metadata = {
    user-data = module.posthog-init.cloudinit.rendered
  }

  // ... // more non-posthog stuff you need to boot your box
}
```

## Roadmap

- [ ] set up [testing](https://canonical-cloud-init.readthedocs-hosted.com/en/latest/howto/predeploy_testing.html) so I don't have to power cycle a box every time I change something
- [ ] ideally hand this off to official support
