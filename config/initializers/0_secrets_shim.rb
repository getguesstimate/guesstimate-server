# Rails 7.2 removed `Rails.application.secrets`. This app still reads its config
# from config/secrets.yml (with ERB + per-environment ENV interpolation), so we
# restore a minimal, read-only `secrets` accessor backed by that file.
#
# Loaded first (the `0_` prefix sorts ahead of other initializers) so that any
# initializer using `Rails.application.secrets` continues to work.
require "erb"
require "yaml"

module SecretsShim
  def secrets
    @secrets ||= begin
      path = Rails.root.join("config", "secrets.yml")
      parsed =
        if path.exist?
          erb = ERB.new(path.read).result
          YAML.safe_load(erb, aliases: true, permitted_classes: [Symbol]) || {}
        else
          {}
        end
      env_config = parsed[Rails.env] || {}
      options = ActiveSupport::OrderedOptions.new
      env_config.each { |key, value| options[key.to_sym] = value }
      options
    end
  end
end

Rails::Application.prepend(SecretsShim)
