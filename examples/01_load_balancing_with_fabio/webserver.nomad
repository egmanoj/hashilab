# Ref: https://learn.hashicorp.com/tutorials/nomad/load-balancing-fabio#create-and-run-an-apache-web-server-job
job "webserver" {
  region      = "global"
  # NOTE: Our local cluster is called `dc-local`
  datacenters = ["dc-local"]
  type        = "service"

  group "webserver" {
    count = 3
    network {
      # Ref: https://www.nomadproject.io/docs/job-specification/network#mapped-ports
      port "http" {
        to = 80
      }
    }

    service {
      name = "apache-webserver"
      tags = ["urlprefix-/"]
      port = "http" # Defined above, in `network` stanza
      check {
        name     = "alive"
        type     = "http"
        path     = "/"
        interval = "10s"
        timeout  = "2s"
      }
    }

    restart {
      attempts = 2
      interval = "30m"
      delay    = "15s"
      mode     = "fail"
    }

    task "apache" {
      driver = "docker"
      config {
        image = "httpd:latest"
        ports = ["http"] # Defined above, in `network` stanza
      }
    }

  }

}