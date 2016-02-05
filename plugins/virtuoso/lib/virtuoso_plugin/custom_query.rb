class VirtuosoPlugin::CustomQuery < Noosfero::Plugin::ActiveRecord

  belongs_to :environment

  attr_accessible :enabled, :environment, :query, :template, :name, :stylesheet

  validates_presence_of :name

end
