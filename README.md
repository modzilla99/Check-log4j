# Check-log4j
Log4Shell vulnerability checker - domain.

copy the ps1 file, edit your $server and $path, and wait for a long time.
Alternatively, split this by starting letter and run several simultaneous logs. - needs to add a variable to the output file: just append $prefix

For Linux, you can use the follwing:

find . -name log4j-*.jar


## Example

customer: 'Contoso'

server naming scheme: 'Con-$svrXY'

use prefix: 'Con-'


If you want to split the scan into mulitple logs or have several naming schemes, run several instances simultaneously.

Examples:

prefix: 'Con-fil'

prefix: 'Con-app'
