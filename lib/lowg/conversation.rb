class Lowg::Conversation

  EXPENSE_LINE_REGEXP = /^(?<timestamp>[\w\:,\s]+)-(?<sender>[\w\s]+[^:])\:\s+(?<amount>[\+\-]\d+)\s+(?<description>.+)$/

  attr_accessor :name, :email, :expenses, :debts

  def initialize(name, email)
    @name  = name
    @email = email
  end

  def self.parse(name, email, raw_conversation)
    new(name, email).tap do |conversation|
      conversation.expenses = raw_conversation.split("\n").collect do |line|
        if parsed_line = line.match(EXPENSE_LINE_REGEXP)
          {
            :timestamp   => parsed_line[:timestamp].strip,
            :sender      => parsed_line[:sender].strip,
            :amount      => parsed_line[:amount].strip.to_i,
            :description => parsed_line[:description].strip
          }
        end
      end.compact
    end
  end

  def individual_sums
    @individual_sums ||= expenses.inject({}) do |hash,expense|
      hash[expense[:sender]] ||= 0
      hash[expense[:sender]] += expense[:amount]
      hash
    end
  end

  def grand_total
    @grand_total = individual_sums.inject(0) { |sum,(sender,total)| sum += total }
  end

  def balances
    @balances ||= begin
      total_per_sender = grand_total / individual_sums.size
      individual_sums.collect do |sender,amount|
        {
          :sender  => sender,
          :balance => amount - total_per_sender
        }
      end
    end
  end

  def senders
    @senders ||= individual_sums.keys
  end

  def settle
    return @debts if @debts

    @debts = senders.inject({}) do |hash,sender|
      hash[sender] = {}
      hash
    end

    resolved_members = 0
    members = Marshal.load(Marshal.dump(balances))

    while resolved_members != members.size
      members = members.sort_by { |member| member.to_a.last }
      sender = members.first
      recipient = members.last

      sender_should_send = sender[:balance].abs
      recipient_should_receive = recipient[:balance].abs
      amount = sender_should_send > recipient_should_receive ? recipient_should_receive : sender_should_send

      sender[:balance] = sender[:balance] + amount
      recipient[:balance] = recipient[:balance] - amount
      @debts[sender[:sender]][recipient[:sender]] = amount

      sender_should_send = sender[:balance].abs
      recipient_should_receive = recipient[:balance].abs
      resolved_members += 1 if sender_should_send == 0
      resolved_members += 1 if recipient_should_receive == 0
    end

    @debts
  end

end