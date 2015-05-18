require 'sinatra'
#require 'json'
#require 'pg'
#require 'HTTPClient'
#require 'net/http'
#require 'uri'
#require 'nokogiri'
#require 'cgi'
#require 'socket'
#require 'net/smtp'
require 'sinatra/reloader'
require 'date'
require 'time'
#require_relative "./Marval Soap Requests.rb"

#	border: 2px solid #90C695;


set :port, 8088
set :environment, :development
set :server, 'webrick'

class MarvalData
	def initialize
	end

	def get_lcr_data ( lcr_id )
	end

	def get_rfc_data ( rfc_id )
	end
end


class DatabaseData
	def initialize
	end

	def get_lcr_contacts ( lcr_id )
	end

	def get_lcr_information
	end
end


class TimeData
	def days_in_month(year, month)
	  Date.new(year, month, -1).day
	end

	def previous_month_name(month)
		previous_month = month.to_i - 1
		if previous_month == 0
			previous_month = 12
		end
		previous_month = Time.parse('01.' + previous_month.to_s + '.2015')
		previous_month_name = previous_month.strftime("%b")
	end

	def subsequent_month_name(month)
		subsequent_month = month.to_i + 1
		if subsequent_month == 13
			subsequent_month = 1
		end
		subsequent_month = Time.parse('01.' + subsequent_month.to_s + '.2015')
		subsequent_month_name = subsequent_month.strftime("%b")
	end
end


get '/home_month_view' do
	if params["arrow_value"].nil? || params["arrow_value"].empty?
		puts 'WARNING: No year was entered'
		@arrow_value = 'no_value'
	else
		@arrow_value = params["arrow_value"]
	end

	if params["current_month_year"].nil? || params["current_month_year"].empty?
		puts 'WARNING: No current_month_year was entered'
		current_time = Time.now
		first_weekday_number = current_time.strftime("%m%Y")
		@current_month_year = first_weekday_number.to_s
	else
		@current_month_year = params["current_month_year"]
	end

	time_data_obj = TimeData.new

	previous_month_days = []
	subsequent_month_days = []
	previous_month =  0
	previous_month_name =  ''
	subsequent_month_name =  0

	current_month = @current_month_year[0..1].to_i
	current_year = @current_month_year[2..5].to_i

	if @arrow_value == "positive"
		current_month = current_month + 1
		if current_month == 13
			current_year = current_year + 1
			current_month = 1
		end
	elsif @arrow_value == "minus"
		current_month = current_month - 1
		if current_month == 0
			current_year = current_year - 1
			current_month = 12
		end
	end

	subsequent_month_name = time_data_obj.subsequent_month_name(current_month)
	previous_month_name = time_data_obj.previous_month_name(current_month)

	number_of_days = time_data_obj.days_in_month(current_year, current_month)
	firstday_of_month = Time.parse('01.' + current_month.to_s + '.' + current_year.to_s)
	lastday_of_month = Time.parse(number_of_days.to_s + '.' + current_month.to_s + '.' + current_year.to_s)
	first_weekday_number = firstday_of_month.strftime("%w")
	last_weekday_number = lastday_of_month.strftime("%w")
	month_name = firstday_of_month.strftime("%B")

	if first_weekday_number.to_i == 1
		puts 'First day of the month is a Monday'
	else
		previous_month = current_month - 1
		previous_year = current_year
		if previous_month == 0
			previous_year = previous_year - 1
			previous_month = 12
		end

		lastday_of_month = time_data_obj.days_in_month(previous_year, previous_month)
		if first_weekday_number.to_i == 0
			first_weekday_number = 7
		end

		weekday_number = first_weekday_number.to_i - 2
		previous_first = lastday_of_month.to_i - (weekday_number)
		previous_month_days = (previous_first.to_i..lastday_of_month.to_i).to_a
	end

	if last_weekday_number.to_i == 0
		puts 'Last day of the month is a Sunday'
	else
		additional_days = 7 - last_weekday_number.to_i
		subsequent_month_days = (1..additional_days).to_a
	end

	if current_month.to_s.length == 1
		current_month = '0' + current_month.to_s
	end

	@current_month_year = current_month.to_s + current_year.to_s
	@month_year = month_name + ' ' + current_year.to_s
	@previous_month_days = previous_month_days
	@previous_month = previous_month_name.to_s
	@subsequent_month = subsequent_month_name.to_s
	@current_month_days = number_of_days
	@subsequent_month_days = subsequent_month_days
	erb :dashboard_month_view
