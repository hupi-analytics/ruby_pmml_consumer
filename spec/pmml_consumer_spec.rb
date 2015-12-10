require 'spec_helper'

describe PMMLConsumer do
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
        <RegressionModel modelName="linear regression" functionName="regression">
          <MiningSchema>
            <MiningField name="field_0" usageType="active"/>
            <MiningField name="field_1" usageType="active"/>
            <MiningField name="field_2" usageType="active"/>
            <MiningField name="field_3" usageType="active"/>
            <MiningField name="field_4" usageType="active"/>
            <MiningField name="field_5" usageType="active"/>
            <MiningField name="field_6" usageType="active"/>
            <MiningField name="field_7" usageType="active"/>
            <MiningField name="field_8" usageType="active"/>
            <MiningField name="field_9" usageType="active"/>
            <MiningField name="field_10" usageType="active"/>
            <MiningField name="target" usageType="target"/>
          </MiningSchema>
          <RegressionTable intercept="1.015704555569793">
            <NumericPredictor name="field_0" coefficient="0.13455516964319997"/>
            <NumericPredictor name="field_1" coefficient="0.007262531691286593"/>
            <NumericPredictor name="field_2" coefficient="0.004521408367568601"/>
            <NumericPredictor name="field_3" coefficient="0.03247933694613156"/>
            <NumericPredictor name="field_4" coefficient="0.001258452391950483"/>
            <NumericPredictor name="field_5" coefficient="0.05448791695245674"/>
            <NumericPredictor name="field_6" coefficient="0.0033969530222289013"/>
            <NumericPredictor name="field_7" coefficient="0.01564525905643964"/>
            <NumericPredictor name="field_8" coefficient="0.05212289513645602"/>
            <NumericPredictor name="field_9" coefficient="0.010676486879237128"/>
            <NumericPredictor name="field_10" coefficient="0.17289948006284542"/>
          </RegressionTable>
      </RegressionModel>
      </PMML>
    XML
  end
  let(:xml) { Nokogiri::XML(pmml_string) }

  it "has a version number" do
    expect(PMMLConsumer::VERSION).not_to be nil
  end

  let(:field_hash) do
    {
      "salary" => { "dataType" => "double" },
      "car_location" => {
        "dataType" => "string",
        "values" => %w(carpark street)
      },
      "number_of_claims" => { "dataType" => "integer" }
    }
  end

  it "parse field in a hash" do
    expect(PMMLConsumer.field_type(xml)).to eq(field_hash)
  end

  it "select the first model" do
    expect(PMMLConsumer.model_node(xml, nil).name).to eq("RegressionModel")
    expect(PMMLConsumer.model_node(xml, nil).attributes["modelName"].value).to eq("Sample for stepwise polynomial regression")
  end

  it "select model by name" do
    expect(PMMLConsumer.model_node(xml, "linear regression").name).to eq("RegressionModel")
    expect(PMMLConsumer.model_node(xml, "linear regression").attributes["modelName"].value).to eq("linear regression")
  end
end
