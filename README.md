# shmake
[![test](https://github.com/totomz/shmake/actions/workflows/test.yml/badge.svg)](https://github.com/totomz/shmake/actions/workflows/test.yml)

Build tool in plain sh
`shmake` is a simple script to execute build scripts in bash. 

# How to use
`shMake` is "similar" to GNU Make: it executes a "target" function defined in an `shMakefile`.

Given this `shMakefile`
```shell
function install() {    
    echo "running npm install with ${parameter}"
}

function build() {
  install # run install before
  echo "Hello ${key2}!"
}
```

Then, the output of `shmake build --parameter=shmake --key2=World` is  

`shMakefile` are just plain bash script; it is possible to use `source` to load scripts from a different path (see `examples/inner/shMakefile`)



## Function Documentation
`./shMakefile --help` print a description for each non-private function (function name does not start with `_`)

Each function documentation is made of any line that starts with `## ` within its body  

# Install
Simply, put `shmake` in your $PATH, eg 
```shell
curl -o ~/bin/shmake "https://raw.githubusercontent.com/totomz/shmake/main/shmake"
chmod +x ~/bin/shmake
```


# Builtin functions
The scrip `functions.sh` contains general utilities function to interact with kubectl and git, and 
generic functions for logging.

The script `tests.sh` test the system

# Versioning / Stability
We are using this file with this structure since several years, no breaking changes are expected.
Just keep keep you changes between the boundaries should be safe 
