# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] - 13/02/2026

### Fixed
- **BREAKING FIX**: Removed `formatSettings` from Data Factory pipeline templates to support azurerm provider 4.54's stricter `validateDataConsistency` validation
- Data Factory pipelines now use Direct Binary mode for improved reliability and compatibility
- Fixed compatibility issue where pipeline deployments would fail with azurerm provider 4.54 due to unsupported formatSettings in binary copy mode with data consistency validation enabled

### Changed
- Pipeline templates (`data-factory-pipeline-incremental.tpl` and `data-factory-pipeline-full.tpl`) now omit the `formatSettings` block from binary source configuration
- This enables pure byte-for-byte Direct Binary copy mode, which fully supports checksum and size validation

### Added
- `versions.tf` file to explicitly document Terraform and provider version requirements
- Module now supports both azurerm provider 3.54 and 4.54+

### Migration Notes
- **Action Required for azurerm 4.54 users**: You MUST upgrade to this module version if using azurerm provider 4.54 or later
- **Backward Compatible**: Users on azurerm provider 3.54 can safely upgrade to this module version
- **Expected Terraform Behavior**: When applying this update, Terraform will update the Data Factory pipeline resources in-place (no destroy/recreate)
- **Testing Recommendation**: Test in non-production environments first to verify backup operations work as expected
- **Functionality**: No change to backup behavior - files are still copied exactly as-is with the same filtering, hierarchy preservation, and scheduling

## [1.1.0] - 27/03/2024

This release has email alerts added to the module based off of Failed Pipeline runs.

Further information on var setting in readme.

## [1.0.0] - 19/03/2024

This release needs a passed in existing data storage account.

This version release also doesn't have any alerts setup.