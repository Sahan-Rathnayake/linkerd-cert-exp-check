{{/*
Common labels for all resources
*/}}
{{- define "linkerd-cert-exp-check.labels" -}}
labels:
  chart: {{ .Chart.Name }}
  version: {{ .Chart.Version | quote }}
{{- end -}}