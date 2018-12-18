# traefik-idc-demo

[Background](https://github.com/containous/traefik/issues/593#issuecomment-420306250) • [Demo](http://traefik-idc-demo.xlipse.net/)

**NOTE**: This repository contains a submodule pointing to [my fork of lua-resty-openidc](https://github.com/XA21X/lua-resty-openidc). Please run `git submodule update --init --recursive` after cloning the repository OR use the `--recurse-submodules` flag when cloning. 

In its current state, the provided [compose files](#compose-files) are for reference only, taking into account a more complicated setup specific to my server that is also hosting the demo, and therefore will not work anywhere else without modification.

The [auth.lua](openresty-docker/lua/traefik-idc/auth.lua) script was written to slightly modularise the added authentication bypass functionality (WIP; disabled with [examples](https://github.com/XA21X/traefik-idc-demo/blob/a2b65c39831e2aa1e7773d3e9132c6214c92ded3/openresty-docker/lua/traefik-idc/auth.lua#L60-L66)) where the forward auth server can skip the OIDC authentication based on the client IP and requested domain. Alternatively, the configuration can be inserted directly into [default.conf](openresty-docker/conf/default.conf) as per the [official instructions](https://github.com/zmartzone/lua-resty-openidc#sample-configuration-for-google-signin), with careful adaptation of the [HTTP status codes handling](https://github.com/XA21X/traefik-idc-demo/blob/a2b65c39831e2aa1e7773d3e9132c6214c92ded3/openresty-docker/lua/traefik-idc/auth.lua#L71-L87) required for forward auth servers.

## Compose files

#### [docker-compose.yml](docker-compose.yml) [Tested] [Active]
* Expects an _external_ Traefik container that is watching Docker changes; needs network access to OpenResty.
* Includes its own OpenResty instance as the forward auth server; needs internet access to the identity provider.

#### [docker-compose.nested.yml](docker-compose.nested.yml) [Tested]
* Includes an internal Traefik container that is currently set up to run behind another external Traefik container, where the latter provides ACME/TLS termination. The `command` gives an idea of the minimal configuration required for Traefik.

#### [docker-compose.minimal.yml](docker-compose.minimal.yml)
* In production, both Traefik and the OpenResty auth server would likely be external. This provides an example of solely the configuration required for a protected service and is closest to what I have experimentally deployed.

## Live demo

Visit the [protected endpoint](http://traefik-idc-demo.loki.xlipse.net/) and login with `test:test`.
