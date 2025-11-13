# Quick Setup Guide - Jenkins CI/CD Pipeline

This is a condensed guide to get the pipeline running quickly. For detailed documentation, see [README.md](README.md).

## 🚀 Fast Track Setup (10 minutes)

### Step 1: Start Jenkins Container

```bash
# Run Jenkins with Docker support
docker run -d \
  --name jenkins \
  -p 8081:8080 \
  -p 50000:50000 \
  -v ~/jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  jenkins/jenkins:lts

# Wait for startup
sleep 30

# Get admin password
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

### Step 2: Install Tools in Jenkins

```bash
# Install uv (Python package manager)
docker exec -it jenkins bash -c "curl -LsSf https://astral.sh/uv/install.sh | sh"

# Install Python and docker-compose
docker exec -it --user root jenkins bash -c "apt-get update && apt-get install -y python3 python3-pip docker-compose"

# Fix Docker permissions
docker exec -it --user root jenkins bash -c "chmod 666 /var/run/docker.sock"

# Verify installations
docker exec -it jenkins bash -c "export PATH=\"\$HOME/.local/bin:\$PATH\" && uv --version && python3 --version && docker-compose --version"
```

### Step 3: Configure Jenkins

1. Open **http://localhost:8081**
2. Enter the admin password from Step 1
3. Click **"Install suggested plugins"**
4. Create admin user
5. Click **"New Item"**
6. Name: `CI-CD-Demo-Pipeline`
7. Type: **Pipeline**
8. Under **Pipeline** section:
   - Definition: **Pipeline script from SCM**
   - SCM: **Git**
   - Repository URL: `https://github.com/aar-rafi/api_av_pre_scen_2.git` (or your fork)
   - Branch: `*/main`
   - Script Path: `Jenkinsfile`
9. Click **"Save"**

### Step 4: Run Pipeline

1. Click **"Build Now"**
2. Watch the stages execute (should all be GREEN):
   - ✅ Checkout
   - ✅ Build
   - ✅ Test
   - ✅ Package
   - ✅ Deploy
   - ✅ Health Check
   - ✅ Display Status

3. Access the app: **http://localhost:5000**

### Step 5: Capture Deliverables

1. Click on the successful build number
2. Click **"Console Output"**
3. Take screenshots of:
   - Pipeline overview (all stages green)
   - Console output
   - Health check section
   - Final success message

---

## 🔧 Common Issues & Quick Fixes

| Issue | Quick Fix |
|-------|-----------|
| `uv: not found` | `docker exec -it jenkins bash -c "curl -LsSf https://astral.sh/uv/install.sh \| sh"` |
| Permission denied (Docker) | `docker exec -it --user root jenkins bash -c "chmod 666 /var/run/docker.sock"` |
| Container name conflict | `docker rm -f demo-app-container` |
| Port 5000 in use | Change port in `docker-compose.yml` or kill process |
| `source: not found` | Use `. .venv/bin/activate` instead of `source` |

---

## 📊 What Each Stage Does

1. **Checkout**: Pulls code from Git
2. **Build**: Validates Python files
3. **Test**: Runs pytest with uv virtual environment
4. **Package**: Builds Docker image
5. **Deploy**: Starts container with docker-compose
6. **Health Check**: Verifies app is healthy
7. **Display Status**: Shows endpoints and status

---

## 🧹 Cleanup

```bash
# Stop and remove everything
docker-compose down
docker stop jenkins
docker rm jenkins
docker rmi demo-app:latest demo-app:1.0.0
docker volume rm jenkins_home
```

---

## 📝 Deliverables Checklist

- [ ] Screenshot: Pipeline overview (all green)
- [ ] Screenshot: Full console output
- [ ] Screenshot: Health check passing
- [ ] Screenshot: Deployment successful message
- [ ] Text file: Complete console output
- [ ] Verify app accessible at http://localhost:5000

---

## 🆘 Need Help?

- Full documentation: [README.md](README.md)
- Troubleshooting: See README.md "Troubleshooting" section
- Check logs: `docker-compose logs` or Jenkins console output
