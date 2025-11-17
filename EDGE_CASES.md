# Production-Readiness Edge Cases Analysis

This document identifies critical edge cases, bugs, and production-readiness issues in Pipboy.

## Critical Issues (Fix Immediately)

### 1. Symlink Path Bug in Monitor (monitor.rb:32)
**Severity: CRITICAL**

```ruby
# Current (BROKEN):
File.symlink "#{config_dir}/#{file}", path
# Should be:
File.symlink "#{config_dir}/#{File.basename(file)}", path
```

The parameter `file` is already the full expanded path. This creates a symlink pointing to the wrong location.

**Impact**: Symlinks point to incorrect paths, breaking the entire watch functionality.

**Location**: monitor.rb:32

---

### 2. Basename Collision in Inventory (inventory.rb:26)
**Severity: CRITICAL**

```ruby
files[File.basename(file)] = File.dirname(file)
```

Multiple files with the same basename from different directories will overwrite each other in the inventory.

**Example**:
```bash
pipboy watch ~/project1/.bashrc
pipboy watch ~/project2/.bashrc  # Overwrites first entry!
```

**Impact**: Data loss, inability to track multiple files with same name, restore failures.

**Location**: inventory.rb:26

---

### 3. Race Conditions in Inventory (inventory.rb)
**Severity: HIGH**

No file locking when reading/writing `pipboy.yml`. Concurrent operations will corrupt the inventory.

**Scenarios**:
- Two `pipboy watch` commands running simultaneously
- Watch and restore running at the same time
- Multiple terminal sessions

**Impact**: Inventory corruption, data loss, inconsistent state.

**Locations**:
- inventory.rb:18 (read)
- inventory.rb:27-29 (write)
- restore.rb:49-51 (write)

---

### 4. Unsafe YAML Loading (inventory.rb:18)
**Severity: HIGH (Security)**

```ruby
@files ||= File.exist?(@db) ? YAML.load_file(@db) : {}
```

Uses `YAML.load_file` which is vulnerable to arbitrary code execution if the YAML file is compromised.

**Fix**: Use `YAML.safe_load_file` with permitted classes.

**Location**: inventory.rb:18

---

## High Priority Issues

### 5. No Atomic Operations (monitor.rb:29-32)
**Severity: HIGH**

```ruby
def create_symlink_for file
  path = File.expand_path file
  FileUtils.mv path, config_dir
  File.symlink "#{config_dir}/#{file}", path
end
```

If symlink creation fails after moving the file, the original file becomes inaccessible with no rollback.

**Impact**: File loss, broken system if watching critical config files.

**Mitigation**: Implement rollback or use atomic operations.

---

### 6. No File Permission Checks
**Severity: HIGH**

No validation before:
- Moving files (requires write on source & destination)
- Creating symlinks (requires write on parent directory)
- Reading files

**Failure modes**:
```
Errno::EACCES: Permission denied
Errno::EPERM: Operation not permitted
```

**Impact**: Cryptic errors, partial operations, inconsistent state.

---

### 7. Already-Watched File Handling (monitor.rb)
**Severity: MEDIUM**

No check if file is already being watched before moving it again.

**Scenario**:
```bash
pipboy watch ~/.bashrc
pipboy watch ~/.bashrc  # Tries to watch symlink!
```

**Impact**: Watches the symlink instead of the actual file, creates nested symlinks.

---

### 8. Git Operation Error Handling (eff_key.rb)
**Severity: MEDIUM**

```ruby
def save *files
  files = files.map { |x| File.basename x }
  @g.add files
  @g.commit "Added #{files.join(', ')}"  # No error handling!
end
```

**Issues**:
- No check if commit succeeds
- Fails when there are no changes to commit
- `configure_git` silently swallows all errors with `rescue nil`

**Impact**: Silent failures, inventory and git state divergence.

**Location**: eff_key.rb:20-24

---

### 9. Symlink vs Regular File Detection (monitor.rb)
**Severity: MEDIUM**

No check if the file to watch is already a symlink.

**Impact**: Could move and create symlinks to symlinks, breaking the chain.

---

### 10. Directory Creation Race Condition (configuration.rb:11)
**Severity: MEDIUM**

```ruby
Dir.mkdir @config_dir unless File.directory?(@config_dir)
```

Classic TOCTOU (Time-of-check-time-of-use) race condition.

**Location**: configuration.rb:11

---

## Medium Priority Issues

### 11. Restore Path Assumptions (restore.rb:19)
**Severity: MEDIUM**

```ruby
original_path = File.join(original_location, basename)
```

Assumes the original directory still exists. If directory was deleted, restore fails.

**Location**: restore.rb:19

---

### 12. No Disk Space Checks
**Severity: MEDIUM**

No verification that:
- Enough space exists to move files
- Config directory won't fill up the disk

**Impact**: Disk full errors mid-operation, partial file moves.

---

### 13. Special File Types Not Handled
**Severity: MEDIUM**

No validation for:
- Directories (should files only be allowed?)
- Device files (`/dev/null`, `/dev/random`)
- Named pipes (FIFOs)
- Sockets

**Impact**: Unexpected behavior, errors.

