#!/bin/bash
# Test runner script for tutorial persistence tests

echo "Running Tutorial Persistence Tests..."
echo ""

# Check if godot is available
if ! command -v godot &> /dev/null; then
    echo "Error: godot command not found"
    echo "Please ensure Godot is installed and in your PATH"
    exit 1
fi

# Run the test scene
godot --headless tests/test_tutorial_persistence.tscn

exit_code=$?

if [ $exit_code -eq 0 ]; then
    echo ""
    echo "Tests completed successfully!"
else
    echo ""
    echo "Tests failed with exit code: $exit_code"
fi

exit $exit_code
