1. Install all the required packages for the system

```
$ sudo apt-get install build-essential openssl libreadline6 libreadline6-dev curl git-core zlib1g zlib1g-dev libpq-dev libssl-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev automake libtool bison subversion
```

2. Install RVM

```
$ bash -s stable < <(curl -s https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer)
```

Reload your shell environment

```
$ source ~/.rvm/scripts/rvm
```

Find the requirements (follow the instructions):

```
$ rvm requirements
```

Install ruby:

```
$ rvm install 1.9.2-p290
```

Now we have RVM and Ruby ready to roll with whatever projects we decide to build :)
