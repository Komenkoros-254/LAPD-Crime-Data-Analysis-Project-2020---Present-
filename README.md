# LAPD Crime Data Analysis Project (2020 - Present)

![SQL](https://img.shields.io/badge/Language-SQL-blue.svg)
![PostgreSQL](https://img.shields.io/badge/Database-PostgreSQL-elephant.svg)
![pgAdmin](https://img.shields.io/badge/Tools-pgAdmin4-red.svg)

## 📋 Project Overview
This project focuses on extracting tactical public safety insights from the official **Los Angeles Police Department (LAPD) Crime Data dataset**. By building a structured relational database schema within PostgreSQL, the analytical framework transitions raw incident logs into actionable intelligence across five critical dimensions: baseline threat profiling, environmental vulnerabilities, temporal patterns, victim demographics, and operational efficiency metrics.

---

## 📖 Read the Full Analysis on Medium
I have published a detailed breakdown of the strategic and public-policy questions this analysis solves. 
🔗 **[Read the full article on Medium](PASTE_YOUR_MEDIUM_STORY_LINK_HERE)**

---

## ❓ Analytical Questions Addressed
The structured SQL script in this repository solves five fundamental public safety concerns:
1. **Baseline Threat Profile:** Identifying the most frequent city-wide offenses and their proportional severity share.
2. **Structural Vulnerabilities:** Mapping geographic hotspots and identifying the top 3 weapons utilized across different types of premises.
3. **Temporal Vulnerabilities:** Profiling high-risk time windows, day-of-week fluctuations, and calculating weekend crime surges.
4. **Target Demographic Profiling:** Analyzing how age and biological sex exposure varies across specific crime codes and environments.
5. **Operational Pipeline Efficiency:** Tracking case arrest/closure rates, reporting delays (lags), and identifying unresolved active investigation backlogs.

---

## 📁 Repository Structure
* `lapd_crime_analysis.sql`: The complete, production-ready PostgreSQL script containing the schema initialization (`CREATE TABLE`) and all 13 analytical queries organized by section.
* `README.md`: Project documentation.

---

## 🛠️ Getting Started / How to Use
1. **Download the Dataset:** Obtain the raw source data from the [LA City Open Data Portal](https://data.lacity.org/).
2. **Initialize Schema:** Run the first block of `lapd_crime_analysis.sql` in pgAdmin or your preferred PostgreSQL CLI to create the `lapd_crime_data` table.
3. **Import Data:** Use the pgAdmin Import/Export tool or the SQL `COPY` command to map your downloaded CSV columns into the structured schema.
4. **Execute Queries:** Run the documented queries sequentially to generate the statistical backend reporting.

---

## 🔍 Technologies Used
* **Database Engine:** PostgreSQL
* **Interface Tool:** pgAdmin 4
* **Core SQL Concepts:** Common Table Expressions (CTEs), Window Functions (`RANK()`, `SUM() OVER()`), Timestamp Manipulation, Conditional Aggregations (`CASE WHEN`), String Formatting, and Data Type Casting.
