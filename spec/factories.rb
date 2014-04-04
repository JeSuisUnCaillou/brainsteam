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
    last_message_date DateTime.now    

    factory :threadhead_and_friends do 
      after(:create) do |threadhead|
         threadhead.link_tag!(ThreadTag.first.id)
         user = User.first
         user ||= FactoryGirl.create(:user)
         m = FactoryGirl.create(:message, user: user,
                                          title: "thread #{threadhead.id}",
                                          threadhead_id: threadhead.id)
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
    sequence(:description) { |n| "description #{n}" }
  end

  factory :thread_tag_relationship do
    threadhead
    thread_tag
  end
  
  factory :message do
    sequence(:title) { |n| "Titre " + n.to_s }
    sequence(:text) { |n| "Message " + n.to_s }
    user
    threadhead

    factory :message_and_friends do
      after(:create) do |message|
        p_node = Treenode.find_by(obj: message.threadhead)
        tn = FactoryGirl.create(:treenode, obj: message, parent_node: p_node)
      end
    end
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
