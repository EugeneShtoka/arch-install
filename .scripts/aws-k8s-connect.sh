#!/bin/zsh

TAB_TITLE="k9s"

if [[ -z "$AWS_K8S_LAUNCHED" ]]; then
  exec $SCRIPTS_PATH/wezterm-focus-or-launch.sh "$TAB_TITLE" \
    /usr/bin/zsh -ilc "AWS_K8S_LAUNCHED=1 $SCRIPTS_PATH/aws-k8s-connect.sh"
fi

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
kubie exec "$AWS_K8S_CONTEXT" -- k9s
