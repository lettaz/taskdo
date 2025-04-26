# Testing Documentation

This document describes the testing setup for the TaskDo API.

## Test Structure

- `conftest.py`: Contains test fixtures and setup for all tests
- `test_auth.py`: Tests for user authentication (register, login, email verification, password reset)
- `test_projects.py`: Tests for project management
- `test_tasks.py`: Tests for task management
- `test_tags.py`: Tests for tag management
- `test_pomodoro.py`: Tests for Pomodoro timer functionality
- `test_main.py`: Tests for main application endpoints and configuration

## Running Tests

You can run the tests using the provided script:

```bash
./run_tests.sh
```

Or directly with pytest:

```bash
cd backend
export TESTING=True
export MONGODB_URL="mongodb://localhost:27017/taskdo_test"
pytest -v
```

## Test Database

The tests use a separate test database (`taskdo_test`) to avoid interfering with the development or production database. The test database is automatically set up and cleaned between test runs.

## Test Coverage

To generate a test coverage report:

```bash
cd backend
coverage run -m pytest
coverage report
coverage html  # Generates HTML report in htmlcov/
```

## Writing New Tests

When adding new API features, please follow these guidelines:

1. Create new test functions in the appropriate test module
2. Use the fixtures defined in `conftest.py` for common test requirements
3. Follow the existing test patterns for consistency
4. Ensure all test functions are prefixed with `test_`
5. Use descriptive names for test functions
6. Add async marker for async test functions: `@pytest.mark.asyncio`

## Continuous Integration

These tests are designed to be run as part of a CI/CD pipeline, ensuring the API remains functional as new features are added. 