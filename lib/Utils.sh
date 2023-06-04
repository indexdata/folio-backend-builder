
# Returns currently checked out branch if other than 'master'
function gitStatus() {
  modulePath=$1
  gitStatus=$(git -C "$modulePath" status | head -1)
  if [[ "$gitStatus" == "On branch master" ]]; then
    echo ""
  else
    echo " ($gitStatus)"
  fi
}

# Returns time since file was last written
function filesAge() {
  filePath="$1"
  days="$((($(date +%s) - $(date +%s -r "$filePath")) / 86400))"
  hours="$((($(date +%s) - $(date +%s -r "$filePath")) / 3600))"
  minutes="$((($(date +%s) - $(date +%s -r "$filePath")) / 60))"
  seconds="$(($(date +%s) - $(date +%s -r "$filePath")))"
  if [[ $days -gt 1 ]]; then
    printf "%s days" $days
  else  
    if [[ $hours -gt 1 ]]; then
      printf "%s hours" $hours
    else
      if [[ $minutes -gt 1 ]]; then
        printf "%s minutes" $minutes
      else
        printf "%s seconds" $seconds
      fi
    fi
  fi
}
