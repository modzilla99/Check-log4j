# Check-log4j
Log4Shell vulnerability checker - domain.

copy the ps1 file, edit your $server and $path, and wait for a long time.
Alternatively, split this by starting letter and run several simultaneous logs. - needs to add a variable to the output file: just append $prefix

## What does it do?

The script queries your AD for all Windows-Server based servers. <br/>
This servers are then scanned for the presence of log4j files on the filesystem, which indicate a vulnerable library being present.
(unfortunately single-threaded...)

Version 1 isn't impacted, as the functionality being exploited was added in log4j2.

So once you have the logfile, check which servers have log4j version 2, and go from there. <br/>

You can activate **DeepScan** by using the switch `-DeepScan`. This will scan for all jar-Files and print them out if no log4j-named file was found. In contrast to Linux it is not possible to automatically look for log4j within these jars. 

### Additional info
For more details, I advise to check the following links:
* [Randori](https://www.randori.com/blog/cve-2021-44228/)
* Reddit [netsec](https://www.reddit.com/r/netsec/comments/rcwws9/rce_0day_exploit_found_in_log4j_a_popular_java/) - this one includes several sources.
* [Lunasec](https://log4shell.com/)
* [slf4j](http://slf4j.org/log4shell.html) confirms log4j version 1 is unaffected

## Example

```
Unblock-File check-log4j.ps1
.\check-log4j.ps1 -logfile C:\temp\logoutput.txt [-DeepScan]
```

# Linux
to check linux servers, you can use the follwing query in terminal:

```
find / -name log4j-*.jar
```

To check jar files if they have log4j included type the following (this may take a while...):

```
sudo find / -name \*.jar \
	-exec sh -c \
	"if zipinfo {} | grep JndiLookup.class; \
	 then \
	     echo -e '{}\n'; \n
	 fi" \; 2>/dev/null
```
