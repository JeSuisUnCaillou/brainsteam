namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    User.create!(name: "Example User",
                 email: "igorlacroute@gmail.com",
                 password: "99brainsteam!",
                 password_confirmation: "99brainsteam!",
                 admin: true)
    99.times do |n|
      name  = Faker::Name.name
      email = "example-#{n+1}@railstutorial.org"
      password  = "password"
      User.create!(name: name,
                   email: email,
                   password: password,
                   password_confirmation: password)
    end

    ThreadTag.create!(name: "Real world")
    ThreadTag.create!(name: "Crazy stuff")
  end
end
