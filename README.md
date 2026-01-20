# Claude Usage Monitor (PowerShell)

A lightweight PowerShell script that monitors your Claude (Anthropic) API/Usage blocks and sends real-time notifications to your phone when you approach your credit limits.

## Features
- **Real-time Monitoring:** Checks your current cost, burn rate, and reset time.
- **Smart Alerts:** Only sends a notification if your usage has increased since the last check (prevents notification spam).
- **Lightweight:** Designed to run in the background via Windows Task Scheduler with minimal CPU/RAM impact.
- **Customizable Thresholds:** Set your own "Warning" and "Critical" percentage levels.

## Prerequisites
1. **ccusage:** This script relies on the `ccusage` CLI tool.
2. **ntfy.sh:** Install the [ntfy app](https://ntfy.sh/) on your phone (Android/iOS) and subscribe to a unique topic name.

## Installation

### 1. Script Setup
1. Download `MonitorClaude.ps1` to a permanent folder (e.g., `C:\Scripts\ClaudeMonitor`).
2. Open the script and edit the **Configuration** section:
   - `$Topic`: Your unique ntfy.sh topic name.
   - `$Threshold`: The percentage (e.g., 80) to start receiving alerts.
   - `$MaxBlockCost`: Set this to your specific block limit (e.g., 28.00).

### 2. Automate with Task Scheduler
To run this automatically every 5 minutes:
1. Open **Task Scheduler** and select **Create Task**.
2. **General Tab:** Name it "Claude Monitor" and check **Run whether user is logged on or not** and **Hidden**.
3. **Triggers Tab:** - New Trigger > **Begin the task: On a schedule**.
   - Select **One Time**.
   - Set the Start time to 2 minutes in the past.
   - Check **Repeat task every: 5 minutes** for a duration of **Indefinitely**.
4. **Actions Tab:**
   - New Action > **Start a program**.
   - Program/script: `powershell.exe`
   - Add arguments: `-ExecutionPolicy Bypass -WindowStyle Hidden -NonInteractive -File "C:\Path\To\Your\MonitorClaude.ps1"`
5. **Settings Tab:**
   - Check **Run task as soon as possible after a scheduled start is missed**.
   - Change "If the task is already running..." to **Stop the existing instance**.

## Files Created
- `debug_log.txt`: A simple text log showing every check performed.
- `last_alert.txt`: Stores the last alerted percentage to prevent duplicate notifications.

## Security Note
**Do not share your `ntfy` Topic name.** Anyone with this topic string can send notifications to your devices. This script does not require your Claude API keys directly, as it interfaces with the local `ccusage` configuration.

## License
MIT