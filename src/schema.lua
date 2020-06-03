return {
  no_consumer = true,
  fields = {
    url = { required = true, type = "url" },
    path = { required = true, type = "string" },
    authResponseHeaders = { type = "array" },
    connect_timeout = { default = 10000, type = "number" },
    send_timeout = { default = 60000, type = "number" },
    read_timeout = { default = 60000, type = "number" }
  }
}
