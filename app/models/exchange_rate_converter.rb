class ExchangeRateConverter
  def self.convert(usd, date)
    exchange = get_most_recent_exchange(Date.parse(date), 0)
    if exchange
      (usd / exchange.rate).round(4)
    end
  end

  def self.get_most_recent_exchange(date, attempts)
    # check that date falls in range of 2000 - today
    if date > Date.parse('1999-12-31') && date < Date.today + 1
      begin
        # rspec not allowing me to bypass raising of errors, having to put rescue here
        return Exchange.find(date)
      rescue Mongoid::Errors::DocumentNotFound
        # message to alert the echange was closed that day
        puts Rainbow("No data found on that date. Checking one day behind").orange
        attempts += 1
        if attempts > 7
          puts Rainbow("We are sorry but something went wrong. No dates found near your query.").yellow
          return
        end
        get_most_recent_exchange(date -= 1.day, attempts)
      end
    else
      # message error if date is out of range
      puts Rainbow("The date range must be between January 1st 2000 and today").yellow
      return
    end
  end

  def self.get_string_conversion(usd, date)
    amount = convert(usd, date)
    "On #{date} $#{usd} was equal to €#{amount}"
  end

end
