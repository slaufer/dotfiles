#!/bin/bash
[[ "$TERM" = "st" ]] && export TERM="xterm"
[[ "$TERM" = "st-256color" ]] && export TERM="xterm-256color"
[[ "$TERM" = "xterm" ]] && export TERM="xterm-256color"

export JAVA_HOME='/usr/lib/jvm/java-7-openjdk-amd64'
export PLAY2_HOME="$HOME/apps/play-2.2.0"
export MAVEN_HOME="$HOME/apps/maven"
export ECLIPSE_HOME="$HOME/apps/eclipse"
export NODE_HOME="$HOME/apps/node-v6.9.4-linux-x64"
export PATH="$HOME/bin:$NODE_HOME/bin:$MAVEN_HOME/bin:$PATH"