end



get '/home_week_view' do
	time_data_obj = TimeData.new
	monday = ''
	month = ''
	year = ''

	if params["current_monday_month_year"].nil? || params["current_monday_month_year"].empty?
		puts 'WARNING: No current_monday_month_year was entered'
		current_time = Time.now
		weekday_number = current_time.strftime("%w")
		current_day = current_time.strftime("%d")
		current_month = current_time.strftime("%m")
		current_year = current_time.strftime("%Y")
		if weekday_number.to_i == 1
			@current_monday_month_year = current_day.to_s + current_month.to_s + current_year.to_s
		else
			difference = weekday_number.to_i - 1
			monday = current_day.to_i - difference
			if monday < 0
				previous_month = current_month - 1

				if previous_month == 0
					previous_year = previous_year - 1
					previous_month = 12
					lastday_of_month = time_data_obj.days_in_month(previous_year, previous_month)
				else
					lastday_of_month = time_data_obj.days_in_month(current_year, previous_month)
				end

				monday = lastday_of_month.to_i - difference
				@current_monday_month_year = monday.to_s + current_month.to_s + current_year.to_s
			else
        if monday.to_s.length == 1
					monday = "0" + monday.to_s
        end
        if current_month.to_s.length == 1
          current_month = "0" + current_month.to_s
        end
				@current_monday_month_year = monday.to_s + current_month.to_s + current_year.to_s
			end
		end
	else
		@current_monday_month_year = params["current_monday_month_year"]
	end

	time_data_obj = TimeData.new

	subsequent_month = 0
	subsequent_year = 0
	previous_month = 0
	previous_year = 0
	previous_month_days = []
	subsequent_month_days = []
	firstday_of_month = 'empty'
	month_name = ''

	input_monday = @current_monday_month_year[0..1].to_i
	input_month = @current_monday_month_year[2..3].to_i
	input_year = @current_monday_month_year[4..7].to_i

	@weekdays = {}
	@weekday_array = []
	@weekday_names = []

	@weekday_names.push("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday")

	number_of_days = time_data_obj.days_in_month(input_year, input_month)

	if params["arrow_value"].nil? || params["arrow_value"].empty?
		@arrow_value = 'no_value'
		plus_six = input_monday+6
		count = -1
		(input_monday..plus_six).each do |day|
			@weekdays[day] = "current"
			count = count + 1
			@weekday_array.push(@weekday_names[count] + ", " + day.to_s)
		end
	else
		@arrow_value = params["arrow_value"]
		plus_six = input_monday+6

		if @arrow_value == "positive"
			new_monday = input_monday + 7
			new_month = input_month
			new_year = input_year
			subsequent_weekdays = new_monday + 6

			if new_monday > number_of_days
				new_month = input_month + 1
				if new_month == 13
					new_year = input_year + 1
					new_month = 1
				end
				new_monday = new_monday - number_of_days
				subsequent_weekdays = new_monday + 6
				count = -1
				(new_monday..subsequent_weekdays).each do |day|
					@weekdays[day] = "current"
					count = count + 1
					@weekday_array.push(@weekday_names[count] + ", " + day.to_s)
				end
				firstday_of_month = Time.parse('01.' + new_month.to_s + '.' + new_year.to_s)
				month_name = firstday_of_month.strftime("%B")

			elsif subsequent_weekdays > number_of_days
				difference = subsequent_weekdays - number_of_days
				current_weekdays = (new_monday..number_of_days).to_a
				subsequent_weekdays = (1..difference).to_a
				current_weekdays.push(*subsequent_weekdays)
				count = -1
				current_weekdays.each do |day|
					@weekdays[day] = "current"
					count = count + 1
					@weekday_array.push(@weekday_names[count] + ", " + day.to_s)
				end

			else
				count = -1
				(new_monday..subsequent_weekdays).each do |day|
					@weekdays[day] = "current"
					count = count + 1
					@weekday_array.push(@weekday_names[count] + ", " + day.to_s)
				end
			end

		elsif @arrow_value == "minus"
			new_monday = input_monday - 7
			new_month = input_month
			new_year = input_year
			subsequent_weekdays = new_monday + 6

			if new_monday <= 0
				new_month = input_month - 1
				if new_month == 0
					new_year = input_year - 1
					new_month = 12
				end
				previous_number_of_days = time_data_obj.days_in_month(new_year, new_month)
				difference = new_monday + 6
				new_monday = new_monday + previous_number_of_days

				current_weekdays = (new_monday..previous_number_of_days).to_a
				subsequent_weekdays = (1..difference).to_a
				current_weekdays.push(*subsequent_weekdays)
				count = -1
				current_weekdays.each do |day|
					@weekdays[day] = "current"
					count = count + 1
					@weekday_array.push(@weekday_names[count] + ", " + day.to_s)
				end

				firstday_of_month = Time.parse('01.' + new_month.to_s + '.' + new_year.to_s)
				month_name = firstday_of_month.strftime("%B")
			else
				count = -1
				(new_monday..subsequent_weekdays).each do |day|
					@weekdays[day] = "current"
					count = count + 1
					@weekday_array.push(@weekday_names[count] + ", " + day.to_s)
				end
			end

		end
		(new_monday.to_s.length == 1) ? (new_monday = '0' + new_monday.to_s) : (puts 'do nothing')
		(new_month.to_s.length == 1) ? (new_month = '0' + new_month.to_s) : (puts 'do nothing')
		@current_monday_month_year = new_monday.to_s + new_month.to_s + new_year.to_s
	end

	if firstday_of_month == 'empty'
		firstday_of_month = Time.parse('01.' + input_month.to_s + '.' + input_year.to_s)
		month_name = firstday_of_month.strftime("%B")
	end

	if new_monday.nil?
		subsequent_monday = input_monday.to_i + 7
		previous_monday = input_monday.to_i - 7
	else
		subsequent_monday = new_monday.to_i + 7
		previous_monday = new_monday.to_i - 7
	end

	if subsequent_monday > number_of_days
		if new_month.nil?
			previous_month_name = '<'
			subsequent_month_name = time_data_obj.subsequent_month_name(input_month)
		else
			previous_month_name = '<'
			subsequent_month_name = time_data_obj.subsequent_month_name(new_month)
		end
	elsif previous_monday <= 0
		if new_month.nil?
			previous_month_name = time_data_obj.previous_month_name(input_month)
			subsequent_month_name = '>'
		else
			previous_month_name = time_data_obj.previous_month_name(new_month)
			subsequent_month_name = '>'
		end
	else
		previous_month_name = '<'
		subsequent_month_name = '>'
	end


	@current_monday_month_year
	@month_year = month_name + ' ' + input_year.to_s
  @weekday_array
	@weekdays
	@previous_month = previous_month_name.to_s
	@subsequent_month = subsequent_month_name.to_s
	erb :dashboard_week_view
