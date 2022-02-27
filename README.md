# TeamHealth

Welcome to the the TeamHealth-6 app, created by Team 6 for MSCI 342! Please see installation and deployment 
instructions for getting started!

## How to install locally?

1. Please email anyone on our team to add you to the repository.
2. Please git clone the repository by doing `git clone git@github.com:UWaterlooMSCI342/W22-Team-6.git`
3. Please run `cd W22-Team-6` into the repository
4. Please run `bundle install` to install all the required gems
5. Run `rails db:create db:migrate db:seed` to create & seed the Database
6. You have now initialized the application for local use by running 'rails server'. You can login as a professor using
email as `msmucker@gmail.com` and password as `professor`. 


## How to deploy to heroku?

1. Please login, or create an account for Heroku using `heroku login`
2. Please run `heroku apps:create appName` and replace "appName" with the desired app name
3. Please run 'git push heroku main' to push the repository to the Heroku main
4. Please run 'heroku run rails db:migrate` to migrate the database to Heroku
5. Please run 'heroku run rails db:seed` to insert the seed data to Heroku

## Assumptions
This guide assumes that you have Ruby, Rails, and PostgreSQL installed on your local machine for local development.
If deploying on Heroku, it assumes that you already have a Github and Heroku account set up.
