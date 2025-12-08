# Tubes-Kelompok-18
# Data Mart - [Akademik]
Tugas Besar Pergudangan Data - Kelompok [18]
## Team Members
- 123450032 - Aditya Taufiqurrohman (Leader)
- 123450020 - Keren Marito (Member)
- 123450089 - Lia Hana Ichisasmita (Member)

## Project Description
Proyek ini membangun Data Mart Akademik untuk mendukung analisis data mahasiswa pada Biro Akademik. Lingkup pekerjaan meliputi identifikasi kebutuhan bisnis, pemodelan dimensional, perancangan tabel fakta dan dimensi, serta penyusunan KPI berdasarkan dataset dummy mahasiswa.

## Business Domain
Unit bisnis yang dianalisis adalah Biro Akademik, yang bertanggung jawab pada pengelolaan data operasional mahasiswa seperti:
* pencatatan identitas,
* verifikasi dan pemutakhiran data,
* pengelolaan status akademik,
* perhitungan nilai dan IPK,
* penyediaan laporan untuk fakultas, program studi, dan pimpinan institut.


## Architecture
- Approach: Kimball/Inmon/Data Vault
- Platform: SQL Server on Azure VM
- ETL: SSIS

## Key Features
- Fact tables: Fact_KinerjaSemester (Nilai, IPK, SKS Lulus, Status Lulus, Probation Flag)
  
- Dimension tables:
  1. Dimensi Mahasiswa (Dim_Mahasiswa)
  2. Dimensi Program Studi (Dim_ProgramStudi)
  3. Dimensi Fakultas (Dim_Fakultas)
  4. Dim_Waktu (Semester)
  5. Dim_StatusAkademik
  6. Dim_Kinerja
     
- KPIs:
  * KPI-1: IPK Rata-rata per Program Studi
  * KPI-2: Tingkat Kelulusan Mata Kuliah (Pass Rate)
  * KPI-3: Persentase Mahasiswa Probation
  * KPI-4: Predikat Nilai berdasarkan IPK


## Documentation
- [Business Requirements](docs/01-requirements/)
- [Design Documents](docs/02-design/)

## Timeline
- Misi 1: [17/11/2025]
- Misi 2: [24/11/2025]
- Misi 3: [01/12/2025]
- Final Mission: [08/12/2025]
