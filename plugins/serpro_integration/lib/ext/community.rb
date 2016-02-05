require_dependency 'community'

class Community

  settings_items :allow_sonar_integration, :type => :boolean, :default => false
  settings_items :allow_gitlab_integration, :type => :boolean, :default => true
  settings_items :allow_jenkins_integration, :type => :boolean, :default => true

  settings_items :serpro_integration_plugin_gitlab, :type => Hash, :default => {}
  settings_items :serpro_integration_plugin_jenkins, :type => Hash, :default => {}
  settings_items :serpro_integration_plugin_sonar, :type => Hash, :default => {}

  attr_accessible :allow_unauthenticated_comments, :allow_gitlab_integration, :allow_sonar_integration, :allow_jenkins_integration, :serpro_integration_plugin_gitlab, :serpro_integration_plugin_jenkins, :serpro_integration_plugin_sonar

  after_create :create_integration_projects, :if => lambda { |c| c.allow_serpro_integration?}

  def create_integration_projects

    if allow_gitlab_integration
      gitlab_integration = SerproIntegrationPlugin::GitlabIntegration.new(gitlab_host, gitlab_private_token)
      gitlab_project = gitlab_integration.create_gitlab_project(self)
      serpro_integration_plugin_gitlab[:project_id] = gitlab_project.id

      if allow_jenkins_integration
        jenkins_integration = SerproIntegrationPlugin::JenkinsIntegration.new(jenkins_host, jenkins_private_token, jenkins_user)

        jenkins_integration.create_jenkis_project(self, gitlab_project.path_with_namespace, gitlab_project.web_url, gitlab_project.http_url_to_repo)
        gitlab_integration.create_jenkins_hook(jenkins_integration.host)
      end
      
    end
  end

  def serpro_integration_plugin_settings
    @settings ||= Noosfero::Plugin::Settings.new(environment, SerproIntegrationPlugin)
  end

  def gitlab_group
    serpro_integration_plugin_gitlab[:group] || self.identifier
  end

  def gitlab_project_name
    serpro_integration_plugin_gitlab[:project_name] || self.identifier
  end

  def gitlab_host
    serpro_integration_plugin_settings.gitlab[:host]
  end

  def gitlab_private_token
    serpro_integration_plugin_settings.gitlab[:private_token]
  end

  def jenkins_host
    serpro_integration_plugin_settings.jenkins[:host]
  end

  def jenkins_private_token
    serpro_integration_plugin_settings.jenkins[:private_token]
  end

  def jenkins_user
    serpro_integration_plugin_settings.jenkins[:user]
  end

  def jenkins_project_name
    serpro_integration_plugin_jenkins[:project_name] || self.identifier
  end

  def allow_serpro_integration?
    return false if serpro_integration_plugin_settings.communities.blank? || serpro_integration_plugin_settings.communities[:templates].blank?
    allow = serpro_integration_plugin_settings.communities[:templates].include?(self.id.to_s)
    allow || serpro_integration_plugin_settings.communities[:templates].include?(self.template_id.to_s)
  end

end
