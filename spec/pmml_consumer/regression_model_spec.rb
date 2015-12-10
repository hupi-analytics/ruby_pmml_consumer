require 'spec_helper'

describe PMMLConsumer::RegressionModel do
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
          <RegressionTable intercept="3000.25">
            <NumericPredictor name="salary" exponent="1" coefficient="2"/>
            <NumericPredictor name="salary" exponent="2" coefficient="3"/>
            <NumericPredictor name="salary" exponent="3" coefficient="4"/>
            <CategoricalPredictor name="car_location" value="carpark" coefficient="50.2"/>
            <CategoricalPredictor name="car_location" value="street" coefficient="200.75"/>
          </RegressionTable>
        </RegressionModel>
      </PMML>
    XML
  end
  let(:xml) { Nokogiri::XML(pmml_string) }
  let(:regression_model) { PMMLConsumer::RegressionModel.new(PMMLConsumer.model_node(xml, nil), PMMLConsumer.field_type(xml)) }
  let(:input) do
    {
      "salary" => 100,
      "car_location" => "street"
    }
  end

  it "predict the right answer" do
    expect(regression_model.predict(input)).to eq({"number_of_claims" => 4033401 })
  end
end
