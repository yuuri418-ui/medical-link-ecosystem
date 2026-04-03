import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["part", "input"]

  connect() {
    console.log("Body Schema: 接続完了！") // これがコンソールに出れば勝ちです
    try {
      this.selectedParts = JSON.parse(this.inputTarget.value || "[]")
    } catch(e) {
      this.selectedParts = []
    }
    this.refresh()
  }

  toggle(event) {
    event.preventDefault()
    const id = event.currentTarget.id
    console.log("クリックされた部位:", id)

    if (this.selectedParts.includes(id)) {
      this.selectedParts = this.selectedParts.filter(p => p !== id)
    } else {
      this.selectedParts.push(id)
    }

    this.inputTarget.value = JSON.stringify(this.selectedParts)
    this.refresh()
  }

  refresh() {
    this.partTargets.forEach(part => {
      // style.fill を使うのが最も優先順位が高く、確実です
      if (this.selectedParts.includes(part.id)) {
        part.style.fill = "#ef4444" // 赤
      } else {
        part.style.fill = "#cbd5e1" // グレー
      }
    })
  }
}