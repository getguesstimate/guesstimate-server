namespace :factory_girl do
  desc "Verify that all FactoryGirl factories are valid"
  task :lint, [:path] => :environment do |t, args|
    if Rails.env.test?
      begin
        DatabaseCleaner.start
        if args.path.present?
          factories = FactoryGirl.factories.select do |factory|
            factory.name.to_s =~ /#{args.path[0]}/
          end
          FactoryGirl.lint factories
        else
          FactoryGirl.lint
        end
      ensure
        DatabaseCleaner.clean
      end
    else
      system("bundle exec rake factory_girl:lint RAILS_ENV='test'")
    end
  end
end
