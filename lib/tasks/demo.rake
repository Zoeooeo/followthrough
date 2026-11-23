namespace :demo do
  desc "Delete demo families and guest accounts older than a day"
  task clean_up: :environment do
    puts "Deleted #{DemoFamily.clean_up} demo account(s)."
  end
end
