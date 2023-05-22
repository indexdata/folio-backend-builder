
# Gets currently checked out branch if other than 'master'
function gitStatus() {
  modulePath=$1
  gitStatus=$(git -C "$modulePath" status | head -1)
  if [[ "$gitStatus" == "On branch master" ]]; then
    echo ""
  else
    echo " ($gitStatus)"
  fi
}
