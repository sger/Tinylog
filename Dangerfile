all_changed_files = (git.added_files + git.modified_files + git.deleted_files)

has_source_changes = !all_changed_files.grep(/Sources/).empty?
has_test_changes = !all_changed_files.grep(/Tests/).empty?
if has_source_changes && !has_test_changes
    warn("Library files were updated without test coverage. Please update or add tests, if possible!")
end