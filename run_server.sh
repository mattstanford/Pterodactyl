#!/bin/sh

#  run_server.sh
#  PterodactylLib
#
#  Created by Matt Stanford on 3/22/20.
#  Copyright © 2020 Matt Stanford. All rights reserved.

scriptLocation=`dirName $0`
appLocation=`find $scriptLocation -name "PterodactylServer.app" | head -n 1`

open -a $appLocation --args $@

exit 0


