require 'spec_helper'
require 'lowg/conversation'

describe Lowg::Conversation do

  before :all do
    raw_conversation = File.read(File.expand_path("#{File.dirname(__FILE__)}/../fixtures/WhatsApp Chat with Goa Trip.txt"))
    @conversation = Lowg::Conversation.parse('WhatsApp Chat with Goa Trip', 'insanefunction@gmail.com', raw_conversation)
  end

  it 'should parse the info from whatsapp mail' do
    expected_parsed_expenses = [
      { :timestamp => '8:55AM, Sep 16', :sender => 'Mariya Fredrics', :amount =>  500, :description => 'Tickets for Captain America' },
      { :timestamp => '8:18AM, Sep 16', :sender => 'Jones Janarth',   :amount =>  450, :description => 'Lunch at McDonalds' },
      { :timestamp => '8:40AM, Sep 16', :sender => 'Jones Janarth',   :amount => -100, :description => 'Lunch at McDonalds' },
      { :timestamp => '8:51AM, Sep 16', :sender => 'Ebin Bastian',    :amount =>  800, :description => 'Tickets to Goa' }
    ]

    expect(@conversation.expenses).to eql(expected_parsed_expenses)
  end

  it 'should calculate individual sums' do
    expect(@conversation.individual_sums).to eql({
      'Mariya Fredrics' => 500,
      'Jones Janarth'   => 350,
      'Ebin Bastian'    => 800
    })
  end

  it 'should calculate grand total' do
    expect(@conversation.grand_total).to eql(1650)
  end

  it 'should calculate balances' do
    expect(@conversation.balances).to eql([
      { :sender => 'Mariya Fredrics', :balance => -50  },
      { :sender => 'Jones Janarth',   :balance => -200 },
      { :sender => 'Ebin Bastian',    :balance => 250  }
    ])
  end

  it 'should split and settle' do
    expect(@conversation.settle).to eql({
      'Mariya Fredrics' => { 'Ebin Bastian' => 50  },
      'Jones Janarth'   => { 'Ebin Bastian' => 200 },
      'Ebin Bastian'    => {}
    })
  end

end