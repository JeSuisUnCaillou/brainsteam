FactoryGirl.define do

  factory :user do
    sequence(:name)  { |n| "Person #{n}" }
    sequence(:email) { |n| "person_#{n}@example.com"}
    password "foobar"
    password_confirmation "foobar"

    factory :admin do
      admin true
    end

  end

  factory :threadhead do
    sequence(:private) { |n| false } 
    
    factory :threadhead_with_tag do 
      after(:create) { |threadhead| threadhead.link_tag!(ThreadTag.first.id) }
    end

    factory :private_threadhead do
      private true
    end
  end

  factory :thread_tag do
    sequence(:name) { |n| ["Real world", "Crazy stuff"][n%2] }
  end

  factory :thread_tag_relationship do
    #sequence(:thread_tag_id) { |n| n%2 }
    threadhead
    thread_tag
  end
  
end
