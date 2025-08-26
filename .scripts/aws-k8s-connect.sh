#!/bin/bash

echo "🔐 Checking AWS SSO token for profile: $AWS_PROFILE"

if aws sts get-caller-identity --profile "$AWS_PROFILE" >/dev/null 2>&1; then
    echo "✓ AWS SSO token valid"
else
    echo "⚠ Token expired/invalid, logging in..."
    aws sso login --profile "$AWS_PROFILE" || {
        echo "❌ Login failed"
        exit 1
    }
fi

echo "🔄 Switching k8s context to: $AWS_K8S_CONTEXT"
kubie ctx "$AWS_K8S_CONTEXT" || {
    echo "❌ Failed to switch context"
    exit 1
}

sleep 2
k9s
