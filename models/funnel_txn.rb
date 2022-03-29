class FunnelTxn
  include Aws::Record
  string_attr :email_address, hash_key: true
  string_attr :sent_at, range_key: true
  string_attr :status
  string_attr :name
  string_attr :email_id
  string_attr :status_date
end
