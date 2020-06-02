all_changed_files = (git.added_files + git.modified_files + git.deleted_files)

has_source_changes = !all_changed_files.grep(/Sources/).empty?
has_test_changes = !all_changed_files.grep(/Tests/).empty?
if has_source_changes && !has_test_changes
    warn("Library files were updated without test coverage. Please update or add tests, if possible!")
end

if git.lines_of_code > 600
    warn("This is a large pull request! Can you break it up into multiple smaller ones instead?")
end

if github.pr_body.length < 15
    fail("Please provide a detailed summary in the pull request description.")
end

todoist.message = "Oops! We should not commit TODOs. Please fix them before merging."
todoist.fail_for_todos

if github.branch_for_base != "dev" && github.branch_for_base != "develop"
    warn("Pull requests should be submitted to the dev branch only.")
end

swiftlint.verbose = true
swiftlint.config_file = './.swiftlint.yml'
swiftlint.lint_files(inline_mode: true, fail_on_error: true)