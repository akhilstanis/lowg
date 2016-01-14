require 'spec_helper'
require 'lowg/conversation'
require 'lowg/summary_mail'

describe Lowg::SummaryMail do

  MOCK_DEBTS = {
    'Mariya Fredrics' => { 'Ebin Bastian' => 50  },
    'Jones Janarth'   => { 'Ebin Bastian' => 200 },
    'Ebin Bastian'    => {}
  }

  before :each do
    conversation = double(Lowg::Conversation, :settle => MOCK_DEBTS)
    @summary_mail = Lowg::SummaryMail.new(conversation)
  end

  it 'should construct exchanges' do
    expect(@summary_mail.exchanges).to eql(["Mariya Fredrics should pay Rs. 50 to Ebin Bastian", "Jones Janarth should pay Rs. 200 to Ebin Bastian"])
  end

  it 'should render html' do
    File.write('/tmp/template.html', @summary_mail.html)
  end

end