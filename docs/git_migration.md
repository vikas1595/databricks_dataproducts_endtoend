# Git Migration: GitHub to Azure DevOps

## Prerequisites
- Azure DevOps project created
- Git repository created in Azure DevOps
- Local code ready to push

## Step 1: Get Azure DevOps Repository URL

### 1.1 In Azure DevOps
1. Go to your project
2. Click **Repos** → **Files**
3. Click **Clone** button
4. Copy the HTTPS URL (looks like: `https://dev.azure.com/yourorg/yourproject/_git/yourrepo`)

## Step 2: Change Git Remote

### 2.1 Check Current Remote
```bash
# Check current remote
git remote -v
```

### 2.2 Remove GitHub Remote
```bash
# Remove the existing GitHub remote
git remote remove origin
```

### 2.3 Add Azure DevOps Remote
```bash
# Add Azure DevOps as new origin
git remote add origin https://dev.azure.com/vikaspatel0221/DE/_git/cursur_de
```

### 2.4 Verify New Remote
```bash
# Verify the new remote
git remote -v
```

## Step 3: Push to Azure DevOps

### 3.1 Push All Branches
```bash
# Push main/master branch
git push -u origin main

# If you have other branches, push them too
git push origin --all
```

### 3.2 Push Tags (if any)
```bash
# Push all tags
git push origin --tags
```

## Step 4: Verify Migration

### 4.1 Check Azure DevOps
1. Go to **Repos** → **Files**
2. Verify your code is there
3. Check **Commits** to see your history

### 4.2 Update Local Settings (Optional)
```bash
# Set upstream branch
git branch --set-upstream-to=origin/main main

# Verify upstream
git branch -vv
```

## Alternative: Clone Fresh from Azure DevOps

If you prefer to start fresh:

### 1. Clone from Azure DevOps
```bash
# Clone the Azure DevOps repo
git clone https://dev.azure.com/yourorg/yourproject/_git/yourrepo

# Copy your code files to the new directory
cp -r /path/to/your/code/* ./yourrepo/

# Add, commit, and push
cd yourrepo
git add .
git commit -m "Initial commit: Data platform infrastructure"
git push -u origin main
```

## Troubleshooting

### Authentication Issues
```bash
# If you get auth errors, use Personal Access Token
# Go to Azure DevOps → User Settings → Personal Access Tokens
# Create a new token with Code (read & write) permissions
# Use the token as your password when prompted
```

### Push Rejected
```bash
# If push is rejected due to different histories
git push --force-with-lease origin main
# ⚠️ Use with caution - only if you're sure you want to overwrite
```

## Summary of Commands

```bash
# Quick migration commands
git remote remove origin
git remote add origin https://dev.azure.com/yourorg/yourproject/_git/yourrepo
git push -u origin main
```

## Next Steps After Migration

1. ✅ **Push code** to Azure DevOps
2. ✅ **Create variable group** `platform-infra-vars`
3. ✅ **Link variable group** to pipeline
4. ✅ **Run infrastructure pipeline**

Let me know when you've completed the migration and I'll help with the next steps! 🚀 

## 🎯 **Execute These Commands in Your Terminal**

### **Step 1: Check Current Remote**
```bash
<code_block_to_apply_changes_from>
```

### **Step 2: Remove GitHub Remote**
```bash
git remote remove origin
```

### **Step 3: Add Azure DevOps Remote**
```bash
git remote add origin https://dev.azure.com/vikaspatel0221/DE/_git/cursur_de
```

### **Step 4: Verify New Remote**
```bash
git remote -v
```

### **Step 5: Push to Azure DevOps**
```bash
git push -u origin main
```

## 🔐 **Authentication Required**

When you push, you'll be prompted for credentials:
- **Username**: `vikaspatel0221` (your Azure DevOps username)
- **Password**: Use a **Personal Access Token**

**To create Personal Access Token:**
1. Go to [Azure DevOps](https://dev.azure.com/vikaspatel0221/DE)
2. Click **User Settings** (top right corner)
3. Click **Personal Access Tokens**
4. Click **New Token**
5. Set **Name**: `Git Access`
6. Set **Organization**: `vikaspatel0221`
7. Set **Expiration**: Choose appropriate date
8. Set **Scopes**: Select **Code (read & write)**
9. Click **Create**
10. **Copy the token** (you won't see it again!)

## 🚀 **Complete Migration Commands**

Here's the complete sequence to run:

```bash
# Navigate to your repository directory
cd /Users/vikaspatel/repos/cursur_de

# Check current remote
git remote -v

# Remove GitHub remote
git remote remove origin

# Add Azure DevOps remote
git remote add origin https://dev.azure.com/vikaspatel0221/DE/_git/cursur_de

# Verify new remote
git remote -v

# Push to Azure DevOps (you'll be prompted for credentials)
git push -u origin main
```

## 📋 **What Happens Next:**

1. ✅ **Code pushed** to Azure DevOps repository
2. ✅ **Infrastructure pipeline triggers** automatically
3. ✅ **Creates complete data platform** using your SPN

## ❓ **Need Help?**

If you get any errors during the migration, let me know and I'll help troubleshoot. The most common issues are:
- Authentication (use Personal Access Token, not regular password)
- Remote already exists (use `git remote set-url` instead of `add`)

Let me know when you've completed the migration and I'll help with the next steps! 🚀 