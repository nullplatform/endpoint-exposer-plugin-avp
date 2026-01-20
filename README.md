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
└── workflows/
    └── ...                            # Workflow definitions
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

The `np service workflow exec` CLI automatically extracts the base path from the `--overrides` argument. When a workflow file is passed via `--overrides`, the CLI uses a regex pattern `/[^/]+/workflows/.*\.yaml$` to extract the base directory.

**How it works:**
```bash
# Input to CLI
--overrides /root/.np/nullplatform/endpoint-exposer-plugin-avp/workflows/create.yaml

# The CLI regex removes everything from /workflows/*.yaml onward
# OVERRIDES_PATH gets set to
OVERRIDES_PATH=/root/.np/nullplatform/endpoint-exposer-plugin-avp
```

**Therefore, workflow files should use direct paths:**
```yaml
file: "$OVERRIDES_PATH/scripts/generate_cedars"  # ✅ Correct
```

**Not:**
```yaml
file: "$OVERRIDES_PATH/endpoint-exposer-plugin-avp/scripts/generate_cedars"  # ❌ Wrong (double nesting)
```

**Reference:** See `getOverridesBasePath()` function in `cli/cmd/service/workflow/exec/service_workflow_exec.go` (lines 844-849)
