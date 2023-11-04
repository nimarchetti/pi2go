# This is a Fork of the Chuchodavids guide2go, originally based on mar-mei's guide2go

I haven't nyet updated this documentation, except for these inistial paragraphs

The intention here is to create a reaspberry pi docker image that will have a scheduled download of guide data, to run alongside a threadfin docker container

--- original docs here:

I implemented changes that were missing in the current Guide2Go version.

**Recent changes:**
1. Grab images from Schedules Direct in a local folder. This script will download tvshow/movie images and save them in a local folder. Then it will expose the images from a go server. This is useful for players like Emby or Plex.
1. For players like tiviMate I added the "live" and "new" icon in the tittle of the program. This is usually auto-added in Emby or other IPTV players, but TiviMate does not do this by reading XML tags.
1. Added the option to proxy the images instead of downloading them locally. It will pass the guide2go server IP and the server will act as a reverse-proxy to Schedules Direct to grab the image. (only usefully for small EPG files).


## Guide2Go
Guide2Go is written in Go and creates an XMLTV file from the Schedules Direct JSON API.  
**Configuration files from version 1.0.6 or earlier are not compatible!**

### Advantages compared to version 1.0.x
- 3x faster
- Less memory
- Smaller cache file

#### Features
- Cache function to download only new EPG data
- No database is required
- Update EPG with CLI command for using your own scripts

