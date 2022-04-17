require 'spec_helper'

RSpec.describe HadiFunnel do
  include Rack::Test::Methods

  def app
    HadiFunnel
  end

  describe 'database' do

    context "canary in the coal mine" do
      it "loads the homepage" do
        get '/'
        expect(last_response.status).to eq(200)
      end
    end

    context "Local transaction table" do
      before do
        @item = FunnelTxn.new
        @item.email_address = "joe@gmail.com"
        @item.sent_at = Time.new.to_s
        @item.status = "subscribed"
        @item.name = "Joe"
        @item.email_id = "SUB02"
        @item.status_date = "2021-02-09"
        @item.save
      end

      it "successfully stores and retrieves an item" do
        @client = Aws::DynamoDB::Client.new
        @item_query = {
          table_name: "FunnelTxn",
          key: {
            email_address: "joe@gmail.com",
            sent_at: @item.sent_at
          }
        }
        @result = @client.get_item(@item_query)
        expect(@result.item["status"]).to eq("subscribed")
        expect(@result.item["name"]).to eq("Joe")
        expect(@result.item["email_id"]).to eq("SUB02")
        expect(@result.item["status_date"]).to eq("2021-02-09")
      end

    end
  end
end
