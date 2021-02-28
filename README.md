# EliteHax
EliteHax - Hacker World: Official Repository by Dav1337de

### CONTENTS ###
[1. INTRO](https://github.com/Dav1137de/EliteHax/blob/main/README.md#1-intro-1)

[2. Resources](https://github.com/Dav1137de/EliteHax/blob/main/README.md#2-resources-1)

   [2.1 Android App](https://github.com/Dav1137de/EliteHax/blob/main/README.md#21-android-app-1)

   [2.2 Backend Server](https://github.com/Dav1137de/EliteHax/blob/main/README.md#22-backend-server-1)

   [2.3 Database](https://github.com/Dav1137de/EliteHax/blob/main/README.md#23-database-1)

   [2.4 Jobs](https://github.com/Dav1137de/EliteHax/blob/main/README.md#24-jobs-1)
   
   [2.5 Miscellaneous](https://github.com/Dav1137de/EliteHax/blob/main/README.md#25-miscellaneous-1)
   
[3. Security Practices](https://github.com/Dav1137de/EliteHax/blob/main/README.md#3-security-practices-1)

[4. Issues](https://github.com/Dav1137de/EliteHax/blob/main/README.md#4-issues-1)

[5. Architecture](https://github.com/Dav1137de/EliteHax/blob/main/README.md#5-architecture-1)

[6. Statistics](https://github.com/Dav1137de/EliteHax/blob/main/README.md#6-statistics-1)

[7. Contacts](https://github.com/Dav1137de/EliteHax/blob/main/README.md#7-contacts-1)


### 1. INTRO ###
I'm Dav1337de, developer of EliteHax. 
Well, I developed EliteHax, but I'm not a real developer. I have a good job in cybersecurity, but I learnt around 15 programming/scripting/misc languages at school and for hobby.

I basically decided to create EliteHax on December 2016, while I was a stuck in the Alps with bad weather, because I was tired of all the pay2win hacking games available at that time. I wanted to create a game without any p2w content, with great features and focused on the community. And I succeeded! It's incredible! 

During my first 30 years of life I tried 4 times to develop a game, but always abandoned for different reason, but EliteHax was released, and updated, and updated, and updated!
But life changes and suddenly you don't have time anymore to pursue an hobby that requires daily effort to fix bugs here and there, to keep the community paceful, to implement all the wonderful ideas that I have in mind, to fight trash reviews on Play Store and many other things.

Since I don't have time to continue the development and take care of the server and ethically I cannot give users data to someone else, I've decided to end EliteHax on March 2021.

I am very grateful to the community that always supported me, so I decided to release the source code under MIT License, hoping that someone will rebuild it and EliteHax could reborn from the ashes in the future. If someone will ever succeed, please let me know!

### 2. Resources ###
I uploaded all the resources regarding the Android app, EliteHax backend, database schema and some other miscellaneous stuff that can be useful for a potential developer.
I am not a professional developer, so the code could look a bit 'Spaghetti Code', but I'm from Italy and I love spaghetti! Jokes apart, there are some very useful comments here and there, read them and use them. Naming convention is also pretty good, although not perfect.

Before uploading the code to GitHub, I removed all the encryption keys, hardcoded passwords and API keys from the code, adding specific comments that starts with 'GitHub Note:'; make sure to search for those comment and complete the information, otherwise it won't work.

### 2.1 Android App ###
In the folder 'EliteHax app' you can find all the source code and resources (img/audio) regarding the Android app.

The app is written in LUA using the former Corona SDK (https://coronalabs.com/ - when the 'Corona' word had a completely different impact on our mind); the SDK is now called Solar2D (https://solar2d.com/) and I don't know if any change is required to build the project under Solar2D compared to Corona.

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

Please note that some of the folders contains .htaccess file to limit the requests to localhost and to developer workstation ip address (you need to modify it).

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

### 2.5 Miscellaneous ###
In the folder 'Miscellaneous' you can find additional resources such as historical screenshots, TODO lists, notes, reference for some lists in the game and so on. 
Maybe you will find something useful, maybe not.

### 3. Security Practices ###
As a cybersecurity professional, although WebApp, Mobile and Code security are not my specialization, I always tried to put a lot of effort on security practices and I would like that anyone that will eventually rebuild EliteHax will continue to follow or improve security practices, for the benefit of the players and game stability.

I always tried to use state of the art encryption and hashing mechanism (AES-256, SHA-256, HMAC), use prepared statement to avoid any kind of SQL Injection, at some point I added nonce to avoid replay attacks, certificate pinning to make MITM more difficult, package check to avoid app tampering and most importantly input validation! 
I also put a CDN from CloudFlare to mitigate incoming attacks, hide the origin and improve performance around the world.

Always start to validate the inputs on the client before sending, but remember that client can be tampered, so ALWAYS validate the inputs on the backend!!! Don't trust the client app.

I also tried to add various anti-cheat protection and detection mechanism, blocking login from proxy/anonymizer, registrations from temporary emails, check for multiple users from same device/connection and so on. Honestly I hated doing this part, I prefer to focus on expanding the features, but at some point unfortunately it was necessary.

### 4. Issues ###
I'm sure there are numerous uncovered bugs, but generally speaking the code is not that bad at all. Just to give you an idea, the game has been active for 1.5 years without any kind of maintenance and only few things are not working.

The most important issues that I'm aware of are:
- Tournaments & Weekly/Monthly Leaderboards: the combination of code and crontab schedule struggle when there is a time change (Daylight Standard Time vs Standard Time), manual SQL queries could be necessary; Another issue can be a deadlock during this scheduled jobs (see below);
- Deadlocks: sometimes there are deadlocks on mysql database. I'm not a sql master, so some troublesome queries could probably be optimized; server resources could also mitigate this issues;
- Google policies: Google Play updates its policies quite often, so sometimes you need to adjust some permission, update some package, add some metadata to the app and various other things to stay compliant and avoid having the app being removed;
- Graphical Issues: the game doesn't scale well with modern mobile screens, graphics needs to be adjusted for new screen ratio and account for notch, side bars and so on. Generally speaking, UI was never the greatest point of EliteHax... a good graphic designer can improve the impact of the game on new users a lot!

### 5. Architecture ###
The architecture is very simple.. a single server.

It's a CentOS 7 with Plesk pre-installed, hosted on Ionos with 1 vCPU, 1GB RAM and 50GB SSD drive, for something around €15/month (remember that it's not a pay2win game!).
Probably additional vCPU would be nice, RAM is not a huge issue, average is 27% and swap space is never used. Disk space is at 50%, but I offloaded backup files.

I think this is the bare minimum to run EliteHax in a stable way, of course with a good connection. I am also extremely satisfied by IONOS, I always had an incredible uptime and never experienced any serious issue with them.

I also think it could be nice to leverage docker to improve scalability/performance, but I never had time to try it.

### 6. Statistics ###
I started building the game on December 2016 and quit development on October 2018. During this time I wrote a total of 63.181 lines of code, 45.253 Client Side and 17.928 Server Side.

EliteHax was downloaded 100.000+ times and had 23,853 registered users.

In the 'Miscellaneous' folder you can also find the final leaderboard and in-game statistics.

### 7. Contacts ###
You can contact me at app.elitehax.it@gmail.com or on Discord: Dav1337de#4674 or https://discord.gg/BZ5tYxBDuw.

I am willing to give advices or explanation on specific parts of the code to whoever wants to rebuild the game, but I'll not take any active role in it.

If anyone will succeed on re-launching EliteHax, please let me know!







