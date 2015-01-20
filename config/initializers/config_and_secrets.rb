#setup config and secrets

CONFIG = YAML.load_file("#{Rails.root.to_s}/config/config.yml")[Rails.env]
SECRETS = YAML.load_file("#{Rails.root.to_s}/config/config.yml")[Rails.env]
