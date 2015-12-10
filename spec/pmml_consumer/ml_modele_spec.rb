require 'spec_helper'

describe PMMLConsumer::MLModel do
  let(:pmml_string) do
    <<-XML
      <PMML xmlns="http://www.dmg.org/PMML-4_2" version="4.2">
        <Header copyright="DMG.org"/>
        <DataDictionary numberOfFields="3">
          <DataField name="salary" optype="continuous" dataType="double"/>
          <DataField name="car_location" optype="categorical" dataType="string">
            <Value value="carpark"/>
            <Value value="street"/>
          </DataField>
          <DataField name="number_of_claims" optype="continuous" dataType="integer"/>
        </DataDictionary>
        <RegressionModel functionName="regression" modelName="Sample for stepwise polynomial regression" algorithmName="stepwisePolynomialRegression" targetFieldName="number_of_claims">
          <MiningSchema>
            <MiningField name="salary"/>
            <MiningField name="car_location"/>
            <MiningField name="number_of_claims" usageType="target"/>
          </MiningSchema>
          <RegressionTable intercept="3216.38">
            <NumericPredictor name="salary" exponent="1" coefficient="-0.08"/>
            <NumericPredictor name="salary" exponent="2" coefficient="9.54E-7"/>
            <NumericPredictor name="salary" exponent="3" coefficient="-2.67E-12"/>
            <CategoricalPredictor name="car_location" value="carpark" coefficient="93.78"/>
            <CategoricalPredictor name="car_location" value="street" coefficient="288.75"/>
          </RegressionTable>
        </RegressionModel>
      </PMML>
    XML
  end
  let(:xml) { Nokogiri::XML(pmml_string) }
  let(:filtered_field) do
    {
      "salary" => { "dataType" => "double" },
      "car_location" => {
        "dataType" => "string",
        "values" => %w(carpark street)
      }
    }
  end
  let(:input) do
    {
      "salary" => "10e3",
      "car_location" => "street"
    }
  end
  let(:input_casted) do
    {
      "salary" => 10e3,
      "car_location" => "street"
    }
  end
  let(:ml_model) { PMMLConsumer::MLModel.new(PMMLConsumer.model_node(xml, nil), PMMLConsumer.field_type(xml)) }

  it "filter unused field" do
    expect(ml_model.fields_type).to eq(filtered_field)
  end

  it "cast input" do
    expect(ml_model.cast_input(input)).to eq(input_casted)
  end
  it { expect(ml_model).to respond_to(:predict) }
end
