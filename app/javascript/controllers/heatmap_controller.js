
import { Controller } from "stimulus"

export default class extends Controller {
  static values = { counts: Object, max: Number }
  static targets = ["part"]

  connect() {
    this.drawHeatmap()
  }

  drawHeatmap() {
    const counts = this.countsValue
    const max = this.maxValue

    this.partTargets.forEach(part => {
      const count = counts[part.id] || 0
      
      if (count > 0) {
        // 頻度に応じて色の濃さを決める (0.1 ~ 1.0)
        const intensity = (count / max).toFixed(2)
        // 回数が多いほど濃い赤（rgbaのアルファ値を調整）
        part.style.fill = `rgba(239, 68, 68, ${Math.max(0.2, intensity)})`
        // さらに、回数が多いところは枠線を付けて強調
        if (count === max) {
          part.style.stroke = "#b91c1c"
          part.style.strokeWidth = "2px"
        }
      } else {
        part.style.fill = "#e5e7eb" // 0回はグレー
      }
    });
  }
}