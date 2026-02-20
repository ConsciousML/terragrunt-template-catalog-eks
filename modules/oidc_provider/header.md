# AWS OpenID Connect (OIDC) Module

This module creates or retrieves an existing OIDC provider in AWS to connect GitHub Actions with AWS.

The `create` argument is crucial. If this module was used using `create=true`, subsequent use of this module must use `create=false`.

AWS does not allows to create two OIDC providers with the same url.