# NGINX Ingress Resources

This directory contains NGINX Ingress resources.

## Example Ingress

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-nginx-ingress
  namespace: default
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
  - host: localhost
    http:
      paths:
      - path: /app
        pathType: Prefix
        backend:
          service:
            name: my-service
            port:
              number: 80
```

## Notes

- NGINX Ingress is useful for local development and testing
- For external access, use Cloudflare Tunnel instead
- NGINX requires port forwarding or LoadBalancer service for external access
