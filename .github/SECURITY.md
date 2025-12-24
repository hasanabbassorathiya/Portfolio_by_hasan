# 🔒 Security Guide for Public Repositories

## ✅ GitHub Secrets Are Safe

**Making your repository public will NOT expose your GitHub Secrets.**

GitHub Secrets are:
- ✅ Stored encrypted by GitHub
- ✅ Only accessible through GitHub Actions workflows
- ✅ Never exposed in code, logs, or public access
- ✅ Only visible to repository administrators

## ⚠️ What COULD Be Exposed

### 1. Hardcoded Secrets in Code
**Never do this:**
```dart
// ❌ BAD - Never commit secrets in code
final supabaseUrl = "https://your-project.supabase.co";
final apiKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...";
```

**✅ Good - Use environment variables:**
```dart
// ✅ GOOD - Use build-time constants
const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
```

### 2. Secrets in Commit History
If you previously committed secrets to git, they remain in history even after deletion.

**Check your commit history:**
```bash
# Check if secrets were ever committed
git log --all --full-history -S "your-secret-key" --source --pretty=format:"%H %s" | head -10
```

**If found, you must:**
1. Rotate/regenerate all exposed secrets
2. Consider using `git filter-branch` or BFG Repo-Cleaner to remove from history
3. Force push (⚠️ warn collaborators first!)

### 3. Secrets Printed in Workflow Logs
**Never do this:**
```yaml
# ❌ BAD - Don't print secrets
- run: echo "Key: ${{ secrets.SUPABASE_ANON_KEY }}"
```

**✅ Good - Use masked output:**
```yaml
# ✅ GOOD - GitHub automatically masks secrets in logs
- run: echo "Deployment started"  # Secrets are auto-masked
```

### 4. Service Account Files in Repository
**Never commit:**
- `hasan-abbas-portfolio-*.json` (Firebase service account)
- `.env` files
- Any file containing private keys

**Check if already committed:**
```bash
# Check if service account file is tracked
git ls-files | grep -E ".*service.*account.*\.json|hasan-abbas-portfolio.*\.json"

# Check if .env is tracked
git ls-files | grep "\.env$"
```

## 🛡️ Best Practices

### 1. Use GitHub Secrets
- Store all sensitive data in GitHub Secrets
- Reference secrets in workflows: `${{ secrets.SECRET_NAME }}`
- Never hardcode secrets in workflow files

### 2. Use .gitignore
Ensure these are in `.gitignore`:
```
.env
.env.local
*.json
!firebase.json
!package.json
hasan-abbas-portfolio-*.json
*-service-account.json
```

### 3. Use Environment Variables at Build Time
For Flutter web builds, use `--dart-define`:
```bash
flutter build web --release \
  --dart-define=SUPABASE_URL="${{ secrets.SUPABASE_URL }}" \
  --dart-define=SUPABASE_ANON_KEY="${{ secrets.SUPABASE_ANON_KEY }}"
```

### 4. Review Workflow Logs
- Check Actions logs before making repo public
- Ensure no secrets are printed
- GitHub automatically masks secrets, but be careful

### 5. Rotate Secrets Regularly
- Rotate API keys every 90 days
- Rotate service account keys if exposed
- Update GitHub Secrets after rotation

## 🔍 Pre-Public Checklist

Before making your repository public:

- [ ] Verify `.env` is in `.gitignore`
- [ ] Verify service account JSON files are in `.gitignore`
- [ ] Check commit history for exposed secrets
- [ ] Review all workflow files for hardcoded secrets
- [ ] Ensure all secrets are in GitHub Secrets (not in code)
- [ ] Test that workflows work with secrets only
- [ ] Review documentation files for exposed secrets
- [ ] Rotate any secrets that were previously committed

## 🚨 If Secrets Are Exposed

1. **Immediately rotate all exposed secrets:**
   - Generate new Supabase keys
   - Generate new Firebase service account
   - Update GitHub Secrets

2. **Remove from git history** (if committed):
   ```bash
   # Use git filter-branch or BFG Repo-Cleaner
   # ⚠️ This rewrites history - coordinate with team
   ```

3. **Monitor for unauthorized access:**
   - Check Supabase logs
   - Check Firebase usage
   - Review access logs

4. **Update documentation:**
   - Remove any exposed secrets from docs
   - Update setup guides

## 📚 Additional Resources

- [GitHub Secrets Documentation](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [OWASP Secrets Management](https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html)
- [GitHub Security Best Practices](https://docs.github.com/en/code-security)

---

**Remember:** When in doubt, rotate your secrets! 🔄

