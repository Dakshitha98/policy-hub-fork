# Reliable Policy Delivery

This workflow implements folder-based reliable delivery for Policy Hub releases.

## Overview

Instead of all-or-nothing release processing, this approach:

- **Tracks delivery per folder** using commit SHAs
- **Automatically retries failed deliveries** on subsequent releases
- **Persists state in the repository** for transparency and auditability
- **Processes only changed folders** since the last baseline

## State Management

### `.state/baseline.sha`
Contains the earliest commit SHA to consider for changes. Initially set to the repository root commit.

### `.state/delivered.json`
Tracks successful deliveries per folder:

```json
{
  "policies/set-header/v1.0.0": "abc123...",
  "policies/rate-limiter/v1.0.0": "def456..."
}
```

## Workflow Behavior

1. **Detect changed folders** since baseline using `git diff`
2. **Check delivery eligibility** for each folder
3. **Skip already-delivered folders** with same commit SHA
4. **Deliver eligible folders** with idempotency keys
5. **Update state only on success**
6. **Commit state changes** back to repository

## Benefits

- ✅ **Reliable**: Failed folders retry automatically
- ✅ **Idempotent**: Safe to re-run without duplicates
- ✅ **Incremental**: Only processes changes
- ✅ **Auditable**: All state changes versioned in Git
- ✅ **Granular**: Per-folder success/failure tracking

## Migration from Batch Release

The new `reliable-delivery.yml` workflow replaces `batch-release.yml` for production releases. The old workflow can be kept for validation or removed once the new approach is verified.