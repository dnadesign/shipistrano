# DNA Shipistrano

> Ship all the things

NOTE: This is coming out of our internal repos, getting a tidy up, fixing 
shit that's years old and is more a work in process that production ready. So
use at your own risk, most of the helpers we need haven't quite been copied yet
but as I have time, this'll get padded out.

** Check the TODO.md document for outstanding stuff **

NOTE: This still uses the old Capistrano v2. Haven't yet looked into Capistrano v3

## Introduction

With hundreds of heterogeneous applications across a variety of platforms, 
languages and third-party infrastructure configurations, one challenge we face 
at DNA managing those in a effective way. Not just from a automation view but
also to ensure that we have the structure and processes to make sure each team
isn't being caught up reinventing the wheel.

This repo provides one part of our toolkit in solving our problem. Shipistrano 
provides a collection of tested Capistrano processes and helper recipes for 
deploying and syncing environments between machines. It can be used onto of 
Capistrano in order to provide additional helpers.

## Monologue

One tool we've grown to love over the years is Capistrano. Young, fit and fresh 
faced, the relationship between Capistrano and our team blossomed. We were 
lovestruck by the elegant Ruby DSL, mesmerized by its' social grace, blind to 
the birth defects and even congenial to its' opinionated ways.

As time went on, Capistrano always stayed beautiful but the romance dwindled. 
We didn't work on problems with our relationship together. We didn't listen to 
one another or experiment with one another and because of that, rather than 
growing together, we grew apart.

Like all relationships that one day may be destined to fail, we felt the only 
way to save our one was to breath new life into it. So it was, Shipistrano was 
conceived.

Our dream for Shipistrano, much like any parent, is that we can teach it all our 
life lessons so that hopefully it doesn't make the same mistakes as we once did 
when we were young. The best of what we know, plus more.

## Shipistrano

Shipistrano is the collection of all our opinionated little scripts, shortcuts 
and bad manners that have been passed down from generation to generation from 
the rough and tough real world. But it also has some new tricks of it's own. 

Shipistrano's favorite toy is building blocks. Everything Shipistrano plays with 
is a building block and so by using different compositions of these colourful 
little blocks, Shipistrano can create any sort of play area you want.

## Bringing Shipistrano up, the early years

Shipistrano is a child of the much wiser Capistrano. Capsitrano is packaged as
a Ruby gem, hence for it to run you must have installed Ruby (>=1.8.7) and 
Rubygems on your local machine. Describing all the ways to setup Capistrano and 
the lessons Capistrano can teach Shipistrano is a little beyond this one page so 
if you haven't, play with the elder first and you'll pick up a trick or three. 

[https://github.com/capistrano/capistrano](https://github.com/capistrano/capistrano). 

Once you have installed Ruby on the machine, you should be able to run bundler
to grab capistrano and all the friends Shipistrano wants to play with

```
  cd dna_shipistrano
  bundle install
```

### Planning your playtime

First, include this repo inside the project you want to build ontop of 
Shipistrano. You can do this a number of ways:

  1) download the repo and symlink it in,
  2) add it as a git submodule
  3) just download the repo

I personally like to play with it as a submodule to an existing git project so
I would run the following

```
  cd ~/Sites/project
  git submodule add git@github.com:dnadesign/shipistrano.git cap
  git submodule sync
  git submodule init
```
  
### Starting playtime with Shipistrano

Before we can use Shipistrano, we first need to create a new file in the project 
which contains the outline and main picture rules we want Shipistrano to play 
with. We've drawn a few pictures in our time so a collection of existing 
diagrams are provided inside the examples folder.

Let's take an example of a basic VPS server with production / staging versions
and running mysql as our basic outline

  cp cap/examples/basic.capfile ./capfile

That line will copy the example file to our `capfile` in the root of the 
project. If you don't know what a `capfile` is, I recommend you consult the
[Capistrano Documentation](https://github.com/capistrano/capistrano). 
  
Feel free to checkout some of the other examples that Shipistrano can play with,
to get an idea of the flexibility of the concept.

The `capfile` contains links to particular recipes an application might need. 
For instance the MySQL and Postgres helpers are separate helpers which can be
included depending on what solution your application is using. Simple load the
helper and ensure you implement the variables required.

A capfile with an application that has a Postgres database might include the
following:

```
  // capfile
  set :pgsql_user, "username"
  set :pgsql_database, "database"

  load 'cap/lib/shipistrano/helpers/postgres'
```

After copying the example you want to follow, you'll need to edit the `capfile`
to customize the picture to exactly what you want it to look like. Open the file
in a TextEditor of your choice, and alter away. Remember, the examples provide
a few neat tricks and your capfile is simply a ruby file. You can teach 
Shipistrano whatever else you want too along with the build in lessons.

### Playtime GO!

Now that your capfile exists and the cap folder is in your project, Shipistrano
can do it's thing. Actually in fact, it doesn't do much. It relies on it's 
parents to do most of the world for it. 

To see Capistrano tasks your Shipistrano picture provides run

```
  cap -vT
```

Or, if you have built on the separate+environment example, you can see what
tasks you can do on that environment by including the name of the environment in
the command

```
  cap staging -vT
```

And running [Capistrano Tasks](https://github.com/capistrano/capistrano/wiki/Capistrano-Tasks)
is just that easy, either run the task as you would normally:

```
  cap deploy
```

Or, again, with the environment specified.

```
  cap staging deploy
```

## Epilogue

As mentioned, Shipistrano is opinionated to how we want to raise a child of 
Capistrano. May not be the kind of kid you want to hang out with but because of
him we love Capistrano just a little bit more.

## On a more serious note

### Server Configuration

You will note that none of the receipes include code snippets for managing the
server, this is by design. We keep that stuff in Chef. Chef is the Bonnie to
Shipistrano's Clyde. If you want to hear about how we're running Chef, buy me
a beer sometime.

### Testing

Unlike every other capistrano suite I've used, the goal of this one is to be 
stable. Test cases are provided through Cucumber based on similar work by
Jeff Dean (https://github.com/zilkey). To run the tests simply install cucumber
on your machine and run it in this project.

```
  cd ~/Scripts/shipistrano
  cucumber
```

If you only need to test a particular feature or scenario, pass that to cucumber

```
  # run the asset scenarios
  cucumber features/assets.feature

  # run the asset scenario on line 6
  cucumber features/assets.feature:6
```

**NOTE**: The database tests assume you have setup configure file based logins
for your MySQL. To do that, define a ~/.my.cnf with the following settings

```
  [mysql]
  user=mysql
  password=passwordis?

  [mysqldump]
  user=mysql
  password=passwordis?
```

### Contributions

Are welcome! But, this repo is what we're working on putting into production so,
we reserve the right to be opinionated. If you disagree, fork me.

If this thing saves you time, awesome.

This project funded and paid for as part of commercial work we do DNA Designed 
Communications Limited (dna.co.nz). If you feel you have too, please donate 
instead to a charity (http://www.charitywater.org/) and let @dna_nz / @wilr
know and we'll be super grateful!

### License

BSD-3-Clause. True open source.  
