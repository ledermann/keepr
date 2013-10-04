module AccountSystem
  SKR03 = {
    1000 => { :name => 'Kasse',             :kind => 'Asset'     },
    1200 => { :name => 'Bank',              :kind => 'Asset'     },
    1576 => { :name => 'Vorsteuer 19%',     :kind => 'Asset'     },

    1600 => { :name => 'Verbindl. aus L&L', :kind => 'Liability' },

    4920 => { :name => 'Portokosten',       :kind => 'Expense'   }
  }

  def skr03(number)
    if skr03 = SKR03[number]
      Keepr::Account.find_or_create_by(number: number) do |account|
        account.name = skr03[:name]
        account.kind = skr03[:kind]
      end
    else
      raise ArgumentError.new("Account #{number} not found in account system!")
    end
  end
end
