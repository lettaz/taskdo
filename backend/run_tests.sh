#!/bin/bash

# Stop script on first error
set -e

echo "Setting up test environment..."
# Set environment variables for testing
export TESTING=True
export MONGODB_URL="mongodb://localhost:27017/taskdo_test"
export API_KEY="test_api_key_for_testing"
export SECRET_KEY="test_secret_key_for_testing"
export ACCESS_TOKEN_EXPIRE_MINUTES=60
export EMAIL_VERIFICATION_EXPIRY_HOURS=24
export RESET_PASSWORD_EXPIRY_HOURS=1

# Navigate to backend directory if not already there
cd "$(dirname "$0")"

# Run all tests
echo "Running tests..."
python -m pytest tests/ -v

# Run with coverage if coverage is installed
if command -v coverage &> /dev/null; then
    echo "Running tests with coverage..."
    coverage run -m pytest tests/
    coverage report
    coverage html  # Generate HTML report
    echo "Coverage report generated in htmlcov/ directory"
fi

echo "Tests completed!" 