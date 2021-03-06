# Copyright 2015-2016 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License"). You may not
# use this file except in compliance with the License. A copy of the License is
# located at
#
#     http://aws.amazon.com/apache2.0/
#
# or in the "license" file accompanying this file. This file is distributed on
# an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
# or implied. See the License for the specific language governing permissions
# and limitations under the License.

module Aws

  # +Aws::Record+ is the module you include in your model classes in order to
  # decorate them with the Amazon DynamoDB integration methods provided by this
  # library. Methods you can use are shown below, in sub-modules organized by
  # functionality.
  #
  # @example A class definition using +Aws::Record+
  #   class MyModel
  #     include Aws::Record
  #     string_attr     :uuid,    hash_key: true
  #     integer_attr    :post_id, range_key: true
  #     boolean_attr    :is_active
  #     datetime_attr   :created_at
  #     string_set_attr :tags
  #     map_attr        :metadata
  #   end
  module Record
    # @!parse extend RecordClassMethods
    # @!parse include Attributes
    # @!parse extend Attributes::ClassMethods
    # @!parse include ItemOperations
    # @!parse extend ItemOperations::ItemOperationsClassMethods
    # @!parse include Query
    # @!parse extend Query::QueryClassMethods
    # @!parse include SecondaryIndexes
    # @!parse extend SecondaryIndexes::SecondaryIndexesClassMethods
    # @!parse include DirtyTracking
    # @!parse extend DirtyTracking::DirtyTrackingClassMethods

    # Usage of {Aws::Record} requires only that you include this module. This
    # method will then pull in the other default modules.
    #
    # @example
    #   class MyTable
    #     include Aws::Record
    #     # Attribute definitions go here...
    #   end
    def self.included(sub_class)
      sub_class.send(:extend, ClientConfiguration)
      sub_class.send(:extend, RecordClassMethods)
      sub_class.send(:include, Attributes)
      sub_class.send(:include, ItemOperations)
      sub_class.send(:include, DirtyTracking)
      sub_class.send(:include, Query)
      sub_class.send(:include, SecondaryIndexes)
    end

    private
    def dynamodb_client
      self.class.dynamodb_client
    end

    module RecordClassMethods

      # Returns the Amazon DynamoDB table name for this model class.
      #
      # By default, this will simply be the name of the class. However, you can
      # also define a custom table name at the class level to be anything that
      # you want.
      #
      # @example
      #   class MyTable
      #     include Aws::Record
      #   end
      #
      #   class MyTableTest
      #     include Aws::Record
      #     set_table_name "test_MyTable"
      #   end
      #
      #   MyTable.table_name      # => "MyTable"
      #   MyOtherTable.table_name # => "test_MyTable"
      def table_name
        if @table_name
          @table_name
        else
          @table_name = self.name.split("::").join("_")
        end
      end

      # Allows you to set a custom Amazon DynamoDB table name for this model
      # class.
      #
      # @example
      #   class MyTable
      #     include Aws::Record
      #     set_table_name "prod_MyTable"
      #   end
      #
      #   class MyTableTest
      #     include Aws::Record
      #     set_table_name "test_MyTable"
      #   end
      #
      #   MyTable.table_name      # => "prod_MyTable"
      #   MyOtherTable.table_name # => "test_MyTable"
      def set_table_name(name)
        @table_name = name
      end

      # Fetches the table's provisioned throughput from the associated Amazon
      # DynamoDB table.
      #
      # @return [Hash] a hash containing the +:read_capacity_units+ and
      #   +:write_capacity_units+ of your remote table.
      # @raise [Aws::Record::Errors::TableDoesNotExist] if the table name does
      #   not exist in DynamoDB.
      def provisioned_throughput
        begin
          resp = dynamodb_client.describe_table(table_name: table_name)
          throughput = resp.table.provisioned_throughput
          return {
            read_capacity_units: throughput.read_capacity_units,
            write_capacity_units: throughput.write_capacity_units
          }
        rescue DynamoDB::Errors::ResourceNotFoundException
          raise Record::Errors::TableDoesNotExist
        end
      end

      # Checks if the model's table name exists in Amazon DynamoDB.
      #
      # @return [Boolean] true if the table does exist, false if it does not.
      def table_exists?
        begin
          resp = dynamodb_client.describe_table(table_name: table_name)
          if resp.table.table_status == "ACTIVE"
            true
          else
            false
          end
        rescue DynamoDB::Errors::ResourceNotFoundException
          false
        end
      end

      # Turns off mutation tracking for all attributes in the model.
      def disable_mutation_tracking
        @track_mutations = false
      end

      # Turns on mutation tracking for all attributes in the model. Note that
      # mutation tracking is on by default, so you generally would not need to
      # call this. It is provided in case there is a need to dynamically turn
      # this feature on and off, though that would be generally discouraged and
      # could cause inaccurate mutation tracking at runtime.
      def enable_mutation_tracking
        @track_mutations = true
      end

      # @return [Boolean] true if mutation tracking is enabled at the model
      # level, false otherwise.
      def mutation_tracking_enabled?
        if defined?(@track_mutations)
          @track_mutations
        else
          @track_mutations = true
        end
      end

      def model_valid?
        if @keys.hash_key.nil?
          raise Errors::InvalidModel.new("Table models must include a hash key")
        end
      end
    end
  end
end
