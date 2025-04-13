#!/bin/bash

# Navigate to the project directory
cd "$(dirname "$0")"

# Check if Tuist is installed
if command -v tuist &> /dev/null; then
    echo "Generating Xcode project with Tuist..."
    tuist generate
    
    # Run tests using xcodebuild
    echo "Running tests..."
    xcodebuild test -project Kalends.xcodeproj -scheme KalendsTests -destination 'platform=macOS'
else
    echo "Tuist not found. Adding test target to Xcode project manually..."
    
    # Use xcodebuild to add a test target
    # This is a simplified approach, actual implementation may require more steps
    
    # First check if the test target already exists
    if ! xcodebuild -list -project Kalends.xcodeproj | grep -q KalendsTests; then
        echo "Adding KalendsTests target to Xcode project..."
        
        # Create a new test target
        xcodebuild -project Kalends.xcodeproj -target Kalends -scheme Kalends test
        
        echo "Test target created. You may need to add the test files to the target in Xcode."
    else
        echo "Test target already exists. Running tests..."
        xcodebuild test -project Kalends.xcodeproj -scheme KalendsTests -destination 'platform=macOS'
    fi
fi

# Check the test results
if [ $? -eq 0 ]; then
    echo "All tests passed!"
else
    echo "Some tests failed."
    exit 1
fi 