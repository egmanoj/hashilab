# Ref: https://learn.hashicorp.com/tutorials/nomad/load-balancing-fabio
job "fabio" {
  region      = "global"
  # NOTE: Our local cluster is called `dc-local`
  datacenters = ["dc-local"]
  # Setting type to system ensures that Fabio is run on all clients.
  type        = "system"

  group "fabio" {
    network {
      port "lb" {
        static = 9999
      }
      port "ui" {
        static = 9998
      }
    }

    task "fabio" {
      driver = "docker"
      config {
        image        = "fabiolb/fabio"
        # network_mode option is set to host so that Fabio can communicate with Consul on the client nodes.
        network_mode = "host"
        ports        = ["lb", "ui"]
      }

      resources {
        cpu    = 200
        memory = 128
      }
    }
  }
}