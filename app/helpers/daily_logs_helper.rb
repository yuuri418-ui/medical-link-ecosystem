module DailyLogsHelper
  def condition_color_class(condition)
    case condition.to_i
    when 5 then "bg-emerald-400" # 絶好調
    when 4 then "bg-blue-400"    # 良い
    when 3 then "bg-yellow-400"  # 普通
    when 2 then "bg-orange-400"  # 悪い
    when 1 then "bg-red-400"     # 絶不調
    else "bg-gray-200"
    end
  end

  
end
