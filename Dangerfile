# Changed files
all_changed_files = (git.added_files + git.modified_files + git.deleted_files)

has_source_changes = !all_changed_files.grep(/Tinylog/).empty?
has_test_changes = !all_changed_files.grep(/TinylogTests/).empty?
if has_source_changes && !has_test_changes
    warn("Source files were updated without test coverage. Please update or add tests, if possible!")
end

# Pull request is too large to review
if git.lines_of_code > 600
    warn("This is a large pull request! Can you break it up into multiple smaller ones instead?")
end

# Pull request need a description
if github.pr_body.length < 15
    fail("Please provide a detailed summary in the pull request description.")
end

# Fail on TODOs in code
todoist.message = "Oops! We should not commit TODOs. Please fix them before merging."
todoist.fail_for_todos

# All pull requests should be submitted to dev/develop branch
if github.branch_for_base != "dev" && github.branch_for_base != "develop"
    warn("Pull requests should be submitted to the develop branch only.")
end

# PR is a work in progress and shouldn't be merged yet
warn "PR is classed as Work in Progress" if github.pr_title.include? "[WIP]"

# Ensure a clean commits history
if git.commits.any? { |c| c.message =~ /^Merge branch '#{github.branch_for_base}'/ }
  fail "Please rebase to get rid of the merge commits in this PR"
end

# If these are all empty something has gone wrong, better to raise it in a comment
if git.modified_files.empty? && git.added_files.empty? && git.deleted_files.empty?
  fail "This PR has no changes at all, this is likely an issue during development."
end

podfile_updated = !git.modified_files.grep(/Podfile/).empty?

# Leave warning, if Podfile changes
if podfile_updated
  warn "The `Podfile` was updated"
end

swiftlint.verbose = true
swiftlint.config_file = './.swiftlint.yml'
swiftlint.lint_files(inline_mode: true, fail_on_error: true)