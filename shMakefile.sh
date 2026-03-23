#!/bin/bash 

setcolor

alice() {
  ## This is a simple function that can be invoked. 
  ## Comments that starts with `##` are shown in the script usage (./shMakefile --help) 
  ## Parameters:  
  ##    -env **required** the environment to operare, like test or prod
  ##    -name your name
  mustVar env
  local name="${name:-}"    # optional, default empty  
  
  # Everything with the form `--<key>=value` is passed as a named variable 
  echo "alice ${env} ${name}"
}

bob() {
  mustVar env
  echo "bob ${env}"
}