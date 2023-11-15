# DumpDC
DumpDC is a batch script designed for gathering group policies and password hashes from a Windows Domain Controller. This script consolidates the collected information into a single file for analysis. It is crucial to run this script with Domain Administrator privileges on a Domain Controller.

## Version
1.0.3

## Usage
1. Execute the script on a Domain Controller with elevated privileges.
2. Follow on-screen prompts to choose the type of dump (Group Policies or Password Hashes).
3. Optionally, select whether to delete the script after completion.
## Features
**Zero-Trust Security Model:** Assumes no default trust for users or devices.  
**Group Policy Information Dump:** Gathers and saves group policies, including detailed reports, disabled policies, and unlinked policies.  
**Password Hash Dump (Optional):** Utilizes ntdsutil to extract password hashes if selected by the user.  
**Cleanup Option:** Choose whether to automatically delete the script after execution.  
**Log File:** Generates a log file (DumpDC-%COMPUTERNAME%.log) capturing script execution details.
## Requirements
**GPMC (Group Policy Management Console):** The script checks for GPMC installation and exits if not found.  
**7-Zip:** Used for compressing the collected data into a ZIP file.  
**ntdsutil:** Required for password hash extraction.
## Warning
Running DumpDC may temporarily impact system performance.  
Ensure proper permissions and run on a secure environment.  
## Instructions
1. Clone or download the script to the Domain Controller.
2. Execute the script with elevated privileges.
1. Follow on-screen prompts to customize the dump.
1. Review the generated log file (DumpDC-%COMPUTERNAME%.log) for details.
1. Check the compressed results in DumpIT-%COMPUTERNAME%.zip.  
## Cleanup (Optional)
If selected during execution, the script will delete itself after completion.
## Disclaimer.
Use this script responsibly and adhere to security best practices.
Review the log file for any errors or issues during execution.
The script is provided as-is, without warranties.
**Note: It is recommended to understand the implications of extracting password hashes and adhere to legal and ethical guidelines when using this script.**
