# shmake
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

# Install
Simply, put `shmake` in your $PATH, eg 
```shell
curl -o ~/bin/shmake "https://raw.githubusercontent.com/totomz/shmake/main/shmake"
chmod +x ~/bin/shmake
```


# Builtin functions
These functions can be used in the target
```shell

gitVersion=$()

```