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
    
    factory :threadhead_and_friends do 
      after(:create) do |threadhead|
         threadhead.link_tag!(ThreadTag.first.id)
         user = User.first
         user ||= FactoryGirl.create(:user)
         m = FactoryGirl.create(:message, user: user, title: threadhead.id)
         tn = FactoryGirl.create(:treenode, obj: threadhead)
         tn_m = FactoryGirl.create(:treenode, obj: m, parent_node: tn)
       end
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
  
  factory :message do
    sequence(:title) { |n| "Titre n°" + n.to_s }
    sequence(:text) { |n| "Message n°" + n.to_s  }
    user
  end

  factory :treenode do
    association :obj, factory: :threadhead
    parent_node nil
  end

  factory :path do
    user
    threadhead
    treenode
  end

end
