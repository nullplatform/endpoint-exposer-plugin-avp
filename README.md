# Amazon Verified Permissions plugin for Endpoint Exposer service

This plugin provides Amazon Verified Permissions (AVP) authorization integration for the endpoint-exposer service using Cedar policies and Istio AuthorizationPolicy resources.

## Overview

The AVP Authorizer plugin generates Kubernetes manifests for implementing fine-grained authorization controls on exposed endpoints. It integrates with AWS Verified Permissions to enforce Cedar-based policies through Istio's external authorization framework.

## Repository Structure

```
endpoint-exposer-plugin-avp/
├── scripts/
│   ├── generate_cedars                 # Script to generate Cedar policy files
│   └── generate_authorization_policy   # Script to generate Istio AuthorizationPolicy manifests
├── templates/
│   └── policies.yaml.tpl              # Template for Istio AuthorizationPolicy resources
└── service/
    └── workflows/                      # Workflow definitions
        ├── create.yaml
        ├── update.yaml
        └── delete.yaml
```

## Getting Started

### How It Works

1. The plugin generates Cedar policies for AWS Verified Permissions
2. It creates Istio AuthorizationPolicy manifests that reference the external authorizer
3. Generated manifests are stored in `$OUTPUT_DIR` for deployment to Kubernetes


### Required Scripts

When adding new functionality, ensure the following scripts are properly implemented:

1. **`generate_cedars`** - This script should:
   - Generate Cedar policy files based on the service configuration
   - Output policies compatible with AWS Verified Permissions
   - Store generated policies in the appropriate location

2. **`generate_authorization_policy`** - This script should:
   - Generate Istio AuthorizationPolicy manifests from templates
   - Output manifests to `$OUTPUT_DIR`

### Output Directory

All generated Kubernetes manifests **must** be placed in the `$OUTPUT_DIR` directory. This ensures proper integration with the endpoint-exposer service provisioning pipeline.

### Important Note on OVERRIDES_PATH

The `np service workflow exec` CLI automatically extracts the base path from the `--overrides` argument. The CLI uses regex pattern `/[^/]+/workflows/[^/]+\.yaml$` to extract the base directory.

**How it works:**

```bash
# Input to CLI
--overrides /root/.np/nullplatform/endpoint-exposer-plugin-avp/service/workflows/create.yaml

# The CLI regex matches: /service/workflows/create.yaml
# OVERRIDES_PATH gets set to
OVERRIDES_PATH=/root/.np/nullplatform/endpoint-exposer-plugin-avp  ✅ CORRECT
```

**Workflow files should use direct paths:**
```yaml
file: "$OVERRIDES_PATH/scripts/generate_cedars"  # ✅ Correct
```

**Not:**
```yaml
file: "$OVERRIDES_PATH/endpoint-exposer-plugin-avp/scripts/generate_cedars"  # ❌ Wrong (double nesting)
```

**Important:** Workflows must be in a subdirectory (e.g., `service/workflows/` or `deployment/workflows/`), not directly under the plugin root. This is required by the CLI's regex pattern.

**CLI Fix:** The regex was updated from `/[^/]+/workflows/.*\.yaml$` to `/[^/]+/workflows/[^/]+\.yaml$` to be more precise and avoid greedy matching. See `getOverridesBasePath()` in `cli/cmd/service/workflow/exec/service_workflow_exec.go` (lines 844-849)
