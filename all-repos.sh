#!/bin/bash

REPOS_DB=~/.all-repos
test -f $REPOS_DB || touch $REPOS_DB

PRG=$0
CMD=$1
shift

list() {
  cat $REPOS_DB
}

add() {
  ls -1d $@ | while read REPO
  do
    ADDED=`readlink -f $REPO`

    if [ `egrep "^$ADDED$" $REPOS_DB` ]
    then
      echo "already added: $ADDED" >&2
      continue
    fi

    echo +$ADDED
    echo $ADDED >> $REPOS_DB
  done
}
del() {
  ls -1d $@ | while read R
  do
    DELETED=`readlink -f $R`

    if [ -z `egrep "^$DELETED$" $REPOS_DB` ]
    then
      echo "repo not found: $DELETED" >&2
      continue
    fi

    mv $REPOS_DB $REPOS_DB.old

    cat $REPOS_DB.old | while read REPO
    do 
      PATH=`readlink -f $REPO`
      if [ $PATH == $DELETED ]
      then
        echo -$DELETED
      else
        echo $DELETED >> $REPOS_DB
      fi
    done
  done
}

run() {
  cat $REPOS_DB | while read REPO
  do
    cd $REPO
    echo "$USER@`cat /etc/hostname`:`pwd`$ $@"

    $@ || true

    cd - >/dev/null
    echo ""
  done
}

usage() {
  echo "Usage: $PRG <command> [arguments...]" >&2
  echo "">&2
  echo "  Commands:" >&2
  echo "    run <command-line> - runs specified command on all repositories" >&2
  echo "" >&2
}

case "$CMD" in
  "list") list;;
  "add") add $@;;
  "del") del $@;;
  "run") run $@;;
  "")
    echo "command is required" >&2
    echo "" >&2
    usage
    ;;
  *)
    echo "unknown command: $CMD" >&2
    echo "" >&2
    usage
    ;;
esac

