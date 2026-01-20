apiVersion: security.istio.io/v1
kind: AuthorizationPolicy
metadata:
  name: avp-ext-authz-{{ .service_slug }}-{{ .service_id }}
  namespace: {{ .k8s_namespace }}
  labels:
    app.kubernetes.io/component: authorization
    app.kubernetes.io/managed-by: endpoint-exposer
    app.kubernetes.io/name: {{ .service_slug }}
    authorizer-mode: lambda
    nullplatform.com/service-id: "{{ .service_id }}"
    nullplatform.com/managed-by: endpoint-exposer
spec:
  action: CUSTOM
  provider:
    name: avp-ext-authz
  rules:
  - to:
    - operation:
        hosts:
{{ range .hosts }}          - {{ . }}
{{ end }}        paths:
{{ range .paths }}          - {{ . }}
{{ end }}  selector:
    matchLabels:
      gateway.networking.k8s.io/gateway-name: {{ .gateway_name }}