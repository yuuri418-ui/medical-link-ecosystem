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

  def quick_chart_url(logs)
    # 日付、痛み、倦怠感、体温のデータを抽出
    labels = logs.map { |l| l.date.strftime('%m/%d') }
    pain_data = logs.map { |l| l.pain_vas }
    fatigue_data = logs.map { |l| l.fatigue_vas }
    # 体温は最高値を取得（nilの場合は0、グラフ上は見やすく35度〜に設定）
    temp_data = logs.map { |l| l.temperature_logs.maximum(:value) || nil }

    chart_config = {
      type: 'line',
      data: {
        labels: labels,
        datasets: [
          { label: '痛み', data: pain_data, borderColor: '#3b82f6', fill: false, yAxisID: 'y1', borderWidth: 2, pointRadius: 2 },
          { label: '倦怠感', data: fatigue_data, borderColor: '#8b5cf6', fill: false, yAxisID: 'y1', borderWidth: 2, pointRadius: 2 },
          { label: '体温(℃)', data: temp_data, borderColor: '#10b981', fill: false, yAxisID: 'y2', borderWidth: 2, pointRadius: 2, borderDash: [5, 5] }
        ]
      },
      options: {
        scales: {
          yAxes: [
            { id: 'y1', type: 'linear', position: 'left', ticks: { min: 0, max: 10, stepSize: 2 }, scaleLabel: { display: true, labelString: 'VAS (0-10)' } },
            { id: 'y2', type: 'linear', position: 'right', ticks: { min: 35.0, max: 40.0, stepSize: 1 }, scaleLabel: { display: true, labelString: '体温 (℃)' }, gridLines: { drawOnChartArea: false } }
          ]
        },
        legend: { position: 'bottom' }
      }
    }.to_json

    "https://quickchart.io/chart?c=#{ERB::Util.url_encode(chart_config)}&w=600&h=250"
  end

  
end