end



get '/new_lcr' do
	erb :dashboard_new_lcr
end

get '/new_deployment' do
	time_data_obj = TimeData.new
	monday = ''
	month = ''
	year = ''

	if params["current_monday_month_year"].nil? || params["current_monday_month_year"].empty?
		puts 'WARNING: No current_monday_month_year was entered'
		current_time = Time.now
		weekday_number = current_time.strftime("%w")
		current_day = current_time.strftime("%d")
		current_month = current_time.strftime("%m")
		current_year = current_time.strftime("%Y")
		if weekday_number.to_i == 1
			@current_monday_month_year = current_day.to_s + current_month.to_s + current_year.to_s
		else
			difference = weekday_number.to_i - 1
			monday = current_day.to_i - difference
			if monday < 0
				previous_month = current_month - 1

				if previous_month == 0
					previous_year = previous_year - 1
					previous_month = 12
					lastday_of_month = time_data_obj.days_in_month(previous_year, previous_month)
				else
					lastday_of_month = time_data_obj.days_in_month(current_year, previous_month)
				end

				monday = lastday_of_month.to_i - difference
				@current_monday_month_year = monday.to_s + current_month.to_s + current_year.to_s
			else
				if monday.to_s.length == 1
					monday = "0" + monday.to_s
				end
				if current_month.to_s.length == 1
					current_month = "0" + current_month.to_s
				end
				@current_monday_month_year = monday.to_s + current_month.to_s + current_year.to_s
			end
		end
	else
		@current_monday_month_year = params["current_monday_month_year"]
	end

	time_data_obj = TimeData.new

	subsequent_month = 0
	subsequent_year = 0
	previous_month = 0
	previous_year = 0
	previous_month_days = []
	subsequent_month_days = []
	firstday_of_month = 'empty'
	month_name = ''

	input_monday = @current_monday_month_year[0..1].to_i
	input_month = @current_monday_month_year[2..3].to_i
	input_year = @current_monday_month_year[4..7].to_i

	@weekdays = {}
	@weekday_array = []
	@weekday_names = []

	@weekday_names.push("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday")

	number_of_days = time_data_obj.days_in_month(input_year, input_month)

	if params["arrow_value"].nil? || params["arrow_value"].empty?
		@arrow_value = 'no_value'
		plus_six = input_monday+6
		count = -1
		(input_monday..plus_six).each do |day|
			@weekdays[day] = "current"
			count = count + 1
			@weekday_array.push(@weekday_names[count] + ", " + day.to_s)
		end
	else
		@arrow_value = params["arrow_value"]
		plus_six = input_monday+6

		if @arrow_value == "positive"
			new_monday = input_monday + 7
			new_month = input_month
			new_year = input_year
			subsequent_weekdays = new_monday + 6

			if new_monday > number_of_days
				new_month = input_month + 1
				if new_month == 13
					new_year = input_year + 1
					new_month = 1
				end
				new_monday = new_monday - number_of_days
				subsequent_weekdays = new_monday + 6
				count = -1
				(new_monday..subsequent_weekdays).each do |day|
					@weekdays[day] = "current"
					count = count + 1
					@weekday_array.push(@weekday_names[count] + ", " + day.to_s)
				end
				firstday_of_month = Time.parse('01.' + new_month.to_s + '.' + new_year.to_s)
				month_name = firstday_of_month.strftime("%B")

			elsif subsequent_weekdays > number_of_days
				difference = subsequent_weekdays - number_of_days
				current_weekdays = (new_monday..number_of_days).to_a
				subsequent_weekdays = (1..difference).to_a
				current_weekdays.push(*subsequent_weekdays)
				count = -1
				current_weekdays.each do |day|
					@weekdays[day] = "current"
					count = count + 1
					@weekday_array.push(@weekday_names[count] + ", " + day.to_s)
				end

			else
				count = -1
				(new_monday..subsequent_weekdays).each do |day|
					@weekdays[day] = "current"
					count = count + 1
					@weekday_array.push(@weekday_names[count] + ", " + day.to_s)
				end
			end

		elsif @arrow_value == "minus"
			new_monday = input_monday - 7
			new_month = input_month
			new_year = input_year
			subsequent_weekdays = new_monday + 6

			if new_monday <= 0
				new_month = input_month - 1
				if new_month == 0
					new_year = input_year - 1
					new_month = 12
				end
				previous_number_of_days = time_data_obj.days_in_month(new_year, new_month)
				difference = new_monday + 6
				new_monday = new_monday + previous_number_of_days

				current_weekdays = (new_monday..previous_number_of_days).to_a
				subsequent_weekdays = (1..difference).to_a
				current_weekdays.push(*subsequent_weekdays)
				count = -1
				current_weekdays.each do |day|
					@weekdays[day] = "current"
					count = count + 1
					@weekday_array.push(@weekday_names[count] + ", " + day.to_s)
				end

				firstday_of_month = Time.parse('01.' + new_month.to_s + '.' + new_year.to_s)
				month_name = firstday_of_month.strftime("%B")
			else
				count = -1
				(new_monday..subsequent_weekdays).each do |day|
					@weekdays[day] = "current"
					count = count + 1
					@weekday_array.push(@weekday_names[count] + ", " + day.to_s)
				end
			end

		end
		(new_monday.to_s.length == 1) ? (new_monday = '0' + new_monday.to_s) : (puts 'do nothing')
		(new_month.to_s.length == 1) ? (new_month = '0' + new_month.to_s) : (puts 'do nothing')
		@current_monday_month_year = new_monday.to_s + new_month.to_s + new_year.to_s
	end

	if firstday_of_month == 'empty'
		firstday_of_month = Time.parse('01.' + input_month.to_s + '.' + input_year.to_s)
		month_name = firstday_of_month.strftime("%B")
	end

	if new_monday.nil?
		subsequent_monday = input_monday.to_i + 7
		previous_monday = input_monday.to_i - 7
	else
		subsequent_monday = new_monday.to_i + 7
		previous_monday = new_monday.to_i - 7
	end

	if subsequent_monday > number_of_days
		if new_month.nil?
			previous_month_name = '<'
			subsequent_month_name = time_data_obj.subsequent_month_name(input_month)
		else
			previous_month_name = '<'
			subsequent_month_name = time_data_obj.subsequent_month_name(new_month)
		end
	elsif previous_monday <= 0
		if new_month.nil?
			previous_month_name = time_data_obj.previous_month_name(input_month)
			subsequent_month_name = '>'
		else
			previous_month_name = time_data_obj.previous_month_name(new_month)
			subsequent_month_name = '>'
		end
	else
		previous_month_name = '<'
		subsequent_month_name = '>'
	end


	@current_monday_month_year
	@month_year = month_name + ' ' + input_year.to_s
	@weekday_array
	@weekdays
	@previous_month = previous_month_name.to_s
	@subsequent_month = subsequent_month_name.to_s
	erb :dashboard_new_deployment
