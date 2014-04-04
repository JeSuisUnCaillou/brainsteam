namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    User.create!(name: "Caillou",
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

    ThreadTag.create!(name: "Real world", 
                      description: "About something real, or realizable")
    ThreadTag.create!(name: "Crazy stuff", 
                      description: "About whatever you can imagine, and even more")
    ThreadTag.create!(name: "Brainsteam",
                      description: "About Brainsteam and its features")
  end
end