---

### 14. File Already Exists at Target (monitor.rb:31)
**Severity: MEDIUM**

```ruby
FileUtils.mv path, config_dir
```

If a file with the same basename already exists in config_dir, `FileUtils.mv` will overwrite it without warning.

**Impact**: Silent data loss.

**Location**: monitor.rb:31

---

### 15. Symlink Verification in Restore (restore.rb:25-29)
**Severity: MEDIUM**

```ruby
if File.symlink?(original_path)
  File.unlink(original_path)
elsif File.exist?(original_path)
  raise FileExistsError
end
```

Doesn't verify the symlink points to the backed up file. Could unlink a symlink pointing elsewhere.

**Location**: restore.rb:25-29

---

### 16. Empty Inventory Edge Cases (inventory.rb:18)
**Severity: LOW**

Empty or missing inventory file returns `{}`, but malformed YAML will raise exceptions.

**Impact**: Unclear error messages.

---

### 17. Git Repository State (eff_key.rb)
**Severity: MEDIUM**

No handling for:
- Detached HEAD state
- Merge conflicts
- Dirty working tree
- Untracked git files that could conflict

**Location**: eff_key.rb

---

### 18. Concurrent Git Operations (eff_key.rb)
**Severity: MEDIUM**

Multiple pipboy operations create simultaneous git commits, which could conflict.

**Impact**: Git lock files, failed commits.

---

## Low Priority Issues

### 19. Path Validation
**Severity: LOW**

No validation for:
- Empty paths
- Paths ending in `/`
- Relative vs absolute paths (partially handled)
- `.` and `..` in paths
- Overly long paths (PATH_MAX)

---

### 20. File Ownership
**Severity: LOW**

No check if the user owns the file. Could create permission issues.

---

### 21. Character Encoding (inventory.rb)
**Severity: LOW**

No handling for:
- Non-UTF8 filenames
- Null bytes in filenames
- Unicode normalization issues

---

### 22. Resource Limits
**Severity: LOW**

No limits on:
- Number of watched files
- Total size of watched files
- Inode limits

---

### 23. Platform Compatibility
**Severity: LOW**

Assumptions:
- Unix-like filesystem (symlinks)
- `Dir.home` works (may fail in some environments)
- Hardcoded path separators

---

### 24. Error Message Quality
**Severity: LOW**

Generic errors don't provide actionable information:
```ruby
rescue => e
  say "✗ Error: #{e.message}", :red
  exit 1
end
```

**Better**: Include context, suggest fixes, log stack traces for debugging.

---

## State Consistency Issues

### 25. Git and Inventory Divergence
**Severity: MEDIUM**

If git operations fail but inventory updates succeed (or vice versa), the two get out of sync.

**Example**: Inventory says file is watched, but it's not in git.

---

### 26. No Integrity Verification
**Severity: LOW**

No checksums or verification that:
- Backed up file matches original
- Symlink points to correct location
- Inventory matches actual filesystem state

---

### 27. Partial Restore Failures (restore.rb:32)
**Severity: HIGH**

```ruby
FileUtils.mv(backed_up_file, original_path)
```

If this fails after removing the symlink, the file is lost from the original location.

**Location**: restore.rb:32

---

## Input Validation Issues

### 28. No File Type Checks (monitor.rb)
**Severity: MEDIUM**

Should validate that input is a regular file, not:
- Directory
- Symlink
- Device file
- Named pipe
- Socket

**Location**: monitor.rb:12-13

---

### 29. No Size Limits
**Severity: LOW**

Can watch arbitrarily large files, potentially:
- Filling up disk
- Causing slow git operations
- Exceeding filesystem limits

---

### 30. Tilde Expansion
**Severity: LOW**

CLI properly expands `~` with `File.expand_path`, but direct API usage might not.

---

## Recommended Fixes Priority Order

1. Fix symlink path bug (monitor.rb:32)
2. Implement inventory file locking
3. Fix basename collision with full-path keys
4. Switch to YAML.safe_load_file
5. Add atomic operations with rollback
6. Add permission checks before operations
7. Validate file types (regular files only)
8. Handle already-watched files
9. Improve git error handling
10. Add disk space checks

## Testing Recommendations

### Unit Tests Needed
- Concurrent inventory access
- Basename collisions
- Permission denied scenarios
- Disk full scenarios
- Malformed YAML
- Git operation failures

### Integration Tests Needed
- Watch same file twice
- Watch files with same basename
- Restore when directory doesn't exist
- Multiple pipboy processes simultaneously
- Symlink chains
- Very long filenames
- Special characters in filenames

### Security Tests
- YAML injection
- Path traversal attempts
- Symlink attacks
- Race conditions

## Additional Production Requirements

1. **Logging**: Add structured logging for operations
2. **Metrics**: Track success/failure rates
3. **Health checks**: Verify inventory/filesystem consistency
4. **Backup**: Backup inventory before modifications
5. **Dry-run mode**: Preview operations without executing
6. **Repair command**: Fix inconsistencies between inventory and filesystem
7. **Version migration**: Handle inventory format changes
8. **Documentation**: Error codes and troubleshooting guide
