# traefik-idc-demo

[Background](https://github.com/containous/traefik/issues/593#issuecomment-420306250) • [Demo](http://traefik-idc-demo.loki.xlipse.net/)                                                                                                                                                                                                               

**NOTE**: This repository contains a submodule pointing to [my fork of lua-resty-openidc](https://github.com/XA21X/lua-resty-openidc). Please run `git submodule update --init --recursive` after cloning the repository OR use the `--recurse-submodules` flag when cloning. 

In its current state, the provided compose files are for reference only, taking into account a more complicated setup specific to my server (that is also hosting the demo), and therefore will not work anywhere else without modification.

## Compose files

#### [docker-compose.yml](docker-compose.yml) [Tested] [Active]
* Expects an _external_ Traefik container that is watching Docker changes; needs network access to OpenResty.
* Includes its own OpenResty instance as the forward auth server; needs internet access to the identity provider.

#### [docker-compose.nested.yml](docker-compose.nested.yml) [Tested]
* Includes an internal Traefik container that is currently set up to run behind another external Traefik container, where the latter provides ACME/TLS termination. The `command` gives an idea of the minimal configuration required for Traefik.

#### [docker-compose.minimal.yml](docker-compose.minimal.yml)
* In production, both Traefik and the OpenResty auth server would likely be external. This provides an example of solely the configuration required for a protected service and is closest to what I have experimentally deployed.
