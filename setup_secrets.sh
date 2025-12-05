#!/bin/bash

# Script to create secrets files for Inception project
# Run this once before launching the project

echo "Creating secrets directory..."
mkdir -p secrets

echo "Creating secret files with default passwords..."
echo 'rootpassword123' > secrets/db_root_password.txt
echo 'userpassword123' > secrets/db_password.txt
echo 'adminpassword123' > secrets/wp_admin_password.txt
echo 'editorpassword123' > secrets/wp_user_password.txt

echo "Setting permissions..."
chmod 600 secrets/*.txt

echo "✅ Secrets created successfully!"
echo ""
echo "⚠️  IMPORTANT: Change these default passwords in production!"
echo "Files created:"
ls -lh secrets/*.txt
