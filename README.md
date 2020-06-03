# kong-plugin-forwardauth

## Environment

k8s 1.13
kong 2.0
kong-ingress-controller:0.8.1

## Description

This plugin lets you authenticate any request using a separate HTTP service.

For every incoming request, the method, query and headers are forwarded to the auth service (removing the body).

If the service returns 200, the request continues the normal path. In any other case, 401 (Unauthorized) is returned to the client.

You can set authResponseHeaders to copy header from response and set to request's header.

Always ignore OPTIONS request.

## Installation

[setting-up-custom-plugins](https://github.com/Kong/kubernetes-ingress-controller/blob/master/docs/guides/setting-up-custom-plugins.md)
## Configuration
```
apiVersion: configuration.konghq.com/v1
kind: KongPlugin
metadata:
  name: app-auth
config:
  url: http://172.16.0.86:5001
  path: /auth
  authResponseHeaders:
    - X-User-Id
    - X-Role-Code
plugin: auth-forward
```
## Author

owen cao
