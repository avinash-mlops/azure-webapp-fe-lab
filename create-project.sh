mkdir -p public tests

cat > package.json <<'EOF'
{
  "name": "azure-webapp-fe-lab",
  "version": "1.0.0",
  "description": "Azure App Service Frontend Lab",
  "main": "server.js",
  "scripts": {
    "start": "node server.js",
    "dev": "node --watch server.js"
  },
  "engines": {
    "node": ">=20"
  },
  "dependencies": {
    "express": "^5.1.0"
  }
}
EOF

cat > server.js <<'EOF'
const express = require('express');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.static(path.join(__dirname, 'public')));

app.get('/health', (req, res) => {
  res.json({ status: 'healthy' });
});

app.listen(PORT, () => {
  console.log(`App running on port ${PORT}`);
});
EOF

cat > public/index.html <<'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Azure Frontend Lab</title>
  <style>
    body {
      margin: 0;
      font-family: Arial, sans-serif;
      color: white;
      background: #102b50;
    }
    header {
      padding: 20px 8%;
      background: #091b32;
    }
    .hero {
      min-height: 75vh;
      padding: 80px 8%;
      display: flex;
      align-items: center;
      background: linear-gradient(120deg, #16466d, #397b72);
    }
    .content { max-width: 650px; }
    h1 { font-size: clamp(40px, 6vw, 68px); }
    p { font-size: 19px; line-height: 1.7; }
    button {
      background: #1687d9;
      color: white;
      border: 0;
      padding: 14px 24px;
      border-radius: 6px;
      cursor: pointer;
    }
    footer {
      padding: 25px;
      text-align: center;
      background: #091b32;
    }
  </style>
</head>
<body>
  <header><h2>Azure Frontend Lab</h2></header>
  <section class="hero">
    <div class="content">
      <h1>Build. Deploy. Learn.</h1>
      <p>Welcome to my Azure App Service frontend lab.
      Learn Node.js, Azure DevOps and CI/CD deployment.</p>
      <button onclick="checkHealth()">Check Application Health</button>
      <p id="status">Application ready.</p>
    </div>
  </section>
  <footer>Azure Web App Frontend Lab | DevOps Practice</footer>
  <script>
    async function checkHealth() {
      const response = await fetch('/health');
      const data = await response.json();
      document.getElementById('status').textContent =
        'Application status: ' + data.status;
    }
  </script>
</body>
</html>
EOF

cat > .gitignore <<'EOF'
node_modules/
.env
.env.*
.DS_Store
npm-debug.log*
EOF

cat > README.md <<'EOF'
# Azure Web App Frontend Lab

A simple Node.js and Express application for learning
Azure App Service and Azure DevOps CI/CD.

## Run locally

npm install
npm start

Open http://localhost:3000

Health endpoint: http://localhost:3000/health

## Deployment

Target: Azure App Service Linux
Runtime: Node.js
Startup command: npm start

Never commit secrets or .env files.
EOF

cat > azure-pipelines.yml <<'EOF'
trigger:
  - main

pool:
  vmImage: ubuntu-latest

steps:
  - task: UseNode@1
    inputs:
      version: '22.x'
    displayName: Use Node.js

  - script: npm ci
    displayName: Install dependencies

  - script: node --check server.js
    displayName: Validate application

  - task: ArchiveFiles@2
    inputs:
      rootFolderOrFile: '$(Build.SourcesDirectory)'
      includeRootFolder: false
      archiveType: zip
      archiveFile: '$(Build.ArtifactStagingDirectory)/frontend.zip'
      replaceExistingArchive: true

  - task: PublishPipelineArtifact@1
    inputs:
      targetPath: '$(Build.ArtifactStagingDirectory)/frontend.zip'
      artifact: frontend-app
EOF
