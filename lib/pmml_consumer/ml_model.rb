require "nokogiri"
module PMMLConsumer
  class MLModel
    attr_accessor :model_node, :fields_type

    def initialize(model_node, field_type)
      @model_node = model_node
      @fields_type = filter_field(field_type)
      @target_fields = target_fields
    end

    def predict(input)
      raise "not implemented"
    end

    def cast_input(input)
      @fields_type.each do |field_name, field_type|
        input[field_name] = if input[field_name].nil? && !field_type["missingValueReplacement"].nil?
          field_type["missingValueReplacement"]
        elsif input[field_name].nil? && field_type["missingValueReplacement"].nil?
          raise "value '#{field_name}' not found and no value replacement set"
        else
          case field_type["dataType"]
          when "double"
            input[field_name].to_f
          when "integer"
            input[field_name].to_i
          when "string"
            input[field_name].to_s
          else
            raise "unknow dataType: #{field_type["dataType"]}"
          end
        end
        if field_type["values"].is_a?(Array) && !field_type["values"].include?(input[field_name])
          raise "not a valid value: #{input[field_name]}"
        end
      end
      input
    end

    def filter_field(field_type)
      @model_node.xpath("xmlns:MiningSchema/xmlns:MiningField").each do |mining_field|
        unless mining_field.attributes["usageType"].nil? || mining_field.attributes["usageType"].value == "active"
          field_type.delete(mining_field.attributes["name"].value)
        end
      end
      field_type
    end

    def target_fields
      @model_node.xpath("xmlns:MiningSchema/xmlns:MiningField[@usageType='target']").map do |mining_field|
        mining_field["name"]
      end
    end
  end
end
