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
  if string.match(kong.request.get_path(),'^/.*/health$') then
    return
  end
 
  local client = http.new()
  client:set_timeouts(5000, 5000, 5000)
 
  local req_headers = kong.request.get_headers()
  req_headers['X-Forwarded-Uri'] = kong.request.get_path()
  local res, err = client:request_uri(conf.url, {
    method = "GET",
    path = tostring(conf.path),
    headers = {
	["X-Forwarded-Uri"] = kong.request.get_path(),
	["sign"] = kong.request.get_header("sign"),
	["loginname"] = kong.request.get_header("loginname"),
	["rolecode"] = kong.request.get_header("rolecode"),
	["token"] = kong.request.get_header("token"),	
	}
  })
  if err then
    kong.log.err(err,kong.request.get_path(),kong.request.get_method())
	return kong.response.exit(500,"Auth Server Error"..err)
  end
 
  if not res then
    return kong.response.exit(500,"Auth Server Error")
  end
 
  if res.status ~= 200 then
    kong.log.err(res.status,kong.request.get_path(),conf.url,tostring(conf.path),res.body)
    return kong.response.exit(res.status, "Access Forbidden")
  end
  
  if conf.authResponseHeaders then
    for k,v in pairs(conf.authResponseHeaders)
    do
	  if res.headers[v] then
        kong.service.request.set_header(v,res.headers[v])
	  else
	    kong.log.err(v..' is null')
	  end
	end
  end
 
end
 
 
AuthForwardHandler.PRIORITY = 500
 
return AuthForwardHandler