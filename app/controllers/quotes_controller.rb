class QuotesController < ApplicationController
  def random
    @quote = Quote.order("RANDOM()").first

    if @quote.nil?
      render plain: "No quotes available", status: :not_found
    end
  end
end
