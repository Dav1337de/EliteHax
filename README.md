# EliteHax
EliteHax - Hacker World: Official Repository by Dav1337de

### CONTENTS ###
[1. INTRO](https://github.com/Dav1137de/EliteHax/blob/main/README.md#1-intro-1)

[2. RESOURCES](https://github.com/Dav1137de/EliteHax/blob/main/README.md#2-resources-1)

..*[2.1 Android App](https://github.com/Dav1137de/EliteHax/blob/main/README.md#21-android-app-1)

..*[2.2 Backend Server](https://github.com/Dav1137de/EliteHax/blob/main/README.md#22-backend-server-1)

..*[2.3 Database](https://github.com/Dav1137de/EliteHax/blob/main/README.md#23-database-1)

..*[2.4 Jobs](https://github.com/Dav1137de/EliteHax/blob/main/README.md#24-jobs-1)


### 1. INTRO ###
I'm Dav1337de, developer of EliteHax. 
Well, I developed EliteHax, but I'm not a real developer. I have a good job in cybersecurity, but I learnt around 15 programming/scripting/misc languages at school and for hobby.
I basically decided to create EliteHax on December 2016 because I was tired of all the pay2win hacking games available at that time. I wanted to create a game without any p2w content, with great features and focused on the community. And I succeeded! It's incredible! 
During my first 30 years of life I tried 4 times to develop a game, but always abandoned for different reason, but EliteHax was released, and updated, and updated, and updated!
But life changes and suddenly you don't have time anymore to pursue an hobby that requires daily effort to fix bugs here and there, to keep the community paceful, to implement all the wonderful ideas that I have in mind, to fight trash reviews on Play Store and many other things.
Since I don't have time to continue the development and take care of the server and ethically I cannot give users data to someone else, I've decided to end EliteHax on March 2021.
I am very grateful to the community that always supported me, so I decided to release the source code under MIT License, hoping that someone will rebuild it and EliteHax could reborn from the ashes in the future.

### 2. RESOURCES ###
I uploaded all the resources regarding the Android app, EliteHax backend, database schema and some other miscellaneous stuff that can be useful for a potential developer.
I am not a professional developer, so the code could look a bit 'Spaghetti Code', but I'm from Italy and I love spaghetti! Jokes apart, there are some very useful comments here and there, read them and use them. Naming convention is also pretty good, although not perfect.
Before uploading the code to GitHub, I removed all the encryption keys, hardcoded passwords and API keys from the code, adding specific comments that starts with 'GitHub Note:'; make sure to search for those comment and complete the information, otherwise it won't work.

### 2.1 Android App ###
In the folder 'EliteHax app' you can find all the source code and resources (img/audio) regarding the Android app.
The app is written in LUA using the former Corona SDK (https://coronalabs.com/ - when the 'Corona' terms had a completely different impact on our mind); the SDK is now called Solar2D (https://solar2d.com/) and I don't know if any change is required to build the project under Solar2D compared to Corona.
Another good option is to rebuild the Android app from scratch using a completely different language/framework/engine and just keep the EliteHax backend. It would require a bit more time and effort, but the result could be better since the UI was far from perfect and I have never been good at graphics.

### 2.2 Backend Server ###
In the folder 'EliteHax server' you can find all the source code related to EliteHax backend/API.
It's written in PHP and I consider it pretty solid. After 1.5 years without any kind of maintenance, there are only few minor things that are not working.
In the main folder you only have few files that are version independent, related to initial registration and password change, while all the backend logic is structured in subfolder:
- 'Dashboard': resources for two dashboards that I did use to monitor game status and economy and to monitor/identify cheaters;
- 'google/google-api-php-client-2.2.0': required for Google Play Authentication; probably it's old/outdated and should be replaced/updated;
- 'jobs': maintenance jobs that must be invoked with a task scheduler/cron/whatever, see '2.4 Jobs' for additional details;
- 'tutorial': the official tutorial for EliteHax; it's a good reference to see how the game looked like and used to work;
- 'v3.0.7': the backend/API of the last EliteHax version; here you have most of the backend logic.
Please note that some of the folders contains .htaccess file to limit the requests to localhost and to developer workstation ip address (to be modified).

### 2.3 Database ###
In the folder 'EliteHax database' you have a .sql file that you can use to build the complete EliteHax database schema from scratch.
In contains all the tables, columns, types, primary/foreign keys and integrity constraints.
Of course I will never upload user data since I had always care about the privacy of my players.

### 2.4 Jobs ###
There are several jobs scheduled using crontab, but you can use the task manager of your choice.
The name of the php script invoked is self-explanatory, the schedule is standard crontab syntax. I think if someone is going to rebuild EliteHax, he/she must be able to read this and understand what to do, otherwise he/she should give up even before starting.
There is an hardcoded password in the scripts to be used as parameter, to avoid unwanted requests from web crawlers. In addition remember that 'jobs' directory access is limited with .htaccess file.
```
0       2       *       *       *       /usr/bin/curl -sL https://app.elitehax.it/jobs/startHackTournament.php?pwd=HardCodedToChange --insecure  >> /tmp/tournament.log
0       0       *       *       mon     /usr/bin/curl -sL https://app.elitehax.it/jobs/resetWeeklyLeaderboard.php?pwd=HardCodedToChange >> /tmp/task_result.txt
10      0       *       *       *       /usr/bin/curl -sL https://app.elitehax.it/jobs/cleanup.php?pwd=HardCodedToChange --insecure >> /tmp/task_result.txt
0       0       *       *       *       /usr/bin/curl -sL https://app.elitehax.it/jobs/saveDailyAttackStatistics.php?pwd=HardCodedToChange --insecure > /dev/null
30      *       *       *       *       /usr/bin/curl -sL https://app.elitehax.it/jobs/updateBotMalware.php?pwd=HardCodedToChange --insecure > /dev/null
0       19      *       *       *       /usr/bin/curl -sL https://app.elitehax.it/jobs/stopHackDefendTournament.php?pwd=HardCodedToChange >> /tmp/tournament.log
*       *       *       *       *       /usr/bin/curl -sL https://app.elitehax.it/jobs/updatetask.php?pwd=HardCodedToChange --insecure >> /tmp/task_result.txt
0       18      *       *       *       /usr/bin/curl -sL https://app.elitehax.it/jobs/startHackDefendTournament.php?pwd=HardCodedToChange --insecure >> /tmp/tournament.log
0       0       1       *       *       /usr/bin/curl -sL https://app.elitehax.it/jobs/resetMonthlyLeaderboard.php?pwd=HardCodedToChange >> /tmp/task_result.txt
0       4       *       *       *       /usr/bin/curl -sL https://app.elitehax.it/jobs/startScoreTournament.php?pwd=HardCodedToChange  --insecure >> /tmp/tournament.log
0       *       *       *       *       /usr/bin/curl -sL https://app.elitehax.it/jobs/game_statistics.php?pwd=HardCodedToChange --insecure >> /tmp/task_result.txt
0       3       *       *       *       /usr/bin/curl -sL https://app.elitehax.it/jobs/stopHackTournament.php?pwd=HardCodedToChange --insecure >> /tmp/tournament.log
0       8       *       *       *       /usr/bin/curl -sL https://app.elitehax.it/jobs/stopScoreTournament.php?pwd=HardCodedToChange --insecure  >> /tmp/tournament.log
0       15      *       *       *       /usr/bin/curl -sL https://app.elitehax.it/jobs/stopHackTournament.php?pwd=HardCodedToChange --insecure >> /tmp/tournament.log
0       0       *       *       *       /usr/bin/curl -sL https://app.elitehax.it/jobs/resetDailyWallet.php?pwd=HardCodedToChange --insecure >> /tmp/task_result.txt
0       0       *       *       *       /usr/bin/curl -sL https://app.elitehax.it/jobs/stopScoreTournament.php?pwd=HardCodedToChange --insecure >> /tmp/tournament.log
0       20      *       *       *       /usr/bin/curl -sL https://app.elitehax.it/jobs/startScoreTournament.php?pwd=HardCodedToChange  >> /tmp/tournament.log
0       *       *       *       *       /usr/bin/curl -sL https://app.elitehax.it/jobs/updateBotMalware.php?pwd=HardCodedToChange --insecure > /dev/null
0       12      *       *       *       /usr/bin/curl -sL https://app.elitehax.it/jobs/stopHackDefendTournament.php?pwd=HardCodedToChange --insecure >> /tmp/tournament.log
0       14      *       *       *       /usr/bin/curl -sL https://app.elitehax.it/jobs/startHackTournament.php?pwd=HardCodedToChange --insecure >> /tmp/tournament.log
0       11      *       *       *       /usr/bin/curl -sL https://app.elitehax.it/jobs/startHackDefendTournament.php?pwd=HardCodedToChange --insecure >> /tmp/tournament.log
```









