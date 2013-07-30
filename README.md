# DNA Shipistrano

> Deploying all the things

## Introduction

With hundreds of heterogeneous applications across a variety of platforms, 
languages and third-party infrastructure configurations, one challenge we have
faced, and continue to face, at DNA is ensuring that our developers have the 
tools and processes to make managing our portfolio of applications easy peesy.

## Monologue

One tool we've grown to love over the years is Capistrano. Young, fit and fresh 
faced, the relationship between the two of us blossomed. We were lovestruck by 
the elegant Ruby DSL, mesmerized by its' social status and therefor even 
congenial to its' opinionated ways and blind to all its shortcomings.

As time went on, Capistrano always stayed beautiful in our eyes but the romance 
had dwindled and over time lost it's spark. We didn't work on problems with our 
relationship. We didn't look to solve our issues together. We didn't experiment
with one another and because of that, rather than growing together, we grew 
apart.

Like all relationships that one day may be destined to fail, we felt the only 
way to save ours was to breath new life into it. So it was, Shipistrano was 
conceived.

Our dream for Shipistrano (like any parent) is that we can teach it all our life
lessons hopefully it doesn't make the same mistakes as we once did when we were
young.

## Shipistrano

Shipistrano is the collection of all our opinionated little scripts, curses and 
bad manners that have been passed down from generation to generation from the 
tough real world. But it also has some new tricks of it's own. It's favorite toy 
is building blocks. Everything Shipistrano plays with is a building block and 
so by using collections of these colourful blocks, Shipistrano can create any 
sort of play area you want.

## Bringing Shipistrano up, the early years

Shipistrano is a child of the much wiser Capistrano. Capsitrano is packaged as
a Ruby gem, hence for it to run you must have installed Ruby (>=1.8.7) and 
Rubygems on your local machine. Describing all the ways to setup Capistrano and 
the lessons Capistrano can teach Shipistrano is a little beyond this one page so 
if you haven't, play with the elder first and you'll pick up a trick or three. 

[https://github.com/capistrano/capistrano](https://github.com/capistrano/capistrano). 

Once you have installed Ruby on the machine, you should be able to run bundler
to grab capistrano and all the friends Shipistrano wants to play with
  
  cd dna_Shipistrano
  bundle install

### Planning your playtime

First, include this repo inside the project you want to build ontop of 
Shipistrano. You can do this a number of ways:

  1) download the repo and symlink it in,
  2) add it as a git submodule
  3) just download the repo

I personally like to play with it as a submodule to an existing git project so
I would run the following

  cd ~/Sites/project
  git submodule add git@github.com:dnadesign/dna_Shipistrano.git cap
  git submodule sync
  git submodule init

  
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

  cap -vT

Or, if you have built on the separate+environment example, you can see what
tasks you can do on that environment by including the name of the environment in
the command

  cap staging -vT

And running [Capistrano Tasks](https://github.com/capistrano/capistrano/wiki/Capistrano-Tasks)
is just that easy, either run the task as you would normally:

  cap deploy

Or, again, with the environment specified.

  cap staging deploy

## Epilogue

As mentioned, Shipistrano is opinionated to how we want to raise a child of 
Capistrano. May not be the kind of kid you want to hang out with but because of
him we love Capistrano just a little bit more.