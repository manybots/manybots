# Manybots

Manybots is the platform for your digital life. It uniquely connects all the apps and devices that power your digital lifestyle into a single place where you can explore, visualize and quantify the data from your past, present and future.

What you get:

 - Detailed access to everything that you did and might do, as reported by your apps and devices
 - Centralized notifications from different apps and devices
 - Powerful visualizations of your lifestyle: analytics, maps, streams, calendars, etc.
 - A unified, standards-based API so you can easily create your own visualizations and integrations

It's the firmest grip you can have on your data. You have the ability to bring it home, see it and build on it. For the first time, you can start integrating your lifestyle in one place. You can gradually know everything that you did, what is happening of relevance to you, and what's predicted to happen in the future.

Creating visualizations, observers and agents is a great part of the fun. As developers, we have the chance to be at the cutting edge of the personal information revolution. We are given a big opportunity to explore and influence the way we will live, to provide greater understanding and better control of our lifestyles in a hyper-connected world.

Developers can easily:

 - Create powerful visualizations, using simple HTML, CSS and JS in under 100 lines of code
 - Create observers to gather more data in under 300 lines of code
 - Hack new and existing apps and devices to integrate with Manybots
 - Imagine best-in-class applications and agents that enable people to excel at one particular aspect of their life and provide integration, quantification, predictions and notifications

 
## Installation

Manybots is a Ruby on Rails application.

Before you install for the first time, please read the Tech Overview and Warnings section of this document. It includes important information, such as the requirements for installing and running Manybots on your system.

1. Get started by cloning the repo.

```
$ git clone https://github.com/manybots/manybots
```

2. Install Redis on your system (used by Resque to manage background jobs)

On Mac OS X, use Homebrew

```
$ brew install redis
$ redis-server /usr/local/etc/redis.conf
```
Use ctrl+d to detach the Redis server process.

3. Install Manybots stuff

Now go into the 'manybots' directory and install stuff:

```
$ cd manybots
$ bundle install
$ rails generate manybots_local:install
$ bundle exec rake db:migrate
```

Now let's install your first observer, and you're ready to run.

```
$ rails generate manybots_gmail:install
$ bundle exec rake db:migrate
```

## Running Manybots

Start the server and workers with

```
$ foreman start
```

Then point your browser to

'http://localhost:5000'

Create your account and get started! 

## Using Manybots

The principle is simple: aggregate activities, notifications and predictions to make your life easier, your future more manageable and your past more traceable.

The default installation includes the Gmail Observer, so you can start collecting your emails immediately.

You'll be able to see with whom, when and how much you communicate via email. Add more apps to collect more information and view it in even more forms.

## Adding Apps to Manybots (observers, visualizations, agents, etc.)

Go to the [App Catalogue](https://github.com/manybots/manybots/wiki/Applications-Catalogue) page on the Wiki and use the instructions for each one. It's very easy if you're familiar with Ruby on Rails.

## Creating Apps (observers, visualizations, agents, etc.)

Manybots is a Ruby on Rails application, but you can use any technology you like to create new observers and apps.

Visualizations, for example, can be plain HTML + JS + CSS apps. 

Rails developers will find it easy to create observers and agents: create them as mountable engines, and you'll be able to use Manybots' shared classes and methods to write a new observer from start to finish in under 300 lines of code.

Any app can use OAuth and the web API to add activities, notifications and predictions to Manybots.

To learn more, check out the [Creating Apps](https://github.com/manybots/manybots/wiki/Creating-Apps) page on the Wiki.

## Tech Overview and warnings

Manybots is based on Ruby on Rails. At this very early stage of release, please have Ruby 1.9.2+ working on your system before you get started. To install Manybots, check out the Installation section of this document.

Tech Overview:

- Ruby on Rails 3.2.1
- sqlite3 database in development, expects postgres in production (this might change rapidly)
- Redis database for workers (Resque gem used to manage workers)
- API request data formatted in Activity Streams (JSON)

Requirements: 

- Ruby 1.9.2
- latest Rubygems
- git
- sqlite 3
- redis

Warnings: 

- Hasn't been used with Ruby 1.9.3
- Won't work on 1.8 versions
- Hasn't been used on Windows
- There are no tests in the code at this point. Right, booooooh.

## Contributing

Manybots has the objective to use and promote standards, and therefore tries to invent as little as possible, and to only break ground when absolutely necessary. Not only does that provide for a more accessible and hopefuly sustainable approach, but it also endebts the project to the countless developers and contributors that made this design possible. Thank you to all!

It is also the work of a single guy helped here and there by colleagues and friends, working far away from the tech hubs. May this serve as a disclaimer for all shortcomings that you might find, and as an invitation to contribute to an open code base that enables everyone to enhance their digital lifestyles.

How to contribute:

 - use Github to report issues, fork and make pull requests (topic branches appreciated)
 - participate on the mailing list
 - spread the word


## Help

Use Github Issues and the Manybots development mailing list

http://groups.google.com/group/manybots-dev

## License

Manybots is released under the MIT license:

  - www.opensource.org/licenses/MIT
