import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["part", "startDate", "endDate", "pdfLink", "csvLink"]
  static values = { counts: Object, max: Number }

  connect() {
    // 1. まずは一番大事なヒートマップの描画を実行
    this.drawHeatmap()
    
    // 2. その後、リンクの更新を実行（失敗しても描画には影響させない）
    try {
      this.updateLinks()
    } catch (error) {
      console.warn("Links update failed:", error)
    }
  }

  // 🌡️ ヒートマップ描画（既存ロジック）
  drawHeatmap() {
    if (!this.hasCountsValue) return
    
    const counts = this.countsValue
    const max = this.maxValue || 1

    this.partTargets.forEach(part => {
      const count = counts[part.id] || 0
      if (count > 0) {
        const intensity = (count / max).toFixed(2)
        part.style.fill = `rgba(239, 68, 68, ${Math.max(0.2, intensity)})`
        if (count === max) {
          part.style.stroke = "#b91c1c"
          part.style.strokeWidth = "2px"
        }
      } else {
        part.style.fill = "#e5e7eb"
      }
    })
  }

  // 🔗 リンク更新（ここを安全に修正）
  updateLinks() {
    // ターゲットが揃っていない場合は何もしない（ここでエラーを落とさない）
    if (!this.hasStartDateTarget || !this.hasEndDateTarget) return

    const start = this.startDateTarget.value
    const end = this.endDateTarget.value

    // PDFリンク
    if (this.hasPdfLinkTarget) {
      const pdfUrl = new URL(this.pdfLinkTarget.href, window.location.origin)
      pdfUrl.searchParams.set("start_date", start)
      pdfUrl.searchParams.set("end_date", end)
      this.pdfLinkTarget.href = pdfUrl.toString()
    }

    // CSVリンク
    if (this.hasCsvLinkTarget) {
      const csvUrl = new URL(this.csvLinkTarget.href, window.location.origin)
      csvUrl.searchParams.set("start_date", start)
      csvUrl.searchParams.set("end_date", end)
      this.csvLinkTarget.href = csvUrl.toString()
    }
  }
}