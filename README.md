BlueSource
==============
[![Build Status](https://travis-ci.org/Orasi/blue-source.svg?branch=master)](http://travis-ci.org/Orasi/blue-source)
[![Coverage Status](https://coveralls.io/repos/Orasi/blue-source/badge.png?branch=simplecov-integration)](https://coveralls.io/r/Orasi/blue-source?branch=simplecov-integration)

BlueSource is an employee information tracking system. Its creation came from the need to have a universal and collaborative tool for storing employee records. By using BlueSource, a user is able to maintain information about employees, projects, and time off. All data is stored on a central database allowing employees to be transferred between projects and functional teams securely and efficiently. BlueSource uses your current Orasi user credentials, so information can be accessed securely without the need for creating a separate account.

BlueSource Team:

    Lew Gordon - Development
    David Quach - Development
    Perry Thomas - Project Management
    Adam Thomas - Business Analysis, Design
    John Martin - Functional Testing
    Lateef Livers - Automation/Functional Testing
    Kevin Hedgecock - Functional Testing
    Jason Trogdon - Functional Testing
    Linley Love - Data Entry, User Acceptance Testing

# Installation 

## Minimum Requirements - (mac)
1. **Ruby:** The language that the Rails framework runs on. 
2. **Rails:** The framework that will be used to run the BlueSource application.
3. **Text editor or IDE (Eclipse):** Any text editor will do, it'll just be used to edit files (I'm currently using Eclipse with an Aptana plugin, let me know if you want to setup eclipse). 
4. **Github account:** Github is used for version control and pulling the code down from the website. 

## Setup - (mac)

First install ruby using RVM (Ruby Version Manager). This will help manage your projects easier. 
To do this, open terminal and type:

```bash
$ \curl -sSL https://get.rvm.io | bash -s stable
$ rvm install 2.1.1
$ ruby -v 
```
   **NOTE** This command installs RVM and Ruby 2.1.1 (You can use any version of ruby you want). Then checks if it properly installed. 

Then install rails by doing:

```bash
$ gem install rails
$ rails -v
```

   **NOTE** This should install rails, also checking the version, and the `bundle gem` which you will need to setup your    project's gems. 

Now you will need to get git. To do this go to the website and download the app for github which gives you the gui interface and the command line tools. To check if git installed properly type this into terminal:

```bash
$ git --version
```

   **RECOMMENDED** To learn more about git there is a really good guide on try.github.com to start you in the right        direction into understand what git does. 

The final step is to grab the BlueSource code from github repository. First you want to cd into the directory that you want the repository to be in (I just put it in my Documents folder):

```ruby 
$ cd ~/Documents
```
Then you can `clone` the BlueSource repository into that directory by typing this into the terminal:

```bash
$ git clone https://github.com/Orasi/blue-source.git
``` 
   **NOTE** This clones whatever files are in the repository to your local machine in the directory that you `cd` into. 

## Running BlueSource Locally
Now to run the web application locally, you have to setup all the gem dependencies for the bluesource project. So first `cd` into your the bluesource folder:

```bash
$ cd ~/Documents/blue-source/
```

then you have to run `bundle install`. This will install everything that is in the `Gemfile`. 

```bash
$ bundle install
```
   **NOTE** If there any errors -usually with installing a gem- then you will not be able to run the project. I had a problem installing the postgresql gem. So I had to use a work around to get it to install. I downloaded postgresql from http://postgresapp.com. Then I installed the gem using the configurations from the app by typing this into the terminal: 

```bash
$ gem install pg -- --with-pg-config=/Applications/Postgres.app/Contents/Versions/9.3/bin/pg_config
``` 
If that did not work you have to check where your pg_config is stored in your postgress.app. 

After everything installs then you run `rails server` in the terminal while you are in the root directory of the blue-source folder. 

```bash
$ rails server
```
Then if you go to http://localhost:3000 in your browser. Then you should see the BlueSource web app login page. 

   











