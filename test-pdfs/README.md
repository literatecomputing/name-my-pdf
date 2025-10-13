# Test PDFs for NameMyPdf

This directory contains test PDF files used to validate the PDF renaming functionality.

## Test Files

### ✅ Success Cases

| File       | DOI                          | Author                       | Year | Expected Behavior                                                                          |
| ---------- | ---------------------------- | ---------------------------- | ---- | ------------------------------------------------------------------------------------------ |
| **b.pdf**  | `10.1016/j.chb.2010.04.008`  | Baytiyeh & Pfaffman          | 2010 | Renames to: `Baytiyeh 2010 - Open source software.pdf`                                     |
| **s.pdf**  | `10.1207/s15327647jcd0601_5` | Schwartz, Martin, & Pfaffman | 2005 | Renames to: `Schwartz 2005 - How Mathematics Propels the Development of Physical.pdf`      |
| **p2.pdf** | `10.1353/hsj.2008.0006`      | Pfaffman                     | 2008 | Renames to: `Pfaffman 2008 - Transforming High School Classrooms with FreeOpen Source.pdf` |

### ❌ Expected Failure Cases

| File      | DOI                         | Issue                               | Expected Behavior                                       |
| --------- | --------------------------- | ----------------------------------- | ------------------------------------------------------- |
| **p.pdf** | `10.1007/s11528-007-0040-x` | Missing author in CrossRef metadata | Prints error: "Failed to extract author" and skips file |

## Running Tests

### Quick Test

```bash
./test_rename.sh
```

This will:

1. Create a temporary directory
2. Copy all test PDFs
3. Run `normalize_filename.sh` on each PDF
4. Validate the output matches expected filenames
5. Clean up temporary files

### Expected Output

```
╔════════════════════════════════════════════════════════╗
║        NameMyPdf Test Suite - PDF Renaming Tests      ║
╚════════════════════════════════════════════════════════╝

=== Running Tests ===

✓ b.pdf: Multi-author paper (Baytiyeh & Pfaffman 2010)
✓ s.pdf: Three authors (Schwartz, Martin, & Pfaffman 2005)
✓ p2.pdf: Single author (Pfaffman 2008)
✓ p.pdf: Missing author in CrossRef (expected failure)

╔════════════════════════════════════════════════════════╗
║                    Test Summary                        ║
╚════════════════════════════════════════════════════════╝
  Tests run:    4
  Tests passed: 4
  Tests failed: 0

✓ All tests passed!
```

## Test Details

Each test PDF has a corresponding `.md` file with citation information:

- `b.md` - Baytiyeh, H. & Pfaffman, J. A. (2010). Open Source Software: A Community of Altruists
- `s.md` - Schwartz, D., Martin, T., & Pfaffman, J. A. (2005). How mathematics propels the development of physical knowledge
- `p2.md` - Pfaffman, J. A. (2008) Transforming High School Classrooms with Free/Open Source Software
- `p.md` - Pfaffman, J. A. (2007). It's Time to Consider Open Source Software (CrossRef has incomplete metadata)

## Adding New Tests

To add a new test case:

1. Add a PDF file to this directory
2. Create a corresponding `.md` file with the citation
3. Update `test_rename.sh` to include the new test
4. Run `./test_rename.sh` to verify

## Notes

- Tests make **real API calls** to CrossRef, so an internet connection is required
- The test uses a temporary configuration file with standard settings (TITLE_WORDS=7, etc.)
- All tests run in isolation in a temporary directory to avoid modifying the original PDFs
- The `p.pdf` test validates error handling for incomplete CrossRef metadata
