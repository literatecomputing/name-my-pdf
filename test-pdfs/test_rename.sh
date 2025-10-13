#!/usr/bin/env bash
# Simple test script to validate PDF renaming
# Tests the actual PDFs in test-pdfs/ directory with real API calls

set -e  # Exit on error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENT_DIR="$(dirname "$SCRIPT_DIR")"
TEST_DIR="$SCRIPT_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Function to print test results
print_result() {
  local test_name="$1"
  local expected="$2"
  local actual="$3"
  local status="$4"
  
  TESTS_RUN=$((TESTS_RUN + 1))
  
  if [[ "$status" == "PASS" ]]; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
    echo -e "${GREEN}✓${NC} $test_name"
    echo -e "  Expected: ${BLUE}$expected${NC}"
    echo -e "  Got:      ${BLUE}$actual${NC}"
  elif [[ "$status" == "EXPECTED_FAIL" ]]; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
    echo -e "${YELLOW}✓${NC} $test_name ${YELLOW}(expected failure)${NC}"
    echo -e "  Expected: ${BLUE}$expected${NC}"
    echo -e "  Got:      ${BLUE}$actual${NC}"
  else
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo -e "${RED}✗${NC} $test_name"
    echo -e "  Expected: ${BLUE}$expected${NC}"
    echo -e "  Got:      ${RED}$actual${NC}"
  fi
  echo
}

# Setup: Create temp directory and copy test PDFs
setup() {
  echo -e "${BLUE}=== Setting up test environment ===${NC}"
  TEMP_DIR=$(mktemp -d)
  echo "Test directory: $TEMP_DIR"
  
  # Copy test PDFs to temp directory
  cp "$TEST_DIR"/*.pdf "$TEMP_DIR/" 2>/dev/null || true
  
  # Create a temporary config with known settings
  export HOME_BACKUP="$HOME"
  export HOME="$TEMP_DIR"
  
  cat > "$TEMP_DIR/.namemypdfrc" <<EOF
CROSSREF_EMAIL=jay@literatecomputing.com
DOWNCASE_TITLE=false
TITLE_WORDS=7
TITLE_WORD_SEPARATOR=" "
AUTHOR_YEAR_SEPARATOR=" "
YEAR_TITLE_SEPARATOR=" - "
USE_ABBR_TITLE=false
STRIP_TITLE_POST_COLON=true
DEBUG=false
LOG=true
EOF
  
  echo -e "${GREEN}Setup complete${NC}\n"
}

# Teardown: Clean up temp directory
teardown() {
  echo -e "\n${BLUE}=== Cleaning up ===${NC}"
  export HOME="$HOME_BACKUP"
  rm -rf "$TEMP_DIR"
  echo -e "${GREEN}Cleanup complete${NC}\n"
}

# Test function: Run script and check output
test_pdf_rename() {
  local pdf_file="$1"
  local expected_prefix="$2"
  local should_fail="${3:-false}"
  local test_name="$4"
  
  cd "$TEMP_DIR"
  
  # Capture output
  output=$("$PARENT_DIR/normalize_filename.sh" "$pdf_file" 2>&1 || true)
  
  # Check if expected file exists or expected error occurred
  if [[ "$should_fail" == "true" ]]; then
    # This test should produce an error message
    if echo "$output" | grep -q "$expected_prefix"; then
      print_result "$test_name" "Error message containing: $expected_prefix" "$(echo "$output" | grep "$expected_prefix")" "EXPECTED_FAIL"
    else
      print_result "$test_name" "Error message containing: $expected_prefix" "$output" "FAIL"
    fi
  else
    # This test should successfully rename the file
    # Find the renamed file by looking for files starting with expected prefix
    renamed_file=$(ls "${expected_prefix}"*.pdf 2>/dev/null | head -1 || true)
    
    if [[ -n "$renamed_file" ]]; then
      print_result "$test_name" "File starting with: ${expected_prefix}" "$renamed_file" "PASS"
    else
      actual_files=$(ls *.pdf 2>/dev/null || echo "No PDF files found")
      print_result "$test_name" "File starting with: ${expected_prefix}" "Files found: $actual_files" "FAIL"
    fi
  fi
}

# Main test execution
main() {
  echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
  echo -e "${BLUE}║        NameMyPdf Test Suite - PDF Renaming Tests      ║${NC}"
  echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}\n"
  
  setup
  
  echo -e "${BLUE}=== Running Tests ===${NC}\n"
  
  # Test 1: b.pdf - Multi-author paper (Baytiyeh & Pfaffman)
  test_pdf_rename \
    "b.pdf" \
    "Baytiyeh 2010 - Open" \
    "false" \
    "b.pdf: Multi-author paper (Baytiyeh & Pfaffman 2010)"
  
  # Test 2: s.pdf - Three authors (Schwartz, Martin, & Pfaffman)
  test_pdf_rename \
    "s.pdf" \
    "Schwartz 2005 - How" \
    "false" \
    "s.pdf: Three authors (Schwartz, Martin, & Pfaffman 2005)"
  
  # Test 3: p2.pdf - Single author (Pfaffman 2008)
  test_pdf_rename \
    "p2.pdf" \
    "Pfaffman 2008 - Transforming" \
    "false" \
    "p2.pdf: Single author (Pfaffman 2008)"
  
  # Test 4: p.pdf - Missing author in CrossRef (known issue)
  test_pdf_rename \
    "p.pdf" \
    "Failed to extract author" \
    "true" \
    "p.pdf: Missing author in CrossRef (expected failure)"
  
  teardown
  
  # Print summary
  echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
  echo -e "${BLUE}║                    Test Summary                        ║${NC}"
  echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
  echo -e "  Tests run:    ${BLUE}$TESTS_RUN${NC}"
  echo -e "  Tests passed: ${GREEN}$TESTS_PASSED${NC}"
  echo -e "  Tests failed: ${RED}$TESTS_FAILED${NC}"
  echo
  
  if [[ $TESTS_FAILED -eq 0 ]]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
    exit 0
  else
    echo -e "${RED}✗ Some tests failed${NC}"
    exit 1
  fi
}

# Run tests
main
