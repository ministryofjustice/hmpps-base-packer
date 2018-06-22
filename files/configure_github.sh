#!/usr/bin/env bash

aws --region $AWS_REGION ssm get-parameters --with-decryption --names $KEY_NAME | jq -r '.Parameters[0].Value' > $OUTPUT_PATH
chmod 600 $OUTPUT_PATH

git config --global user.name "$GIT_USER_NAME"
git config --global user.email "$GIT_USER_EMAIL"

unset KEY_NAME
unset OUTPUT_PATH
unset GIT_USER_NAME
unset GIT_USER_EMAIL