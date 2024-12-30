# invoke_macbook_sleep_after_sometime

Script puts macbook to sleep and locks screen after some time (default, 120 seconds)

## Pre-requisite

Ensure that 'Required password after screen saver begins or display is turned off' is set to `Immediately` under System Settings > Lock Screen

## Setup

Create alias as follows in `~/.bashrc` or `~/.bash_profile` file replacing with path to script that exists:
```
alias macsleep=~/opt/mycode_public/invoke_macbook_sleep_after_sometime/main.sh
```
Ensure that we `source` the scripts above in current terminal if not restarting terminal.


## Usage

Execute when ready to sleep for default, 120s:
```
macsleep
```

To sleep for a different time period eg 10s:
```
macsleep 10
```
