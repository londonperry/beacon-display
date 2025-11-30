# Phase 2: Azure Configuration

> **Audience**: Azure administrators and enterprise IT staff
> **Duration**: 2 hours
> **Prerequisites**: Azure account with admin access, Power BI Pro or Premium
> **After This Phase**: You'll have Azure credentials to use in Phase 3

---

## Objective

Create an Azure service principal (app identity) and configure Power BI workspace permissions so the BEACON token service can generate embed tokens.

**Key Outcomes**:
- Azure service principal with client secret
- Power BI workspace configured
- IDs needed for display client configuration

---

## Step 1: Create Azure Service Principal

### 1.1 Go to Azure Portal

1. Open [portal.azure.com](https://portal.azure.com)
2. Search for **Azure Active Directory** or **Entra ID**
3. Click **App registrations**

### 1.2 Create New Registration

1. Click **+ New registration**
2. Fill in details:
   - **Name**: `BEACON-Display-POC`
   - **Account type**: Single tenant
3. Click **Register**

### 1.3 Record Application IDs

On the app overview page, record these values:

```
├─ Application (client) ID:      ____________________
└─ Directory (tenant) ID:        ____________________
```

**Save these** - you'll need them in Phase 3.

---

## Step 2: Create Client Secret

### 2.1 Navigate to Secrets

1. In your app registration, click **Certificates & secrets** (left sidebar)
2. Click **Client secrets** tab
3. Click **+ New client secret**

### 2.2 Create Secret

1. Fill in:
   - **Description**: `BEACON POC Secret`
   - **Expires**: 12 months
2. Click **Add**

### 2.3 Record Secret Value

⚠️ **IMPORTANT**: Copy the secret **Value** column immediately. You cannot view it again!

```
Client Secret: ____________________
```

**⚠️ Never share this secret or commit it to Git**

---

## Step 3: Configure Power BI

### 3.1 Enable Service Principals

1. Go to [app.powerbi.com](https://app.powerbi.com)
2. Click **Settings** (gear icon, top right)
3. Select **Admin portal**
4. Go to **Tenant settings**
5. Find **Developer settings** section
6. Enable **"Service principals can use Power BI APIs"**
7. Click **Apply**

### 3.2 Assign to Entire Organization (or specific group)

- **Option A**: Apply to entire organization (simplest for POC)
- **Option B**: Apply to specific security group (production)

For POC, choose **Option A**: Apply to entire organization

---

## Step 4: Create or Select Power BI Workspace

### 4.1 Create New Workspace

1. In Power BI, click **Workspaces** (left sidebar)
2. Click **+ New workspace**
3. Name: `BEACON-Test` (or your preference)
4. Click **Save**

### 4.2 OR Select Existing Workspace

If you have an existing workspace:
1. Go to **Workspaces**
2. Select the workspace where your reports are
3. Continue to Step 5

**Note**: Cannot use "My Workspace" - must be a shared workspace

---

## Step 5: Add Service Principal to Workspace

### 5.1 Open Workspace

1. Go to your `BEACON-Test` workspace (or existing workspace)
2. Click **...** (three dots, top right)
3. Select **Workspace access**

### 5.2 Add Service Principal

1. Click **+ Add**
2. Search for app name: `BEACON-Display-POC`
3. Select it (it shows as an app, not a user)
4. Set role to **Member**
5. Click **Add**

**Role Explanation**:
- **Admin**: Can configure workspace (not needed)
- **Member**: Can view and embed reports (what we need)
- **Contributor**: Can edit reports (not needed)
- **Viewer**: Read-only, cannot embed (won't work)

---

## Step 6: Find Workspace and Report IDs

### 6.1 Get Workspace ID

1. Open your workspace in Power BI
2. Look at the URL:
   ```
   https://app.powerbi.com/groups/{THIS-IS-GROUP-ID}/dashboards
   ```
3. Copy the ID between `/groups/` and `/dashboards`

```
Group ID (Workspace ID): ____________________
```

### 6.2 Get Report ID

1. Open the report you want to display
2. Look at the URL:
   ```
   https://app.powerbi.com/groups/{...}/reports/{THIS-IS-REPORT-ID}/...
   ```
3. Copy the ID between `/reports/` and the next `/`

```
Report ID: ____________________
```

---

## Step 7: API Permissions

### 7.1 Add API Permissions

1. Go back to your app registration in Azure
2. Click **API permissions** (left sidebar)
3. Click **+ Add a permission**
4. Search for **Power BI Service**
5. Select it from the list
6. Click **Application permissions**
7. Check **Report.Read.All** (read-only permission)
8. Click **Add permissions**

### 7.2 Grant Admin Consent

1. In **API permissions**, look for your Power BI permission
2. Click **Grant admin consent for [Tenant Name]**
3. Confirm

**Note**: This requires Azure admin access. If you don't have this permission, contact your Azure administrator.

---

## What You've Accomplished

After Phase 2, you have:

✅ Azure service principal created
✅ Client secret generated
✅ Power BI APIs enabled
✅ Workspace created (or selected)
✅ Service principal added as Member
✅ API permissions configured
✅ All IDs recorded

---

## Summary: Credentials Table

Create a secure document with these values (you'll use them in Phase 3):

```
TENANT_ID:          ____________________
CLIENT_ID:          ____________________
CLIENT_SECRET:      ____________________
GROUP_ID:           ____________________
REPORT_ID:          ____________________
```

**⚠️ SECURITY WARNING**:
- Never commit credentials to Git
- Never share CLIENT_SECRET
- Store in secure location (password manager, Key Vault for production)
- Rotate CLIENT_SECRET every 12 months (set calendar reminder)

---

## Troubleshooting Phase 2

### "Service principals can use Power BI APIs" not showing

**Cause**: Power BI license or region limitation
**Solution**:
1. Verify you have Power BI Premium capacity (not just Pro)
2. Check admin portal access
3. Contact Power BI admin if setting doesn't appear

### Can't find app in workspace access dialog

**Cause**: App not yet available
**Solution**:
1. Wait 5-10 minutes after creation
2. Refresh browser
3. Try searching for Client ID instead of app name

### Report ID not found in URL

**Cause**: Looking at dashboard instead of report
**Solution**:
1. Open a **Report** (not a Dashboard)
2. Reports have `/reports/` in the URL
3. Dashboards use `/dashboards/` (different format)

### "Grant admin consent" button missing

**Cause**: You don't have admin permissions
**Solution**:
1. Contact your Azure administrator
2. Ask them to grant admin consent for this app
3. Provide them the app name: `BEACON-Display-POC`

---

## Next Phase

Once you have all credentials, continue to [Phase 3: Token Service Setup](token-service.md).

---

## Related Documentation

- **[Setup Overview](README.md)** - All setup phases
- **[Token Service Setup](token-service.md)** - Phase 3: Use these credentials
- **[Architecture: Authentication](../architecture/authentication.md)** - How authentication works
- **[Configuration Reference](configuration-reference.md)** - Config schema
- **[Security Model](../architecture/security-model.md)** - Security implications
