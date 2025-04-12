# Contributing to better-code-blocks

Thank you for your interest in contributing to this plugin! Here's how you can help.

## Development Setup

1. Fork and clone the repository:

   ```bash
   git clone https://github.com/YOUR-USERNAME/better-code-blocks.git
   cd better-code-blocks
   ```

2. Set up your development environment:

   - Use a separate Vim/Neovim configuration for development to avoid conflicts with your everyday setup.
   - Create a minimal vimrc file for testing:
     ```vim
     " minimal_vimrc
     set nocompatible
     filetype off
     set rtp+=vader.vim
     set rtp+=.
     set rtp+=after
     filetype plugin indent on
     syntax enable
     ```

3. Install the test framework:
   ```bash
   git clone https://github.com/junegunn/vader.vim.git
   ```

## Testing Locally

This plugin uses [Vader.vim](https://github.com/junegunn/vader.vim) for testing. Tests are located in the `test/` directory.

### Running Tests

1. **Run all tests:**

   ```bash
   vim -Nu minimal_vimrc -c 'Vader! test/**/*.vader'
   ```

2. **Run specific test files:**

   ```bash
   vim -Nu minimal_vimrc -c 'Vader! test/highlighting.vader'
   ```

3. **Run tests from within Vim:**

   ```vim
   :Vader test/**/*.vader
   ```

4. **Run tests with more verbose output:**
   ```bash
   vim -Nu minimal_vimrc -c 'Vader! test/**/*.vader' -V1
   ```

### Writing Tests

Tests are written in Vader's `.vader` format. Each test typically consists of:

```vim
" Test description
Given (initial text/setup):
  " Initial text content
Do (action):
  " Commands to execute
Expect (result):
  " Expected text after transformation

Execute (script test):
  " VimScript to run
  Assert function_call() == expected_result
```

Example test case:

```vim
Execute (Test highlighting parser):
  let result = fenced_code_block#parse_highlight_attribute('1,3-5')
  AssertEqual [1, 3, 4, 5], result
```

## Code Style and Guidelines

1. Follow Vim script best practices:

   - Use `snake_case` for function and variable names
   - Prefix plugin-specific functions with `fenced_code_block#`
   - Document functions with detailed comments

2. Keep functions focused and modular

3. Add comments for complex logic or non-obvious behavior

4. Maintain backward compatibility when possible

## Pull Request Process

1. Create a new branch for your feature or fix:

   ```bash
   git checkout -b feature/your-feature-name
   ```

2. Develop and test your changes locally

3. Add or update tests for your changes

4. Update documentation (README.md, docs, etc.) as necessary

5. Push your changes to your fork and submit a pull request:

   ```bash
   git push origin feature/your-feature-name
   ```

6. In your PR description, explain:
   - What the change accomplishes
   - How it was tested
   - Any design decisions you made

## Debugging Tests

- Vader provides debugging tools:

  ```vim
  Execute:
    Log "Variable value: " . g:some_variable
    " Output will appear in test results
  ```

- Use `:VaderRepeat` to rerun the last test

- Add `BREAK` command to pause execution:

  ```vim
  Execute:
    BREAK  " Execution will stop here
  ```

- Examine state with:
  ```vim
  :echo g:vader_file g:vader_line
  :messages  " To see log output
  ```

## Continuous Integration

GitHub Actions automatically run tests on pull requests. The configuration is in `.github/workflows/test.yml`.

If you add new dependencies or change plugin behavior significantly, make sure the CI configuration is updated accordingly.

## Release Process

1. Update version number in relevant files
2. Update documentation with new features or changes
3. Create a detailed changelog
4. Tag the release with Git:
   ```bash
   git tag -a v1.0.0 -m "Version 1.0.0"
   git push origin v1.0.0
   ```

## Questions or Problems?

If you have questions or run into issues with the contribution process, please open an issue for discussion.

Thank you for contributing!