end









=begin

		<div class="calendar_slot_grey_full">
			<div class="calendar_text" align="right">1</div>
			<div class="LCR4_calendar">Some different changes</div>
			<div class="LCR2_calendar">Changes to UI</div>
			<div class="LCR1_calendar">Security changes</div>
			<div class="LCR3_calendar">Map changes</div>
		</div>
		<div class="calendar_slot_grey">
			<div class="calendar_text" align="right">2</div>
		</div>
		<div class="calendar_slot_grey">
			<div class="calendar_text" align="right">3</div>
		</div>

=end


=begin

			if weekday == 3 && time_slot == "20:00"%>
				<div class="week_calendar_slot">
					<div class="calendar_text" align="right"><%=time_slot%></div>
					<div class="LCR4_calendar_week"><div class="week_calendar_text">Title of some changes</div></div>
				</div>
			<% elsif weekday == 1 && time_slot == "19:00"%>
				<div class="week_calendar_slot">
					<div class="calendar_text" align="right"><%=time_slot%></div>
					<div class="LCR1_calendar_week">
					<div class="triangle"></div>
					<div class="week_calendar_text_fail"><strike>Security changes</strike></div>
					</div>
				</div>
			<% elsif weekday == 3 && time_slot == "21:00"%>
				<div class="week_calendar_slot">
					<div class="calendar_text" align="right"><%=time_slot%></div>
					<div class="LCR1_calendar_week">
					<div class="week_calendar_text_fail_2">Security changes</div>
					<img src="fail.png" class="image_format">
					</div>
				</div>
			<% elsif weekday == 5 && time_slot == "02:00"%>
				<div class="week_calendar_slot">
					<div class="calendar_text" align="right"><%=time_slot%></div>
					<div class="LCR2_calendar_week"><div class="week_calendar_text">Changes to UI</div></div>
				</div>
			<% elsif weekday == 6 && time_slot == "22:00" || weekday == 6 && time_slot == "23:00" || weekday == 6 && time_slot == "00:00"%>
				<div class="week_calendar_slot">
					<div class="calendar_text" align="right"><%=time_slot%></div>
					<div class="LCR3_calendar_week"><div class="week_calendar_text">Infrastructure changes</div></div>
				</div>
			<% elsif weekday == 5 %>
				<% if time_slot == "19:00" %>
					<div class="week_calendar_slot_bottom">
						<div class="calendar_text" align="right"><%=time_slot%></div>
					</div>
				<% elsif time_slot == "04:00" %>
					<div class="week_calendar_slot_top">
						<div class="calendar_text" align="right"><%=time_slot%></div>
					</div>
				<% else %>
					<div class="week_calendar_slot_today">
						<div class="calendar_text" align="right"><%=time_slot%></div>
					</div>
				<% end %>
			<% elsif weekday == 1 || weekday == 2%>
				<div class="week_calendar_slot_grey">
					<div class="calendar_text" align="right"><%=time_slot%></div>
				</div>
			<% else %>
				<div class="week_calendar_slot">
					<div class="calendar_text" align="right"><%=time_slot%></div>
				</div>
			<% end %>
			<option id="1900" value="1900">19:00</option>
			<option id="2000" value="2000">20:00</option>
			<option id="2100" value="2100">21:00</option>
			<option id="2200" value="2200">22:00</option>
			<option id="2300" value="2300">23:00</option>
			<option id="0000" value="0000">00:00</option>
			<option id="0100" value="0100">01:00</option>
			<option id="0200" value="0200">02:00</option>
			<option id="0300" value="0300">03:00</option>
