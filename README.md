# vSphere Inventory for Sizing Script

## Description

`vsphere-inventory-for-sizing.ps1` is a PowerShell script designed to connect to a VMware vCenter Server and gather inventory information as well as performance statistics for virtual machines (VMs). The primary purpose of this script is to collect data that can be used for infrastructure sizing exercises, capacity planning, or performance assessments.

The script retrieves key details for each VM, including:
*   VM Name
*   Cluster
*   Host
*   Power State
*   Number of vCPUs
*   Assigned vRAM (GB)
*   Used Storage Space (GB)
*   Provisioned Storage Space (GB)
*   CPU Usage Statistics (Average, Maximum, Minimum over a defined period)
*   Memory Usage Statistics (Average, Maximum, Minimum over a defined period)

This information is then exported to a CSV file for further analysis.

## Configuration

The script requires several variables to be configured before execution. These are found at the beginning of the `vsphere-inventory-for-sizing.ps1` file:

*   `$VIServer`: (String) The IP address or hostname of your vCenter Server.
    *   Example: `$VIServer = "vcsa.mydomain.local"`
*   `$VIUsername`: (String) The username for connecting to vCenter Server.
    *   Example: `$VIUsername = "administrator@vsphere.local"`
*   `$VIPassword`: (String) The password for the specified user.
    *   Example: `$VIPassword = "YourSecurePassword!"`
*   `$statsdays`: (Integer) The number of past days for which to collect performance statistics.
    *   Default: `30`
*   `$statsinterval`: (Integer) The interval in minutes at which performance metrics were sampled by vCenter (and how granular the query will be).
    *   Default: `30`

**Important Security Note:**
Hardcoding credentials (`$VIUsername` and especially `$VIPassword`) directly in scripts is generally discouraged for production environments due to security risks. Consider using PowerShell credential management cmdlets (e.g., `Get-Credential`), secure vault solutions, or service accounts with limited permissions where appropriate.

## Prerequisites

To use this script, the following prerequisites must be met:

*   **VMware PowerCLI:** The machine executing the script must have VMware PowerCLI installed. PowerCLI provides the PowerShell cmdlets necessary to interact with vSphere components (like `Connect-VIServer`, `Get-VM`, `Get-Stat`, etc.).
    *   You can typically install it from the PowerShell Gallery: `Install-Module -Name VMware.PowerCLI -Scope CurrentUser`

## Usage

1.  **Configure Variables:** Open the `vsphere-inventory-for-sizing.ps1` script in a text editor and modify the configuration variables at the beginning of the file as described in the "Configuration" section.
2.  **Open PowerShell:** Launch a PowerShell console.
3.  **Navigate to Script Directory:** Change to the directory where you saved the script.
    *   Example: `cd C:\Scripts`
4.  **Execute Script:** Run the script.
    *   Example: `.+sphere-inventory-for-sizing.ps1`
5.  **Output:** The script will display progress messages in the console as it connects to vCenter, retrieves VM information, and gathers statistics. Upon completion, it will generate a CSV file named `VMs.csv` in the `C:\` directory (by default). This file contains the collected inventory and performance data.

    *Note: The output path `C:\VMs.csv` is currently hardcoded in the script. You may wish to modify this path within the script if needed.*

## Script Optimizations

This script has been optimized for better performance and efficiency:

*   **Efficient Statistic Collection:** It now retrieves both CPU and memory statistics for each VM in a single operation, reducing the number of calls to vCenter.
*   **Improved Data Handling:** Uses a more efficient method for accumulating VM data in memory before export, which is beneficial when dealing with a large number of VMs.
*   **Resilient Error Handling:** If statistics for a specific VM cannot be fetched, the script logs the issue and continues with other VMs, ensuring that an error with one VM does not halt the entire process.
