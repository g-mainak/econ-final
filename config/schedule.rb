# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

set :environment, 'development'
set :output, '~/Gilt/cronlog'

every 1.hour, at: 20 do
	command 'date'
	command 'echo "Checking for Active Sales"'
	runner 'Sku::get_active'
end
every 1.hour, at: 50 do
	command 'date'
	command 'echo "Checking for Ended Sales"'
	runner 'Sku::get_ended'
end
every 1.day, at: '1:00 am' do
	command 'echo "printing days eneded sales"'
	runner 'Sku::print_ended'
end
