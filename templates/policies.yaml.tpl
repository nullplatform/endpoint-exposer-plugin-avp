apiVersion: security.istio.io/v1
kind: AuthorizationPolicy
metadata:
  name: {{ .service_slug }}-{{ .service_id }}-authz
  namespace: {{ .k8s_namespace }}
  labels:
    app.kubernetes.io/name: {{ .service_slug }}
    nullplatform.com/service-id: "{{ .service_id }}"
    nullplatform.com/managed-by: endpoint-exposer
spec:
  selector:
    matchLabels:
      nullplatform: "true"
  action: CUSTOM
  provider:
    name: {{ .provider_name }}
  rules:
  - to:
    - operation:
        hosts:
          - {{ .domain }}
        methods:
{{ range .methods }}          - {{ . }}
{{ end }}        paths:
{{ range .paths }}          - {{ . }}
{{ end }}