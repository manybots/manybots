Ok, first off this is not a preferred environment to run Manybots
It currently is not fully working. We still need to find a replacement or a fix for foreman

http://railsinstaller.org/

Watch the video for at least the first 3 minutes (the rest gets you started with a rails project, github and engineyard hosting platform)

While running the install make sure you set up git and ssh as they are needed to access the Manybots repository on Github
If you have problems make sure that the Git bin directory (default should be "C:/RailsInstaller/Git/bin") is in the PATH directory for at least your user.

Once we have ssh and git as command we can use in the console start up the git enabled console (default should be "C:/RailsInstaller/Git/git-cmd.bat")

--

Manybots Repo

Then run this command to clone the manybots repository (make sure you browse to the folder where you want the manybots code to be)

   git clone git@github.com:manybots/manybots.git

If you get errors about remote end "hanging up expectantly" you may have to deal with more technical problems. Google is probably you best friend.
If you have TortoiseGit installed this might cause problems with the instructions.

--

Redis Install

There is no official windows support for Redis but there are some ports that work (only tested on Windows 7 32bit)

   https://github.com/dmajkic/redis

Download 2.4.5 (others untested) and just run the redis-server executable from the appropriate folder (32bit/64bit)

Running this should open a console window that should report every 5 seconds how many clients the server has.
Keep this window open while you are running Manybots (it runs all the tasks in the background that get your data)

--

Open a console window and browse to the clone of manybots (e.g. C:/Sites/manybots)

Install all the require gems

   bundle install

You may see errors about the Gmail repo requiring Ore. To fix this run

   gem install ore-core

If you see problems with eventmachine try installing the latest eventmachine release

   gem install eventmachine --pre
or change the Gemfile to
   gem "thin", "1.3.1"
   gem "eventmachine", "1.0.0.beta.4"

you may also have to force the update if you still can't get bundle install to work
   bundle update eventmachine

Then you need to double check bundle install is finished. You want this to finish without errors.


Then run
   $ rails generate manybots_local:install

If you see ruby.exe error about libgcc_s_sjlj-1.dll being missing. You need to download

   http://dl.dropbox.com/u/8440706/Program64.zip

Extract the libstdc++-6.dll and libgcc_s_sjlj-1.dll into C:/RailsInstaller/Ruby1.9.3/bin
Run the install again 

Now install the migrate DB command to create all the SQLite stuff

   $ bundle exec rake db:migrate

Now onto the the first of the apps (the default Gmail observer - you can build more!)

   $ rails generate manybots_gmail:install
   $ bundle exec rake db:migrate

To start editing code we recommend using redcar. To install just run

   gem install redcar


Then run the web server

   foreman start