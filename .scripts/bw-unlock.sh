export BW_SESSION=$(bw unlock | grep '$ export' | awk -F'BW_SESSION=' '{print $2}')

