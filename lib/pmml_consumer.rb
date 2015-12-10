require "pmml_consumer/version"
require "nokogiri"

require "pmml_consumer/ml_model"
require "pmml_consumer/regression_model"

begin
  require "pry"
rescue LoadError
end

module PMMLConsumer
  def self.load(pmml_string, model_name: nil)
    xml = Nokogiri::XML(pmml_string)

    ml_model = model_node(xml, model_name)

    case ml_model.name
    when 'RegressionModel'
      RegressionModel.new(ml_model, field_type(xml))
    else
      MLModel.new(ml_model, field_type(xml))
    end
  end

  def self.field_type(xml)
    xml.xpath("/xmlns:PMML/xmlns:DataDictionary/xmlns:DataField").each_with_object({}) do |child, memo|
      memo[child.attributes["name"].value] = case child.attributes["optype"].value
      when "continuous"
        child.to_h.reject! { |key| %w(name optype).include?(key) }
      when "categorical"
        data_field_h = child.to_h.reject! { |key| %w(name optype).include?(key) }
        data_field_h["values"] = child.xpath("xmlns:Value").map do |cat|
          cat.attributes["value"].value
        end
        data_field_h
      else
        raise "unknow optype: #{child.attributes['optype'].value}"
      end
    end
  end

  def self.model_node(xml, model_name)
    if model_name.nil?
      xml.xpath("/xmlns:PMML/*[contains(name(), 'Model') or (name() = 'NeuralNetwork') or (name() = 'Scorecard')]").first
    else
      xml.xpath("/xmlns:PMML/*[@modelName='#{model_name}']").first
    end
  end
end
