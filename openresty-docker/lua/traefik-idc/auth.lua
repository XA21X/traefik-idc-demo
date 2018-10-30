local auth = {}

local function authenticate_openidc()

  -- For more examples, visit: https://github.com/zmartzone/lua-resty-openidc
  local opts = {
    redirect_uri = "https://traefik-idc-demo.loki.xlipse.net/redirect_uri",
    discovery = "https://auth.xlipse.net/auth/realms/traefik-idc-demo/.well-known/openid-configuration",
    client_id = "traefik-idc-demo",
    client_secret = "717c73fc-3f94-4d63-84c4-289f1f3ee9fd",

    scope = "openid email profile",

    -- Refresh id_token silently
    refresh_session_interval = 900,

    -- Only permit secure redirect
    redirect_uri_scheme = "https",

    -- Actually redirect somewhere (vs a blank page)
    post_logout_redirect_uri = "https://xlipse.net/",

    -- Allow for minor delays (defaults to 0 otherwise)
    timeout = 1000,
  }

  local res, err = require("resty.openidc").authenticate(opts)

  if err then
    return nil, err
  end

  if not res then
    return false, nil
  end

  -- If needed, pass information about the user via headers, being careful about sanitisation!
  -- ngx.req.set_header("REMOTE_USER", res.id_token.sub)

  return true, nil
end

local function from_network(network)
  -- TODO: Write/use generic subnet parser? Currently only accepts 10.x.x.0/24!
  if not network:match("^10%.%d+%.%d+%.0/24$") then
    ngx.log(ngx.ERR, "unacceptable network format: " .. network)
    return false
  end
  local pattern = "^" .. network:gsub("%.", "%%%."):gsub("0/24", "%%d%+") .. "$"
  -- NOTE: Assumes remote_addr is trusted from the ngx_http_realip_module!
  return ngx.var.remote_addr:match(pattern)
end

local function to_domain(domain)
  local host = ngx.var.http_x_forwarded_host
  return host and host:lower() == domain:lower()
end

local function authenticate_bypass()
  -- if from_network("10.1.8.0/24") then
  --   return true
  -- end

  -- if from_network("10.1.16.0/24") and to_domain("example.com") then
  --   return true
  -- end

  return false
end

local function finalize(status, msg)
  ngx.status = status
  ngx.say(msg)
  return ngx.exit(status)
end

local function deny_error(msg)
  return finalize(ngx.HTTP_INTERNAL_SERVER_ERROR, msg or "error")
end

local function deny_forbidden(msg)
  return finalize(ngx.HTTP_FORBIDDEN, msg or "forbidden")
end

local function accept(msg)
  return finalize(ngx.HTTP_ACCEPTED, msg or "accepted")
end

function auth.authenticate()
  local res, err = authenticate_bypass()

  local or_methods = {authenticate_bypass, authenticate_openidc}

  for i, authenticate in ipairs(or_methods) do
    local res, err = authenticate()

    if err then
      ngx.log(ngx.ERR, "authenticate failed: " .. tostring(err))
      return deny_error()
    end

    if res then
      return accept()
    end
  end

  return deny_forbidden()
end

return auth
