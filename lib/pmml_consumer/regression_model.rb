module PMMLConsumer
  class RegressionModel < MLModel

    def predict(input)
      cast_input(input)
      res = @model_node.xpath("xmlns:RegressionTable").each_with_object({}) do |regression_table, result|
        res_name = regression_table["targetCategory"]
        res_name ||= @model_node["targetFieldName"]
        res_name ||= @target_fields.first
        result[res_name] = regression_table["intercept"].to_f
        regression_table.element_children.each do |predictor|
          case predictor.name
          when "NumericPredictor"
            coefficient = predictor["coefficient"].to_f
            exponent = (predictor["exponent"] || "1").to_i
            result[res_name] += coefficient * (input[predictor["name"]]**exponent)
          when "CategoricalPredictor"
            if predictor["value"] == input[predictor["name"]]
              result[res_name] += predictor["coefficient"].to_f
            end
          when "PredictorTerm"
            coefficient = predictor["coefficient"].to_f
            predictor.element_children.each do |field_ref|
              coefficient *= input[field_ref["field"]]
            end
            result[res_name] += coefficient
          else
            raise "unknow predictor name: #{predictor.name}"
          end
        end
      end
      case @model_node["normalisationMethod"]
      when "softmax"
        softmax(res)
      when "logit"
        logit(res)
      when "probit"
        probit(res)
      when "cloglog"
        cloglog(res)
      when "loglog"
        loglog(res)
      when "cauchit"
        cauchit(res)
      when "exp"
        exp(res)
      when nil, "none"
      else
        raise "unknow normalisation method: #{@model_node["normalisationMethod"]}"
      end
      res
    end

    def softmax(result)
      if result.count == 1
        1 / (1 + Math.exp(-result.values.first))
      else
        sum1n = result.values.reduce(:+)
        result.each do |k, v|
          result[k] = Math.exp(v) / sum1n
        end
      end
    end

    def logit(result)
      result.each do |k, v|
        result[k] = 1 / (1 + Math.exp(-v))
      end
    end

    def cloglog(result)
      raise "error" if result.count == 1
      result.each do |k, v|
        result[k] = 1 - Math.exp(-Math.exp(v))
      end
    end

    def loglog(result)
      raise "error" if result.count == 1
      result.each do |k, v|
        result[k] = Math.exp(-Math.exp(-v))
      end
    end

    def cauchit(result)
      raise "error" if result.count == 1
      result.each do |k, v|
        result[k] = 0.5 + (1 / Math::PI) * Math.atan(v)
      end
    end

    def exp(result)
      result.each do |k, v|
        result[k] = Math.exp(v)
      end
    end
  end
end