#### Requirement
- [Schedules Direct](https://www.schedulesdirect.org/ "Schedules Direct") Account
- [Go](https://golang.org/ "Golang") to build the binary
- Computer with 1-2 GB memory


## Installation
### Build binary
The following command must be executed with the terminal / command prompt inside the source code folder.  

```
go mod init main
go get
go build -o guide2go

```

### Docker
Download the docker image:

docker pull chuchodavids/guide2go:stable

**Stable:**

`docker pull chuchodavids/guide2go:stable`

**Development:**

`docker pull chuchodavids/guide2go:development`

**docker-compose**
```
version: "3.4"
services:
    guide2go:
      container_name: guide2go
      image: chuchodavids/guide2go:stable
      ports:
        - 8080:8080
      environment:
        - TZ: America/Chicago
      volumes:
        - /YOU_APP_PATH/guide2go:/app
        - /YOUR_IMAGE_PATH:/app/images
      restart: always
```

### Show CLI parameter:  
```guide2go -h```

```
-config string
    = Get data from Schedules Direct with configuration file. [filename.yaml]
-configure string
    = Create or modify the configuration file. [filename.yaml]
-h  : Show help
```

### Create a config file:

**note: You can use the sample config file that is in the /config folder inside of the docker container**

```guide2go -configure MY_CONFIG_FILE.yaml```  
If the configuration file does not exist, a YAML configuration file is created. 

**Configuration file from version 1.0.6 or earlier is not compatible.**  
##### Terminal Output:
```

Configuration [MY_CONFIG_FILE.yaml]
-----------------------------
 1. Schedules Direct Account
 2. Add Lineup
 3. Remove Lineup
 4. Manage Channels
 5. Create XMLTV File [MY_CONFIG_FILE.xml]
 0. Exit

```

**Follow the instructions in the terminal**

1. Schedules Direct Account:  
Manage Schedules Direct credentials.  

2. Add Lineup:  
Add Lineup into the Schedules Direct account.  

3. Remove Lineup:  
Remove Lineup from the Schedules Direct account.  

4. Manage Channels:  
Selection of the channels to be used.
All selected channels are merged into one XML file when the XMLTV file is created.
When using all channels from all lineups it is recommended to create a separate Guide2Go configuration file for each lineup.  

**Example:**  

Lineup 1:
```
guide2go -configure Config_Lineup_1.yaml
```
Lineup 2:
```
guide2go -configure Config_Lineup_2.yaml
```

5. Create XMLTV File [MY_CONFIG_FILE.xml]:  
Creates the XMLTV file with the selected channels.  

#### The YAML configuration file can be customize with an editor.:

```yaml
Account:
    Username: SCHEDULES_DIRECT_USERNAME
    Password: SCHEDULES_DIRECT_HASHED_PASSWORD
Files:
    Cache: MY_CONFIG_FILE.json
    XMLTV: MY_CONFIG_FILE.xml
Options:
    Poster Aspect: all
    Schedule Days: 7
    Subtitle into Description: false
    Insert credits tag into XML file: true
    Local Images Cache: true
    Images Path: /data/images/
    Proxy Images: false
    Hostname: localhost:8080
    Rating:
        Insert rating tag into XML file: true
        Maximum rating entries. 0 for all entries: 1
        Preferred countries. ISO 3166-1 alpha-3 country code. Leave empty for all systems:
          - DEU
          - CHE
          - USA
        Use country code as rating system: false
    Show download errors from Schedules Direct in the log: false
Station:
  - Name: Fox Sports 1 HD
    ID: "82547"
    Lineup: USA-DITV-DEFAULT
  - Name: Fox Sports 2 HD
    ID: "59305"
    Lineup: USA-DITV-DEFAULT
```

**- Account: (Don't change)**  
Schedules Direct Account data, do not change them in the configuration file.  

**- Files: (Can be customized)**
```yaml
Cache: /app/file.json  
XMLTV: /app/file.xml  
```

**- Options: (Can be customized)**  
```yaml
Poster Aspect: all
```
- all:  All available Image ratios are used.  
- 2x3:  Only uses the Image / Poster in 2x3 ratio. (Used by Plex)  
- 4x3:  Only uses the Image / Poster in 4x3 ratio.  
- 16x9: Only uses the Image / Poster in 16x9 ratio.  

**Some clients only use one image, even if there are several in the XMLTV file.**  

---

```yaml
Schedule Days: 7
```
EPG data for the specified days. Schedules Direct has EPG data for the next 12-14 days  

---

```yaml
Subtitle into Description: false
```
Some clients only display the description and ignore the subtitle tag from the XMLTV file.  

**true:** If there is a subtitle, it will be added to the description.  

```XML
<?xml version="1.0" encoding="UTF-8"?>
<programme channel="guide2go.67203.schedulesdirect.org" start="20200509134500 +0000" stop="20200509141000 +0000">
   <title lang="de">Two and a Half Men</title>
   <sub-title lang="de">Ich arbeite für Caligula</sub-title>
   <desc lang="de">[Ich arbeite für Caligula]
Alan zieht aus, da seine Freundin Kandi und er in Las Vegas eine Million Dollar gewonnen haben. Charlie kehrt zu seinem ausschweifenden Lebensstil zurück und schmeißt wilde Partys, die bald ausarten. Doch dann steht Alan plötzlich wieder vor der Tür.</desc>
   <category lang="en">Sitcom</category>
   <episode-num system="xmltv_ns">3.0.</episode-num>
   <episode-num system="onscreen">S4 E1</episode-num>
   <episode-num system="original-air-date">2006-09-18</episode-num>
   ...
</programme>
```

---
```yaml
Local Images Cache: false
```
**true**: Download the images from SD in a local folder. This option atuomatically enables the server so clients can access to the images.
**false**: images are not downloaded locally

---

```yaml
Hostname: localhost:8080
```
**Hostname:** hostname + port of the local server for the images 
---

```yaml
Images Path: /data/images
```

Path to cache images locally. Only useful if Local Images Cache = true

---

```yaml
Proxy Images: false
```

**True**: (Overrides local image cache option) Instead of downloading the images locally, it will act as a reverse proxy between the clients and guide2go server.
This is only usefull when there are not too many clients on your network, not too many channels on your EPG and you are not downloading more than 1-3 days of EPG data.
It is very usefull if you dont want to bother setting up a cache folder for your EPG images.

---

```yaml
Insert credits tag into XML file: false
```
**true:** Adds the credits (director, actor, producer, writer) to the program information, if available.
```xml
<?xml version="1.0" encoding="UTF-8"?>
<programme channel="guide2go.67203.schedulesdirect.org" start="20200509134500 +0000" stop="20200509141000 +0000">
   <title lang="de">Two and a Half Men</title>
   <sub-title lang="de">Ich arbeite für Caligula</sub-title>
   ...
  <credits>
    <director>Jamie Widdoes</director>
    <actor role="Charlie Harper">Charlie Sheen</actor>
    <actor role="Alan Harper">Jon Cryer</actor>
    <actor role="Jake Harper">Angus T. Jones</actor>
    <actor role="Judith">Marin Hinkle</actor>
    <actor role="Evelyn Harper">Holland Taylor</actor>
    <actor role="Rose">Melanie Lynskey</actor>
    <writer>Chuck Lorre</writer>
    <writer>Lee Aronsohn</writer>
    <writer>Susan Beavers</writer>
    <writer>Don Foster</writer>
</credits>
   ...
</programme>
```

---

```yaml
Rating:
        Insert rating tag into XML file: true
        ...
```
**true:** Adds the TV parental guidelines to the program information.  

```xml
<?xml version="1.0" encoding="UTF-8"?>
<programme channel="guide2go.67203.schedulesdirect.org" start="20200509134500 +0000" stop="20200509141000 +0000">
  <title lang="de">Two and a Half Men</title>
  <sub-title lang="de">Ich arbeite für Caligula</sub-title>
  <language>de</language>
  ...
  <rating system="Freiwillige Selbstkontrolle der Filmwirtschaft">
    <value>12</value>
  </rating>
   ...
</programme>
```
**false:** TV parental guidelines are not used. Further rating settings are ignored.  
```xml
<?xml version="1.0" encoding="UTF-8"?>
<programme channel="guide2go.67203.schedulesdirect.org" start="20200509134500 +0000" stop="20200509141000 +0000">
  <title lang="de">Two and a Half Men</title>
  <sub-title lang="de">Ich arbeite für Caligula</sub-title>
  <language>de</language>
   ...
</programme>
```

```yaml
Rating:
        ...
        Maximum rating entries. 0 for all entries: 1
        ...
```
Specifies the number of maximum rating entries. If the value is 0, all parental guidelines available from Schedules Direct are used. Depending on the preferred countries.

```yaml
Rating:
        ...
        Preferred countries. ISO 3166-1 alpha-3 country code. Leave empty for all systems:
          - DEU
          - CHE
          - USA
        ...
```
Sets the order of the preferred countries [ISO 3166-1 alpha-3](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-3 "ISO 3166-1 alpha-3").  
Parental guidelines are not available for every country and program information. Trial and error.  
If no country is specified, all available countries are used. Many clients ignore a list with more than one entry or use the first entry.  

**If no country is specified:**  
If a rating entry exists in the same language as the Schedules Direct Lineup, it will be set to the top. In this example German (DEU).  

Lineup: **DEU**-1000097-DEFAULT  
1st rating system (Germany): Freiwillige Selbstkontrolle der Filmwirtschaft  
```xml
...
<rating system="Freiwillige Selbstkontrolle der Filmwirtschaft">
  <value>12</value>
</rating>
<rating system="USA Parental Rating">
  <value>TV14</value>
</rating>
...
```

```yaml
Rating:
        ...
        Use country code as rating system: false
```

**true:**
```xml
<rating system="DEU">
  <value>12</value>
</rating>
<rating system="USA">
  <value>TV14</value>
</rating>

```

**false:**
```xml
<rating system="Freiwillige Selbstkontrolle der Filmwirtschaft">
  <value>12</value>
</rating>
<rating system="USA Parental Rating">
  <value>TV14</value>
</rating>
```

---

```
Show download errors from Schedules Direct in the log: false
```
**true:** Shows incorrect downloads of Schedules Direct in the log.  

Example:
```
2020/07/18 19:10:53 [ERROR] Could not find requested image. Post message to http://forums.schedulesdirect.org/viewforum.php?f=6 if you are having issues. [SD API Error Code: 5000] Program ID: EP03481925
```

### Create the XMLTV file using the command line (CLI): 

```
guide2go -config MY_CONFIG_FILE.yaml
```
**The configuration file must have already been created.**
