# SpotlightOnDesktop

### Description

SpotlightOnDesktop is powershell script which allows you to always have beautiful wallpaper from Windows 10 Lockscreen on your desktop.

### Instalation
  - Just download this repository and extract the entire contents of archive somewhere on your computer.
  - Open Task Scheduler
    1) Create new task with some name
    2) As trigger set computer startup
    3) As action
      - Action: Run program
      - Program name: powershell.exe
      - Arguments: -ExecutionPolicy UnRestricted -windowstyle hidden -File SpotlightOnDesktop.ps1
      - Start in: Directory where script is extracted
    4) In conditions tab uncheck "Start the task only if computer is on AC power" and click OK.
  - Right click on created task and click Run.
  - Enjoy!

### Additional info
  - Script works only with Windows 10
  - Script work only with Spotlight wallpapers. If you set your own wallpaper this script cannot handle it!

### TODO

 - Autoinstaller
 - Support for own lockscreen wallpapers

### License

SpotlightOnDesktop script is licensed under [GNU General Public License 3](http://www.gnu.org/copyleft/gpl.html).