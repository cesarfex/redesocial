require File.dirname(__FILE__) + '/../test_helper'

class VirtuosoPluginAdminControllerTest < ActionController::TestCase

  attr_reader :environment

  def setup
    @environment = Environment.default
    @profile = create_user('profile').person
    login_as(@profile.identifier)
  end

  def mock_settings
    { :virtuoso_uri=>"http://virtuoso.noosfero.com",
      :virtuoso_username=>"username",
      :virtuoso_password=>"password",
      :virtuoso_readonly_username=>"readonly_username",
      :virtuoso_readonly_password=>"readonly_password",
      :dspace_servers=>[
        {"dspace_uri"=>"http://dspace1.noosfero.com","last_harvest" => 5 },
        {"dspace_uri"=>"http://dspace2.noosfero.com"},
        {"dspace_uri"=>"http://dspace3.noosfero.com", "last_harvest" => 0},
        {"dspace_uri"=>"http://dspace4.noosfero.com", "last_harvest" => nil},
        {"dspace_uri"=>"http://dspace5.noosfero.com", "last_harvest" => 9},
      ]
    }
  end

  should 'save virtuoso plugin settings' do
    post :index, :settings => mock_settings
    @settings = Noosfero::Plugin::Settings.new(environment.reload, VirtuosoPlugin)
    assert_equal 'http://virtuoso.noosfero.com', @settings.settings[:virtuoso_uri]
    assert_equal 'username', @settings.settings[:virtuoso_username]
    assert_equal 'password', @settings.settings[:virtuoso_password]
    assert_equal 'readonly_username', @settings.settings[:virtuoso_readonly_username]
    assert_equal 'readonly_password', @settings.settings[:virtuoso_readonly_password]
    assert_equal 'http://dspace1.noosfero.com', @settings.settings[:dspace_servers][0][:dspace_uri]
    assert_equal 'http://dspace2.noosfero.com', @settings.settings[:dspace_servers][1][:dspace_uri]
    assert_equal 'http://dspace3.noosfero.com', @settings.settings[:dspace_servers][2][:dspace_uri]
    assert_equal  "9", @settings.settings[:dspace_servers][4][:last_harvest]
    assert_redirected_to :action => 'index'
  end

  should 'redirect to index after save' do
    post :index, :settings => mock_settings
    assert_redirected_to :action => 'index'
  end

  should 'create delayed job to start harvest on force action' do
    post :index, :settings => mock_settings
    harvest = VirtuosoPlugin::DspaceHarvest.new(environment, {"dspace_uri"=>"http://dspace1.noosfero.com", "last_harvest" => 5 })
    assert !harvest.find_job.present?
    get :force_harvest
    assert harvest.find_job.present?
  end

  should 'force harvest from start' do
    post :index, :settings => mock_settings
    get :force_harvest, :from_start => true
    harvest = VirtuosoPlugin::DspaceHarvest.new(environment, {"dspace_uri"=>"http://dspace4.noosfero.com", "last_harvest" => nil})
    assert harvest.find_job.present?
    assert_equal nil, harvest.settings.last_harvest
  end

  should 'not create delayed job to start harvest on force action without settings' do
    post :index, :settings => mock_settings
    harvest = VirtuosoPlugin::DspaceHarvest.new(environment)
    assert !harvest.find_job.present?, "testing if no job is running"
    get :force_harvest
    assert !harvest.find_job.present?, "testing if no job is running again"
  end

end
