#!/bin/bash
echo "[*] Installing dcmtk..."
apt install dcmtk -y

echo "[*] Downloading base DICOM file..."
wget https://github.com/darcymason/pydicom/raw/main/pydicom/data/test_files/CT_small.dcm -O base.dcm

echo "[*] Creating patient files..."
cp base.dcm patient_smith.dcm
dcmodify -m "PatientName=Smith^John^A" -m "PatientID=MRN-00234" -m "PatientBirthDate=19850312" -m "PatientSex=M" -m "StudyDescription=Chest CT" patient_smith.dcm

cp base.dcm patient_johnson.dcm
dcmodify -m "PatientName=Johnson^Mary^E" -m "PatientID=MRN-00891" -m "PatientBirthDate=19721105" -m "PatientSex=F" -m "StudyDescription=Brain MRI" patient_johnson.dcm

cp base.dcm patient_williams.dcm
dcmodify -m "PatientName=Williams^Robert^C" -m "PatientID=MRN-01122" -m "PatientBirthDate=19600824" -m "PatientSex=M" -m "StudyDescription=Abdominal CT" patient_williams.dcm

cp base.dcm patient_davis.dcm
dcmodify -m "PatientName=Davis^Patricia^L" -m "PatientID=MRN-01567" -m "PatientBirthDate=19950417" -m "PatientSex=F" -m "StudyDescription=Knee X-Ray" patient_davis.dcm

cp base.dcm patient_martinez.dcm
dcmodify -m "PatientName=Martinez^Carlos^M" -m "PatientID=MRN-02034" -m "PatientBirthDate=19781230" -m "PatientSex=M" -m "StudyDescription=Chest X-Ray" patient_martinez.dcm

echo "[*] Uploading all patients to Orthanc..."
for f in patient_*.dcm; do
  echo "Uploading $f..."
  storescu localhost 4242 $f
done

echo "[*] Cleaning up base file..."
rm base.dcm

echo "[+] Verifying uploads..."
curl http://localhost:8042/patients

echo "[+] Done! Check http://localhost:8042 to confirm all 5 patients appear."
