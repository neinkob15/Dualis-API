# Dualis API

This is an unofficial API for dualis by DHBW built with Bash. This one file NOTEN.sh lets you retrieve all grades as json.<br/>
The interface can be used by all sorts of applications for automating things concerning grades.<br/>
It uses 'curl' for login and querying all the pages.

## usage

Call: <br/>
 ./NOTEN.sh [Options]<br/>
 
Options: <br/>
 -u	Set username (f.e. muster.max@dh-karlsruhe.de)<br/>
 -p	Set password<br/>
 -h	Show help page<br/>
 
The options -u and -p are mandatory fields, without them, grades cannot be gathered.

## webserver

Alternatively you can use the webserver. See here for an example: https://neinkob.de/grades.
<br />Use your dhbw email (mustermann.max@dh-karlsruhe.de) as username and your password. 