=end


=begin
<label class="page1">Start Time</label>
<div class="tooltips" title="Please select the start_time that the customer will primarily be served from">
    <select id="start_time" name="start_time" placeholder="Phantasyland">
        <option></option>
        <option>19:00</option>
        <option>20:00</option>
        <option>21:00</option>
        <option>22:00</option>
        <option>23:00</option>
        <option>00:00</option>
        <option>01:00</option>
        <option>02:00</option>
        <option>03:00</option>
    </select>
</div>
<br />
<br />
<label class="page1">End Time</label>
<div class="tooltips" title="Please select the city that the customer is primarily to be served from.">
    <select id="end_time" name="end_time" placeholder="Anycity"></select>
</div>
=end

=begin
jQuery(function($) {
    var end_times = {
        '19:00': ["20:00", "21:00", "22:00", "23:00", "00:00", "01:00", "02:00", "03:00", "04:00"],
        '20:00': ["21:00", "22:00", "23:00", "00:00", "01:00", "02:00", "03:00", "04:00"],
        '21:00': ["22:00", "23:00", "00:00", "01:00", "02:00", "03:00", "04:00"],
        '22:00': ["23:00", "00:00", "01:00", "02:00", "03:00", "04:00"],
        '23:00': ["00:00", "01:00", "02:00", "03:00", "04:00"],
        '00:00': ["01:00", "02:00", "03:00", "04:00"],
        '01:00': ["02:00", "03:00", "04:00"],
        '02:00': ["03:00", "04:00"],
        '03:00': ["04:00"]
    }

    var $end_times = $('#end_time');
    $('#start_time').change(function () {
        var start_time = $(this).val(), lcns = end_times[start_time] || [];

        var hours = start_time.substring(0, 2);
        var new_count = 0
        var html = '';
        for (var counter = 1; counter < 5; counter++) {
            var additional_hours = (parseInt(hours) + counter).toString()
            if (additional_hours.length == 1) {
                var additional_hours = '0' + additional_hours + ':00';
            }
            else {
                var additional_hours = additional_hours + ':00';
            }
            if (additional_hours == "24:00") {
                var additional_hours = "00:00";
                var hours = 0-counter;
            }
          var html = html + '<option value="'+ additional_hours + '">' + additional_hours + '</option>'
        }


        $end_times.html(html)
    });
});

=end
