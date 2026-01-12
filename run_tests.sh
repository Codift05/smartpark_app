#!/usr/bin/env bash
# Test Runner Script untuk SmartPark App

echo "🧪 SmartPark App - Test Runner"
echo "=============================="
echo ""

case "$1" in
  "all")
    echo "▶️  Running ALL tests..."
    flutter test
    ;;
  
  "auth")
    echo "▶️  Running AUTHENTICATION tests..."
    flutter test test/auth_test.dart --verbose
    ;;
  
  "parking")
    echo "▶️  Running PARKING STATUS tests..."
    flutter test test/parking_test.dart --verbose
    ;;
  
  "payment")
    echo "▶️  Running PAYMENT tests..."
    flutter test test/payment_test.dart --verbose
    ;;
  
  "coverage")
    echo "▶️  Running tests with COVERAGE..."
    flutter test --coverage
    echo ""
    echo "✅ Coverage report generated in coverage/lcov.info"
    ;;
  
  "watch")
    echo "▶️  Running tests in WATCH mode..."
    flutter test --watch
    ;;
  
  *)
    echo "❌ Usage: ./run_tests.sh [command]"
    echo ""
    echo "Available commands:"
    echo "  all       - Run all tests"
    echo "  auth      - Run authentication tests"
    echo "  parking   - Run parking status tests"
    echo "  payment   - Run payment tests"
    echo "  coverage  - Run tests with coverage"
    echo "  watch     - Run tests in watch mode"
    echo ""
    echo "Example: ./run_tests.sh all"
    exit 1
    ;;
esac

echo ""
echo "✅ Test execution complete!"
