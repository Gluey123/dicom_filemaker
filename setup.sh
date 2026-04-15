#!/bin/bash
echo "[*] Updating system..."
apt update && apt upgrade -y

echo "[*] Installing Orthanc..."
apt install orthanc orthanc-dicomweb python3-pip -y

echo "[*] Installing pydicom..."
pip3 install pydicom --break-system-packages

echo "[*] Configuring Orthanc to be vulnerable..."
cat > /etc/orthanc/orthanc.json << 'ORTHANCCONF'
{
  "Name" : "HospitalPACS",
  "StorageDirectory" : "/var/lib/orthanc/db",
  "RemoteAccessAllowed" : true,
  "AuthenticationEnabled" : false,
  "RegisteredUsers" : {
    "orthanc" : "orthanc"
  },
  "HttpPort" : 8042,
  "DicomPort" : 4242,
  "DicomServerEnabled" : true,
  "DicomCheckCalledAet" : false
}
ORTHANCCONF

echo "[*] Restarting Orthanc..."
systemctl enable orthanc
systemctl restart orthanc

echo "[*] Generating fake patient DICOM files..."
python3 /root/dicom-setup/generate_patients.py

echo "[*] Uploading DICOM files to Orthanc..."
for f in /root/dicom-setup/patients/*.dcm; do
  echo "Uploading $f..."
  curl -s -X POST http://localhost:8042/instances --data-binary @"$f" > /dev/null
done

echo "[+] Done! Orthanc is running at http://$(hostname -I | awk '{print $1}'):8042"
