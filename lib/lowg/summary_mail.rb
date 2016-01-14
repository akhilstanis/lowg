require 'erb'
require 'date'
require 'premailer'

class Lowg::SummaryMail

  attr_reader :conversation

  def initialize(conversation)
    @conversation = conversation
  end

  def exchanges
    conversation.settle.collect do |debt|
      payer = debt.first
      payees = debt.last

      payees.collect do |payee|
        name   = payee.first
        amount = payee.last

        "#{payer} should pay Rs. #{amount} to #{name}"
      end
    end.flatten
  end

  def html
    b = binding
    html = ERB.new(template).result(b)
    Premailer.new(html, :with_html_string => true).to_inline_css
  end

  def template
    @template ||= File.read(File.expand_path("#{File.dirname(__FILE__)}/summary_mail.html.erb"))
  end

end