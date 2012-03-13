require 'test_helper'

class ActivitiesControllerTest < ActionController::TestCase
  
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
  
  # include Devise::TestHelpers
  
  # setup do
  #    @user = users(:one)
  #    @activity = activities(:one)
  #    @actor = activity_objects(:actor)
  #    @object = activity_objects(:obj)
  #    sign_in :user, @user
  #  end

  # test "should validate activity" do
  #   # Test that the initial object is valid
  #   @activity.user = @user
  #   @activity.actor = @actor
  #   @activity.object = @object
  #   assert(@activity.valid?)
  # end
  # 
  # test "should create activity" do
  #   assert_difference('Activity.count') do
  #     post :create, :activity => @activity.attributes.merge({
  #       :object_attributes=>@object.attributes, 
  #       :actor_attribtues => @actor.attributes
  #     })
  #   end
  # 
  #   assert_redirected_to activity_path(assigns(:activity))
  # end
  
  # 
  # test "should get index" do
  #   get :index
  #   assert_response :success
  #   assert_not_nil assigns(:activities)
  # end
  # 
  # test "should get new" do
  #   get :new
  #   assert_response :success
  # end
  #   
  # test "should show activity" do
  #   get :show, :id => @activity.to_param
  #   assert_response :success
  # end
  # 
  # test "should get edit" do
  #   get :edit, :id => @activity.to_param
  #   assert_response :success
  # end
  # 
  # test "should update activity" do
  #   put :update, :id => @activity.to_param, :activity => @activity.attributes
  #   assert_redirected_to activity_path(assigns(:activity))
  #   # assert_response :success
  # end
  # 
  # test "should destroy activity" do
  #   assert_difference('Activity.count', -1) do
  #     delete :destroy, :id => @activity.to_param
  #   end
  # 
  #   assert_redirected_to activities_path
  # end
end
