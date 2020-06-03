local BasePlugin = require "kong.plugins.base_plugin"
local http = require "resty.http"
 
local AuthForwardHandler = BasePlugin:extend()
 
function AuthForwardHandler:new()
  AuthForwardHandler.super.new(self, "external-auth")
end
 
function AuthForwardHandler:access(conf)
  AuthForwardHandler.super.access(self)
 
  if kong.request.get_method() == "OPTIONS" then
    return
  end
 
  local client = http.new()
  client:set_timeouts(conf.connect_timeout, send_timeout, read_timeout)
 
  local res, err = client:request_uri(conf.url, {
    method = kong.request.get_method(),
    path = tostring(conf.path),
    query = kong.request.get_raw_query(),
    headers = kong.request.get_headers(),
    body = ""
  })
 
  if not res then
    return kong.response.exit(500,"auth server error")
  end
 
  if res.status ~= 200 then
    return kong.response.exit(401,"auth fail")
  end
 
  for k,v in pairs(conf.authResponseHeaders)
  do
    kong.service.request.set_header(tostring(v),res.headers[tostring(v)])
  end
 
end
 
 
AuthForwardHandler.PRIORITY = 500
 
return AuthForwardHandler