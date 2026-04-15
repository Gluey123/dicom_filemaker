# DICOM Setup — CPTC Tryout

## Usage
```bash
curl -sSL https://raw.githubusercontent.com/YOUR_USERNAME/dicom-setup/main/setup.sh | sudo bash
```

## What it does
1. Installs Orthanc DICOM server
2. Misconfigures it intentionally (no auth, remote access open)
3. Generates 5 fake patient DICOM files with realistic PHI
4. Uploads all files to Orthanc automatically

## Intended vulns
- Port 8042: Orthanc web UI with default creds (orthanc:orthanc)
- Port 8042: REST API fully open with no authentication
- Port 4242: DICOM protocol open with no auth
- Patient data accessible via /patients /studies /instances endpoints

## After setup verify with
```bash
curl http://localhost:8042/patients
```
