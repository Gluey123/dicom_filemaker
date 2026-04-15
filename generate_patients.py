import pydicom
from pydicom.dataset import Dataset, FileDataset, FileMetaDataset
import pydicom.uid
import os

os.makedirs("/root/dicom-setup/patients", exist_ok=True)

patients = [
    {"name": "Smith^John^A", "id": "MRN-00234", "dob": "19850312", "sex": "M", "study": "Chest CT", "diagnosis": "Pneumonia"},
    {"name": "Johnson^Mary^E", "id": "MRN-00891", "dob": "19721105", "sex": "F", "study": "Brain MRI", "diagnosis": "Migraine"},
    {"name": "Williams^Robert^C", "id": "MRN-01122", "dob": "19600824", "sex": "M", "study": "Abdominal CT", "diagnosis": "Appendicitis"},
    {"name": "Davis^Patricia^L", "id": "MRN-01567", "dob": "19950417", "sex": "F", "study": "Knee X-Ray", "diagnosis": "Fracture"},
    {"name": "Martinez^Carlos^M", "id": "MRN-02034", "dob": "19781230", "sex": "M", "study": "Chest X-Ray", "diagnosis": "COVID-19"},
]

for i, p in enumerate(patients):
    file_meta = FileMetaDataset()
    file_meta.MediaStorageSOPClassUID = pydicom.uid.SecondaryCaptureImageStorage
    file_meta.MediaStorageSOPInstanceUID = pydicom.uid.generate_uid()
    file_meta.TransferSyntaxUID = pydicom.uid.ExplicitVRLittleEndian

    ds = FileDataset(f"patient{i+1}.dcm", {}, file_meta=file_meta, preamble=b"\0"*128)
    ds.is_little_endian = True
    ds.is_implicit_VR = False

    ds.PatientName = p["name"]
    ds.PatientID = p["id"]
    ds.PatientBirthDate = p["dob"]
    ds.PatientSex = p["sex"]
    ds.StudyDescription = p["study"]
    ds.AdditionalPatientHistory = p["diagnosis"]
    ds.InstitutionName = "General Hospital"
    ds.SOPClassUID = pydicom.uid.SecondaryCaptureImageStorage
    ds.SOPInstanceUID = file_meta.MediaStorageSOPInstanceUID

    out = f"/root/dicom-setup/patients/patient{i+1}.dcm"
    pydicom.dcmwrite(out, ds)
    print(f"[+] Created {out} — {p['name']} ({p['id']})")

print("[+] All patient files generated.")
