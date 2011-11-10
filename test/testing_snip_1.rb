# -*- coding: utf-8 -*-
#require 'test_helper'

class Admin::GiftsControllerTest < ActionController::TestCase

  include WebratHelpers

  def setup
    @request.session[:typus_user_id] = create_typus_admin.id

    Factory :user, 
            :email => 'm.roy@lovgroup.com', 
            :id => 500, 
            :pseudo => 'user1'
    Factory :user, 
            :email => 'l.cabourdin@banijay.com', 
            :id => 501, 
            :pseudo => 'user2'
    Factory :user, 
            :email => 'egn@octo.com', 
            :id => 502, 
            :pseudo => 'user3'

    2.times do
      Factory :gift, :amount => 5
    end
  end

  test "sets sum of the amounts of the gifts without filter." do
    get :index
    assert_equal 10.to_f, assigns(:def_sum).to_f
  end

  test "sets sum of the amounts of the gifts with filter." do
    Timecop.travel(Time.now - 1.year) do
      Factory :gift, :amount => 100
    end
    get :index,
      :created_at => { :from => Time.now.beginning_of_month.strftime('%d/%m/%Y'),
                       :to => Time.now.end_of_month.strftime('%d/%m/%Y') }
    assert_equal 10.to_f, assigns(:def_sum).to_f
  end

  test "create some Gift objects with valid data" do
    assert_difference 'Gift.count', 3 do       
      post :create, "gift" => {
        "comment"=>"toto", 
        "users_list"=>"l.cabourdin@banijay.com\r\nm.roy@lovgroup.com\r\negn@octo.com            ", 
        "user_content_type"=>'emails',
        "amount"=>"555"
      }
    end 
    assert_redirected_to :action => :index
  end

  test "create some Gift with empty user field" do
    assert_difference 'Gift.count', 0 do
      post :create, "gift" => {
        "comment"=>"toto", 
        "users_list"=>"", 
        "amount"=>"500",
        "user_content_type"=>'emails',
      }
    end
    assert_redirected_to :action => :new
  end

  test "create some Gift with empty amount" do
    assert_difference 'Gift.count', 0 do
      post :create, "gift" => {
        "comment"=>"toto", 
        "users_list"=>"m.roy@lovgroup.com", 
        "amount"=>"",
        "user_content_type"=>'emails'
      }
    end
    assert_redirected_to :action => :new
  end

  test "create some Gift with empty comment" do
    assert_difference 'Gift.count', 1 do
      post :create, "gift" => {
        "comment"=>"", 
        "users_list"=>"m.roy@lovgroup.com", 
        "amount"=>"300",
        "user_content_type"=>'emails',
      }
    end
    assert_redirected_to :action => :index
  end

  test "create some Gift with some users containing one user unknown (rollback all)" do
    assert_difference 'Gift.count', 0 do
      post :create, "gift" => {
        "comment"=>"toto", 
        "users_list"=>"l.cabourdin@banijay.com\r\nm.roy@lovgroup.com\r\nasdsadsad@dasddas.com", 
        "user_content_type"=>'emails',
        "amount"=>"500"
      }
    end
    assert_redirected_to :action => :new
  end

  test "create some Gift with USER ID" do
    assert_difference 'Gift.count', 3 do
      post :create, "gift" => {
        "comment"=>"toto", 
        "users_list"=>"500\r\n501\r\n502", 
        "user_content_type"=>'ids',
        "amount"=>"500"
      }
    end
    assert_redirected_to :action => :index
  end

  test "create some Gift with USER PSEUDOS" do
    assert_difference 'Gift.count', 3 do
      post :create, "gift" => {
        "comment"=>"toto", 
        "users_list"=>"user1\r\nuser2\r\nuser3", 
        "user_content_type"=>'usernames',
        "amount"=>"500"
      }
    end
    assert_redirected_to :action => :index
  end

  test "create some Gift with USER PSEUDOS / MAILS" do
    assert_difference 'Gift.count', 0 do
      post :create, "gift" => {
        "comment"=>"toto", 
        "users_list"=>"user1\r\nuser2\r\nl.cabourdin@banijay.com", 
        "user_content_type"=>'usernames',
        "amount"=>"500"
      }
    end
    assert_redirected_to :action => :new
  end

  test "create some Gift with newline excessing" do
    assert_difference 'Gift.count', 2 do
      post :create, "gift" => {
        "comment"=>"toto", 
        "users_list"=>"user1\r\nuser2\r\n", 
        "user_content_type"=>'usernames',
        "amount"=>"500"
      }
    end
    assert_redirected_to :action => :index
  end

end
