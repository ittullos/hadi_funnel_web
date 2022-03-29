require 'rubygems'
require 'sinatra'
require './app'
require 'pry-byebug'
require 'aws-record'
require './models/funnel_txn'



Aws.config.update(
  endpoint: 'http://localhost:8000',
  region: 'us-east-1'
)

cfg = Aws::Record::TableConfig.define do |t|
  t.model_class(FunnelTxn)
  t.read_capacity_units(5)
  t.write_capacity_units(2)
end
cfg.migrate!

run HadiFunnel
