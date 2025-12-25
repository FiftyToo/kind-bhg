# Cloudflare Tunnel Resources

This directory contains Ingress resources for exposing services via Cloudflare Tunnel.

## Creating an Ingress

Example Ingress resource:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-service-ingress
  namespace: default
spec:
  ingressClassName: cloudflare-tunnel
  rules:
  - host: myapp.yourdomain.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: my-service
            port:
              number: 80
```

## Important Notes

- The domain must be configured in your Cloudflare account
- DNS records are automatically created by the controller
- No need for port forwarding or external load balancers
